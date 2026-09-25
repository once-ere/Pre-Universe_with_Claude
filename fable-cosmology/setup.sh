#!/usr/bin/env bash
# fable-cosmology/setup.sh -- one-time setup, Linux / macOS / Git Bash on Windows.
#
#   1. a Python virtual environment (.venv) with numpy, scipy, matplotlib, jupyter;
#   2. a sparse clone of the rustSolveIt repository FOR THIS PLATFORM into rust/vendor/rustSolveIt,
#      restricted to its vendored pure-Rust SUNDIALS 7.8.0 (sundials_rs), which both solver crates
#      depend on by path exactly as rustSolveIt's own planet_Mercury/mercury_rs does;
#   3. release builds of the two solver crates, rust/fable_cosmo (the classical fields) and
#      rust/fable_fermion (the quantized fermion fable), and a smoke test of each (--version).
#
# Run it from anywhere:   bash fable-cosmology/setup.sh
# It is idempotent: re-running it updates nothing that is already in place.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

# ---------------------------------------------------------------- 1. Python
if [ ! -x .venv/bin/python ] && [ ! -x .venv/Scripts/python.exe ]; then
  # many macOS and Linux systems have python3 but no python; Git Bash on Windows usually has python
  if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then SYSPY=python3; else SYSPY=python; fi
  echo "== creating .venv with $SYSPY"
  "$SYSPY" -m venv .venv
fi
if [ -x .venv/Scripts/python.exe ]; then PY=.venv/Scripts/python.exe; else PY=.venv/bin/python; fi
echo "== installing Python requirements into .venv"
"$PY" -m pip install --quiet --upgrade pip
"$PY" -m pip install --quiet -r requirements.txt
"$PY" -c "import numpy, scipy, matplotlib, nbconvert, nbclient, ipykernel; print('python ok:', 'numpy', numpy.__version__, 'scipy', scipy.__version__, 'matplotlib', matplotlib.__version__)"

# ---------------------------------------------------------------- 2. the engine, for this platform
case "$(uname -s)" in
  Linux*)                    REPO=https://github.com/once-ere/rustSolveIt_linux_SUNDIALS_7_8_0.git ;;
  Darwin*)                   REPO=https://github.com/once-ere/rustSolveIt_macos-silicon_SUNDIALS_7_8_0.git ;;
  MINGW*|MSYS*|CYGWIN*)      REPO=https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git ;;
  *) echo "unknown platform $(uname -s); clone one of the three rustSolveIt repositories into rust/vendor/rustSolveIt by hand" >&2; exit 1 ;;
esac
mkdir -p rust/vendor
if [ ! -d rust/vendor/rustSolveIt/sundials_rs/crates/cvode_rs ]; then
  echo "== cloning the engine (sparse: sundials_rs only) from $REPO"
  rm -rf rust/vendor/rustSolveIt
  git clone --depth 1 --filter=blob:none --sparse "$REPO" rust/vendor/rustSolveIt
  ( cd rust/vendor/rustSolveIt && git sparse-checkout set sundials_rs )
fi
echo "== engine: $(cd rust/vendor/rustSolveIt && git remote get-url origin) @ $(cd rust/vendor/rustSolveIt && git rev-parse --short HEAD)"

# ---------------------------------------------------------------- 3. the solvers
for CRATE in fable_cosmo fable_fermion; do
  echo "== building rust/$CRATE (release)"
  ( cd "rust/$CRATE" && cargo build --release )
  if [ -x "rust/$CRATE/target/release/$CRATE.exe" ]; then BIN="rust/$CRATE/target/release/$CRATE.exe"; else BIN="rust/$CRATE/target/release/$CRATE"; fi
  "$BIN" --version
done
echo "== setup complete"
