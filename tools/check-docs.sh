#!/usr/bin/env bash
# Lints Typst docstrings for typstdoc YAML compatibility.
#
# typstdoc emits the first paragraph of every `#let` docstring as the
# `subtitle:` field of the generated reference qmd. YAML cannot parse an
# unquoted multi-line value followed by another mapping key, so a docstring
# whose first paragraph spans more than one `///` line silently breaks
# `quarto render`. This linter catches that before commit.
#
# A "first paragraph" is the run of `///` lines preceding a `#let`, stopping
# at the first blank `///` line or the first `/// @tag` line.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

while IFS= read -r -d '' file; do
  awk -v file="${file}" '
    BEGIN { doc_start = 0; doc_count = 0 }

    /^\/\/\// {
      # New docstring block? Reset on the first /// after a non-/// line.
      if (prev_was_doc != 1) { doc_start = NR; doc_count = 0; in_para = 1 }
      line = $0
      sub(/^\/\/\/[ ]?/, "", line)
      # Blank /// line ends the first paragraph.
      if (line == "") { in_para = 0 }
      # @tag line ends the first paragraph too.
      else if (line ~ /^@/) { in_para = 0 }
      else if (in_para) { doc_count++ }
      prev_was_doc = 1
      next
    }

    /^#let / {
      if (prev_was_doc == 1 && doc_count > 1) {
        printf("%s:%d: docstring first paragraph spans %d lines (will break typstdoc YAML)\n", file, doc_start, doc_count) > "/dev/stderr"
        failures++
      }
      prev_was_doc = 0
      doc_count = 0
      next
    }

    {
      prev_was_doc = 0
    }

    END {
      if (failures > 0) { exit 1 }
    }
  ' "${file}" || failures=$((failures + 1))
done < <(find "${REPO_ROOT}/src" -type f -name '*.typ' -print0)

if [[ ${failures} -gt 0 ]]; then
  printf '\n%d file(s) with docstring lint errors.\n' "${failures}" >&2
  exit 1
fi

printf 'Docstring lint: ok.\n'
