# fable-cosmology/setup.ps1 -- one-time setup, Windows 11 (PowerShell 7 or Windows PowerShell).
#
#   1. a Python virtual environment (.venv) with numpy, scipy, matplotlib, jupyter;
#   2. a sparse clone of rustSolveIt_Win11_SUNDIALS_7_8_0 into rust\vendor\rustSolveIt, restricted
#      to its vendored pure-Rust SUNDIALS 7.8.0 (sundials_rs), which the solver crate depends on
#      by path exactly as rustSolveIt's own planet_Mercury\mercury_rs does;
#   3. a release build of the solver crate rust\fable_cosmo, and a smoke test of it.
#
# Run it from anywhere:   powershell -ExecutionPolicy Bypass -File fable-cosmology\setup.ps1
# It is idempotent.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# ---------------------------------------------------------------- 1. Python
if (-not (Test-Path ".venv\Scripts\python.exe")) {
  Write-Host "== creating .venv"
  python -m venv .venv
}
$py = ".venv\Scripts\python.exe"
Write-Host "== installing Python requirements into .venv"
& $py -m pip install --quiet --upgrade pip
& $py -m pip install --quiet -r requirements.txt
& $py -c "import numpy, scipy, matplotlib, nbconvert, nbclient, ipykernel; print('python ok:', 'numpy', numpy.__version__, 'scipy', scipy.__version__, 'matplotlib', matplotlib.__version__)"

# ---------------------------------------------------------------- 2. the engine, Windows edition
$repo = "https://github.com/once-ere/rustSolveIt_Win11_SUNDIALS_7_8_0.git"
New-Item -ItemType Directory -Force rust\vendor | Out-Null
if (-not (Test-Path "rust\vendor\rustSolveIt\sundials_rs\crates\cvode_rs")) {
  Write-Host "== cloning the engine (sparse: sundials_rs only) from $repo"
  if (Test-Path "rust\vendor\rustSolveIt") { Remove-Item -Recurse -Force "rust\vendor\rustSolveIt" }
  git clone --depth 1 --filter=blob:none --sparse $repo rust\vendor\rustSolveIt
  Push-Location rust\vendor\rustSolveIt
  git sparse-checkout set sundials_rs
  Pop-Location
}
Push-Location rust\vendor\rustSolveIt
Write-Host ("== engine: " + (git remote get-url origin) + " @ " + (git rev-parse --short HEAD))
Pop-Location

# ---------------------------------------------------------------- 3. the solver
Write-Host "== building rust\fable_cosmo (release)"
Push-Location rust\fable_cosmo
cargo build --release
Pop-Location
& rust\fable_cosmo\target\release\fable_cosmo.exe --version
Write-Host "== setup complete"
