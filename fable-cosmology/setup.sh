#!/usr/bin/env bash
# fable-cosmology/setup.sh -- one-time setup, Linux / macOS / Git Bash on Windows.
#
#   1. a Python virtual environment (.venv) with numpy, scipy, matplotlib, jupyter;
#   2. a sparse clone of the rustSolveIt repository FOR THIS PLATFORM into rust/vendor/rustSolveIt,
#      restricted to its vendored pure-Rust SUNDIALS 7.8.0 (sundials_rs), which the solver crate
#      depends on by path exactly as rustSolveIt's own planet_Mercury/mercury_rs does;
#   3. a release build of the solver crate rust/fable_cosmo, and a smoke test of it.
#
# Run it from anywhere:   bash fable-cosmology/setup.sh
# It is idempotent: re-running it updates nothing that is already in place.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

# ---------------------------------------------------------------- 1. Python
if [ ! -x .venv/bin/python ] && [ ! -x .venv/Scripts/python.exe ]; then
  echo "== creating .venv"
  python -m venv .venv
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

# ---------------------------------------------------------------- 3. the solver
echo "== building rust/fable_cosmo (release)"
( cd rust/fable_cosmo && cargo build --release )
if [ -x rust/fable_cosmo/target/release/fable_cosmo.exe ]; then BIN=rust/fable_cosmo/target/release/fable_cosmo.exe; else BIN=rust/fable_cosmo/target/release/fable_cosmo; fi
"$BIN" --version
echo "== setup complete"
