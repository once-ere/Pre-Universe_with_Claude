#!/usr/bin/env bash
# fable-cosmology/run_all.sh -- reproduce everything from a fresh clone, after setup.sh:
#   1. the tests of both solvers (rust/fable_cosmo, rust/fable_fermion);
#   2. every notebook (01-07), executed headlessly in order (outputs written back into the .ipynb);
#   3. the eight-requirement check of every notebook;
#   4. the paper, compiled to PDF with latexmk (MiKTeX / TeX Live).
# Run it from anywhere:   bash fable-cosmology/run_all.sh
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
if [ -x .venv/Scripts/python.exe ]; then PY=.venv/Scripts/python.exe; else PY=.venv/bin/python; fi

echo "== 1. solver tests"
echo "   rust/fable_cosmo"
( cd rust/fable_cosmo && cargo test --release 2>&1 | tail -n 3 )
echo "   rust/fable_fermion"
( cd rust/fable_fermion && cargo test --release 2>&1 | grep -E "^running|^test result|FAILED|panicked" )

echo "== 2. notebooks"
mkdir -p results
for nb in notebooks/0*.ipynb; do
  echo "   executing $nb"
  "$PY" -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 \
        --ExecutePreprocessor.kernel_name=python3 "$nb"
done

echo "== 3. notebook requirements"
"$PY" notebooks/_build/nbcheck.py

echo "== 4. the paper"
( cd latex && latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex > latexmk.log 2>&1 && ls -la fable_cosmology.pdf )
echo "== all done"
