#!/usr/bin/env lua

local function script_dir()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)/[^/]+$") or "."
end

local DIR = script_dir()
local ROOT = DIR .. "/../.."

package.path = DIR .. "/?.lua;" .. ROOT .. "/tools/typstdoc/?.lua;" .. package.path

local util = require("util")

local GOLDEN_REL = "tests/visual/golden"

local USAGE = [[
Usage: tools/snapshot/diff.lua [options]

Visualise how the committed golden snapshots changed between two git refs.
Builds side-by-side and red-pixel overlay composites per changed snapshot and
emits a self-contained interactive HTML report (onion-skin slider, flicker,
keyboard stepper that walks the diffs and skips everything unchanged).

Options:
  --base <ref>    Base commit or branch (default: HEAD~1). For a branch like
                  `main`, the effective base is the merge-base with head, so the
                  report shows only the snapshots this branch/PR changed.
  --head <ref>    Head commit. Omitted compares the base against the on-disk
                  goldens (working tree), so uncommitted `--update` results show.
  --exact         Skip merge-base resolution; diff <base>..<head> literally.
  --only <substr> Restrict to golden keys containing this substring.
  --fuzz <pct>    ImageMagick `-fuzz` for the overlay (default: 2%).
  --out <dir>     Report directory (default: build/snapshot/diff-report).
  --open          Open the report in the browser (macOS).
  --help          Show this help and exit.
]]

local function shell_quote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

local function abs(path)
  if path:sub(1, 1) == "/" then return path end
  return ROOT .. "/" .. path
end

local function die(msg)
  io.stderr:write("snapshot-diff: " .. msg .. "\n")
  os.exit(1)
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parse_args(argv)
  local opts = {
    base = "HEAD~1",
    head = nil,
    exact = false,
    only = nil,
    fuzz = "2%",
    out = "build/snapshot/diff-report",
    open = false,
  }
  local i = 1
  local function take_value(flag)
    i = i + 1
    if i > #argv then die(flag .. " requires a value") end
    return argv[i]
  end
  while i <= #argv do
    local a = argv[i]
    if a == "--base" then opts.base = take_value(a)
    elseif a == "--head" then opts.head = take_value(a)
    elseif a == "--exact" then opts.exact = true
    elseif a == "--only" then opts.only = take_value(a)
    elseif a == "--fuzz" then opts.fuzz = take_value(a)
    elseif a == "--out" then opts.out = take_value(a)
    elseif a == "--open" then opts.open = true
    elseif a == "--help" or a == "-h" then io.write(USAGE); os.exit(0)
    else die("unknown arg: " .. a) end
    i = i + 1
  end
  return opts
end

-- All git calls run from ROOT; dynamic values are shell-quoted by the caller.
local function git(args)
  return util.popen_capture(string.format("git -C %s %s 2>&1", shell_quote(ROOT), args))
end

local function resolve_commit(ref)
  local code, out = git(string.format("rev-parse --verify %s^{commit}", shell_quote(ref)))
  if code ~= 0 then return nil end
  return trim(out)
end

local function subject(rev)
  local code, out = git("show -s --format=" .. shell_quote("%h %s") .. " " .. shell_quote(rev))
  if code ~= 0 then return rev end
  return trim(out)
end

-- `identify` is part of the ImageMagick suite the harness already requires.
local function dimensions(png)
  local _, out = util.popen_capture(
    string.format("identify -format '%%wx%%h' %s 2>/dev/null", shell_quote(png)))
  local w, h = out:match("(%d+)x(%d+)")
  return tonumber(w), tonumber(h)
end

-- Pad to a common canvas so `compare` does not abort on a size mismatch
-- (the margin-reclaim refresh changes canvas height). NorthWest gravity keeps
-- the plot pinned top-left so the growth shows as extra blank space.
local function pad_to(src, dst, w, h)
  os.execute(string.format(
    "convert %s -background white -gravity NorthWest -extent %dx%d %s 2>/dev/null",
    shell_quote(src), w, h, shell_quote(dst)))
end

-- Same `compare -metric AE -fuzz` contract as run.lua:diff_images, so the
-- overlay matches what CI gates on. Returns the AE pixel count (nil on error).
local function overlay(base_png, head_png, diff_png, fuzz)
  local cmd = string.format(
    "compare -metric AE -fuzz %s %s %s %s 2>&1",
    fuzz, shell_quote(base_png), shell_quote(head_png), shell_quote(diff_png))
  local code, out = util.popen_capture(cmd)
  if code > 1 then return nil end
  return tonumber(out:match("^%s*(%d+)"))
end

local function side_by_side(base_png, head_png, out_png)
  os.execute(string.format("convert %s %s +append %s 2>/dev/null",
    shell_quote(base_png), shell_quote(head_png), shell_quote(out_png)))
