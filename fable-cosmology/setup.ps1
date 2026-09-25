# fable-cosmology/setup.ps1 -- one-time setup, Windows 11 (PowerShell 7 or Windows PowerShell).
#
#   1. a Python virtual environment (.venv) with numpy, scipy, matplotlib, jupyter;
#   2. a sparse clone of rustSolveIt_Win11_SUNDIALS_7_8_0 into rust\vendor\rustSolveIt, restricted
#      to its vendored pure-Rust SUNDIALS 7.8.0 (sundials_rs), which the solver crate depends on
#      by path exactly as rustSolveIt's own planet_Mercury\mercury_rs does;
#   3. release builds of the two solver crates, rust\fable_cosmo (the classical fields) and
#      rust\fable_fermion (the quantized fermion fable), and a smoke test of each (--version).
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

# ---------------------------------------------------------------- 3. the solvers
foreach ($crate in @("fable_cosmo", "fable_fermion")) {
  Write-Host "== building rust\$crate (release)"
  Push-Location "rust\$crate"
  cargo build --release
  # $ErrorActionPreference does not stop on a failing native command, so check its exit code
  if ($LASTEXITCODE -ne 0) { Pop-Location; throw "cargo build failed for rust\$crate" }
  Pop-Location
  & "rust\$crate\target\release\$crate.exe" --version
  if ($LASTEXITCODE -ne 0) { throw "rust\$crate\target\release\$crate.exe --version failed" }
}
Write-Host "== setup complete"
