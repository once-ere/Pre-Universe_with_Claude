# fable-cosmology/run_all.ps1 -- reproduce everything from a fresh clone, after setup.ps1:
#   1. the solver's own tests;  2. every notebook, executed headlessly in order;
#   3. the eight-requirement check;  4. the paper, compiled to PDF with latexmk (MiKTeX).
# Run it from anywhere:   powershell -ExecutionPolicy Bypass -File fable-cosmology\run_all.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$py = ".venv\Scripts\python.exe"

Write-Host "== 1. solver tests"
Push-Location rust\fable_cosmo; cargo test --release
# $ErrorActionPreference does not stop on a failing native command, so check its exit code
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "cargo test failed" }
Pop-Location

Write-Host "== 2. notebooks"
New-Item -ItemType Directory -Force results | Out-Null
Get-ChildItem notebooks\0*.ipynb | Sort-Object Name | ForEach-Object {
  Write-Host ("   executing " + $_.Name)
  & $py -m nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 `
        --ExecutePreprocessor.kernel_name=python3 $_.FullName
  if ($LASTEXITCODE -ne 0) { throw "notebook failed: $($_.Name)" }
}

Write-Host "== 3. notebook requirements"
& $py notebooks\_build\nbcheck.py
if ($LASTEXITCODE -ne 0) { throw "nbcheck failed" }

Write-Host "== 4. the paper"
Push-Location latex
latexmk -pdf -interaction=nonstopmode -halt-on-error fable_cosmology.tex *> latexmk.log
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "latexmk failed; see latex\latexmk.log" }
Get-Item fable_cosmology.pdf | Select-Object Name, Length
Pop-Location
Write-Host "== all done"
