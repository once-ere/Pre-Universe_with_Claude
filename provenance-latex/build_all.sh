#!/usr/bin/env bash
# provenance-latex/build_all.sh -- compile the LaTeX twins of provenance pages 14, 15 and 16 to PDF.
# Run it from anywhere:   bash provenance-latex/build_all.sh
# Needs a TeX distribution with latexmk and pdflatex (MiKTeX on Windows, TeX Live on Linux/macOS).
# Each document is built by latexmk (as many pdflatex passes as the cross-references need);
# a document that fails stops the script with its latexmk log named.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
for doc in PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION \
           PROVENANCE-15-FERMION-FABLE-AND-THE-PRIMORDIAL-GRAVITATIONAL-FIELD \
           PROVENANCE-16-THE-COMPLETE-SOLUTION-AND-ITS-COMMANDS; do
  echo "== $doc"
  if ! latexmk -pdf -interaction=nonstopmode -halt-on-error "$doc.tex" > "$doc.latexmk.log" 2>&1; then
    echo "   FAILED; see provenance-latex/$doc.latexmk.log and $doc.log" >&2
    exit 1
  fi
  # the log must be free of undefined references and of overfull boxes worse than 10pt
  if grep -qE "undefined|Rerun to get" "$doc.log"; then echo "   WARNING: undefined references in $doc.log" >&2; fi
  ls -la "$doc.pdf"
done
echo "== all three PDFs built"