end

local function git_show_to(rev, path, dst)
  return os.execute(string.format("git -C %s show %s > %s 2>/dev/null",
    shell_quote(ROOT), shell_quote(rev .. ":" .. path), shell_quote(dst)))
end

-- Returns an array of { status = "A"|"M"|"D", path = <repo-relative> }.
local function changed_goldens(base_rev, head_ref)
  local entries, seen = {}, {}
  local args
  if head_ref then
    args = string.format("diff --name-status %s %s -- %s",
      shell_quote(base_rev), shell_quote(head_ref), shell_quote(GOLDEN_REL))
  else
    args = string.format("diff --name-status %s -- %s",
      shell_quote(base_rev), shell_quote(GOLDEN_REL))
  end
  local _, out = git(args)
  for line in out:gmatch("[^\n]+") do
    local status, path = line:match("^(%a)%S*\t(.+)$")
    if status and path then
      entries[#entries + 1] = { status = status, path = path }
      seen[path] = true
    end
  end
  -- Working-tree mode: untracked goldens are not in `diff`; surface them as adds.
  if not head_ref then
    local _, others = git(string.format(
      "ls-files --others --exclude-standard -- %s", shell_quote(GOLDEN_REL)))
    for path in others:gmatch("[^\n]+") do
      if not seen[path] then entries[#entries + 1] = { status = "A", path = path } end
    end
  end
  return entries
end

local function key_of(path)
  return (path:gsub("^" .. GOLDEN_REL:gsub("([%-%.])", "%%%1") .. "/", ""):gsub("%.png$", ""))
end

local function html_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local STYLE = [[
:root { color-scheme: light dark; }
* { box-sizing: border-box; }
body { margin: 0; font: 14px/1.5 system-ui, sans-serif; }
header.bar {
  position: sticky; top: 0; z-index: 5; padding: 10px 16px;
  background: Canvas; border-bottom: 1px solid #8884; display: flex;
  gap: 16px; align-items: center; flex-wrap: wrap;
}
header.bar .pos { font-variant-numeric: tabular-nums; font-weight: 600; }
header.bar button { font: inherit; padding: 4px 10px; cursor: pointer; }
header.bar .hint { color: #8888; margin-left: auto; }
main { padding: 16px; display: flex; flex-direction: column; gap: 28px; }
.card { scroll-margin-top: 64px; border: 1px solid #8884; border-radius: 8px; padding: 12px; }
.card.active { border-color: #3b82f6; box-shadow: 0 0 0 2px #3b82f655; }
.hd { display: flex; gap: 12px; align-items: baseline; flex-wrap: wrap; margin-bottom: 10px; }
.hd .key { font-weight: 600; }
.hd .meta { color: #8888; font-variant-numeric: tabular-nums; }
.badge { font-size: 11px; text-transform: uppercase; letter-spacing: .04em; padding: 2px 7px; border-radius: 99px; color: #fff; }
.badge.m { background: #d97706; }
.badge.a { background: #16a34a; }
.badge.d { background: #dc2626; }
.cols { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; }
figure { margin: 0; }
figcaption { font-size: 12px; color: #8888; margin-bottom: 4px; }
.cols img, .stack img { max-width: 100%; display: block; background:
  repeating-conic-gradient(#0001 0 25%, transparent 0 50%) 0 0 / 16px 16px; }
.overlay { margin-top: 12px; }
.stack { position: relative; display: inline-block; }
.stack .oh { position: absolute; inset: 0; }
.controls { display: flex; gap: 12px; align-items: center; margin-top: 6px; }
.controls input[type=range] { width: 240px; }
.controls button { font: inherit; padding: 3px 9px; cursor: pointer; }
]]

local SCRIPT = [[
const cards = Array.from(document.querySelectorAll('.card'));
const posEl = document.getElementById('pos');
let idx = 0;

function focus(i) {
  if (!cards.length) return;
  idx = (i + cards.length) % cards.length;
  cards.forEach((c, n) => c.classList.toggle('active', n === idx));
  cards[idx].scrollIntoView({ behavior: 'smooth', block: 'start' });
  posEl.textContent = (idx + 1) + ' / ' + cards.length;
}

function activeCard() { return cards[idx]; }

document.querySelectorAll('.stack').forEach(stack => {
  const head = stack.querySelector('.oh');
  const card = stack.closest('.card');
  const range = card.querySelector('.opa');
  range.addEventListener('input', () => { head.style.opacity = range.value / 100; });
  head.style.opacity = range.value / 100;
});

const flickTimers = new Map();
function toggleFlicker(card) {
  const head = card.querySelector('.oh');
  if (!head) return;
  if (flickTimers.has(card)) {
    clearInterval(flickTimers.get(card));
    flickTimers.delete(card);
    const range = card.querySelector('.opa');
    head.style.opacity = range.value / 100;
    return;
  }
  let on = true;
  flickTimers.set(card, setInterval(() => {
    head.style.opacity = on ? 1 : 0; on = !on;
  }, 500));
}

function cycleOnion(card) {
  const range = card.querySelector('.opa');
  if (!range) return;
  const steps = [0, 50, 100];
  const cur = Number(range.value);
  range.value = steps[(steps.findIndex(s => s >= cur) + 1) % steps.length];
  range.dispatchEvent(new Event('input'));
}

document.querySelectorAll('.flick').forEach(b =>
  b.addEventListener('click', () => toggleFlicker(b.closest('.card'))));
document.getElementById('next').addEventListener('click', () => focus(idx + 1));
document.getElementById('prev').addEventListener('click', () => focus(idx - 1));

document.addEventListener('keydown', e => {
  if (e.target.matches('input')) return;
  if (e.key === 'j' || e.key === 'ArrowRight') { focus(idx + 1); e.preventDefault(); }
  else if (e.key === 'k' || e.key === 'ArrowLeft') { focus(idx - 1); e.preventDefault(); }
  else if (e.key === 'f') { toggleFlicker(activeCard()); }
  else if (e.key === 'o' || e.key === 'Enter') { cycleOnion(activeCard()); e.preventDefault(); }
});

if (cards.length) focus(0);
]]

local function figure(caption, src)
  return string.format(
    '      <figure><figcaption>%s</figcaption><img src="%s" loading="lazy"></figure>\n',
    caption, src)
end

local function render_card(entry)
  local parts = { string.format('    <section class="card" tabindex="-1">\n') }
  local badge = ({ M = "m", A = "a", D = "d" })[entry.status]
  local label = ({ M = "modified", A = "added", D = "removed" })[entry.status]
  local meta = entry.meta or ""
  parts[#parts + 1] = string.format(
    '      <div class="hd"><span class="key">%s</span><span class="badge %s">%s</span>' ..
    '<span class="meta">%s</span></div>\n',
    html_escape(entry.key), badge, label, html_escape(meta))

  parts[#parts + 1] = '      <div class="cols">\n'
  if entry.base_rel then parts[#parts + 1] = figure("base", entry.base_rel) end
  if entry.head_rel then parts[#parts + 1] = figure("head", entry.head_rel) end
  if entry.diff_rel then parts[#parts + 1] = figure("overlay", entry.diff_rel) end
  if entry.side_rel then parts[#parts + 1] = figure("side by side", entry.side_rel) end
  parts[#parts + 1] = '      </div>\n'

  if entry.base_rel and entry.head_rel then
    parts[#parts + 1] = table.concat({
      '      <div class="overlay">\n',
      '        <div class="stack">\n',
      string.format('          <img class="ob" src="%s">\n', entry.base_over),
      string.format('          <img class="oh" src="%s">\n', entry.head_over),
      '        </div>\n',
      '        <div class="controls">\n',
      '          <input class="opa" type="range" min="0" max="100" value="50">\n',
      '          <button class="flick">flicker</button>\n',
      '        </div>\n',
      '      </div>\n',
    })
  end
  parts[#parts + 1] = '    </section>\n'
  return table.concat(parts)
end

local function render_report(summary, cards_html)
  return table.concat({
    "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n",
    '<meta name="viewport" content="width=device-width, initial-scale=1">\n',
    "<title>Snapshot diff</title>\n<style>\n", STYLE, "</style>\n</head>\n<body>\n",
    '<header class="bar">\n',
    '  <button id="prev">&larr; prev</button>\n',
    '  <span class="pos" id="pos">0 / 0</span>\n',
    '  <button id="next">next &rarr;</button>\n',
    string.format('  <span class="summary">%s</span>\n', html_escape(summary)),
    '  <span class="hint">j/k step &middot; f flicker &middot; o onion-skin</span>\n',
    "</header>\n<main>\n", cards_html, "</main>\n<script>\n", SCRIPT, "</script>\n",
    "</body>\n</html>\n",
  })
end

local function main()
  local opts = parse_args(arg or {})
  local out_dir = abs(opts.out)

  local base_commit = resolve_commit(opts.base)
  if not base_commit then die("base ref does not resolve: " .. opts.base) end

  local head_commit = opts.head and resolve_commit(opts.head) or "HEAD"
  if opts.head and not head_commit then die("head ref does not resolve: " .. opts.head) end

  local base_rev = base_commit
  if not opts.exact then
    local code, mb = git(string.format("merge-base %s %s",
      shell_quote(base_commit), shell_quote(head_commit)))
    if code == 0 and trim(mb) ~= "" then base_rev = trim(mb) end
  end

  local entries = changed_goldens(base_rev, opts.head)
  if opts.only then
    local filtered = {}
    for _, e in ipairs(entries) do
      if key_of(e.path):find(opts.only, 1, true) then filtered[#filtered + 1] = e end
    end
    entries = filtered
  end

  local base_label = subject(base_rev)
  local head_label = opts.head and subject(head_commit) or "working tree"

  if #entries == 0 then
    io.write(string.format("no snapshot changes between %s..%s\n", base_label, head_label))
    os.exit(0)
  end

  util.remove_dir(out_dir)
  util.make_dir(out_dir)

  local counts = { M = 0, A = 0, D = 0 }
  for _, e in ipairs(entries) do
    counts[e.status] = (counts[e.status] or 0) + 1
    e.key = key_of(e.path)
    local safe = e.key:gsub("/", "__")
    local img_dir = out_dir .. "/img/" .. safe
    util.make_dir(img_dir)

    if e.status ~= "A" then
      local base_png = img_dir .. "/base.png"
      if git_show_to(base_rev, e.path, base_png) and util.file_exists(base_png) then
        e.base_abs, e.base_rel = base_png, "img/" .. safe .. "/base.png"
      end
    end

    if e.status ~= "D" then
      local head_png = img_dir .. "/head.png"
      local ok
      if opts.head then
        ok = git_show_to(opts.head, e.path, head_png)
      else
        ok = util.copy_file(abs(e.path), head_png)
      end
      if ok and util.file_exists(head_png) then
        e.head_abs, e.head_rel = head_png, "img/" .. safe .. "/head.png"
      end
    end

    e.ae = -1
    if e.base_abs and e.head_abs then
      local bw, bh = dimensions(e.base_abs)
      local hw, hh = dimensions(e.head_abs)
      local base_cmp, head_cmp = e.base_abs, e.head_abs
      local size_note
      if bw and hw and (bw ~= hw or bh ~= hh) then
        local cw, ch = math.max(bw, hw), math.max(bh, hh)
        local bp, hp = img_dir .. "/base.pad.png", img_dir .. "/head.pad.png"
        pad_to(e.base_abs, bp, cw, ch)
        pad_to(e.head_abs, hp, cw, ch)
        base_cmp, head_cmp = bp, hp
        size_note = string.format("%dx%d -> %dx%d", bw, bh, hw, hh)
      end
      local diff_png = img_dir .. "/diff.png"
      local ae = overlay(base_cmp, head_cmp, diff_png, opts.fuzz)
      if ae and util.file_exists(diff_png) then
        e.ae, e.diff_rel = ae, "img/" .. safe .. "/diff.png"
      end
      local side_png = img_dir .. "/side.png"
      side_by_side(base_cmp, head_cmp, side_png)
      if util.file_exists(side_png) then e.side_rel = "img/" .. safe .. "/side.png" end

      e.base_over = e.base_rel
      e.head_over = e.head_rel
      if base_cmp ~= e.base_abs then
        e.base_over = "img/" .. safe .. "/base.pad.png"
        e.head_over = "img/" .. safe .. "/head.pad.png"
      end

      local meta = {}
      if e.ae >= 0 then
        local w, h = dimensions(base_cmp)
        local pct = (w and h and w * h > 0) and (e.ae / (w * h) * 100) or 0
        meta[#meta + 1] = string.format("AE=%d  %.3f%%", e.ae, pct)
      end
      if size_note then meta[#meta + 1] = "size " .. size_note end
      e.meta = table.concat(meta, "  \194\183  ")
    elseif e.status == "A" then
      e.meta = "new snapshot"
    elseif e.status == "D" then
      e.meta = "removed snapshot"
    end
  end

  -- Modified first, largest visual diff on top, then adds, then removes.
  local order = { M = 0, A = 1, D = 2 }
  table.sort(entries, function(a, b)
    if a.status ~= b.status then return order[a.status] < order[b.status] end
    if a.status == "M" then return a.ae > b.ae end
    return a.key < b.key
  end)

  local cards = {}
  for _, e in ipairs(entries) do cards[#cards + 1] = render_card(e) end

  local summary = string.format(
    "%d modified \194\183 %d added \194\183 %d removed   (%s -> %s)",
    counts.M, counts.A, counts.D, base_label, head_label)

  local index = out_dir .. "/index.html"
  util.write_file(index, render_report(summary, table.concat(cards)))

  io.write(summary .. "\n")
  io.write("report: " .. index .. "\n")

  if opts.open then
    local _, uname = util.popen_capture("uname")
    if trim(uname) == "Darwin" then
      os.execute(string.format("open %s", shell_quote(index)))
    else
      io.write("open it in a browser: " .. index .. "\n")
    end
  end
end

main()
