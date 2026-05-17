// Position adjustment dispatcher. Sits between stat and render in
// `_prepare-layer`.

#import "identity.typ" as identity-pos
#import "stack.typ" as stack-pos
#import "dodge.typ" as dodge-pos
#import "fill.typ" as fill-pos
#import "jitter.typ" as jitter-pos
#import "jitterdodge.typ" as jitterdodge-pos
#import "nudge.typ" as nudge-pos

#let _POSITIONS = (
  identity: identity-pos.apply,
  stack: stack-pos.apply,
  dodge: dodge-pos.apply,
  fill: fill-pos.apply,
  jitter: jitter-pos.apply,
  jitterdodge: jitterdodge-pos.apply,
  nudge: nudge-pos.apply,
)

#let apply-position(name, data, mapping, params: (:)) = {
  let resolved = if name == none { "identity" } else { name }
  let apply = _POSITIONS.at(resolved, default: none)
  if apply == none {
    panic("position: unknown adjustment \"" + str(resolved) + "\"")
  }
  apply(data, mapping, params: params)
}
