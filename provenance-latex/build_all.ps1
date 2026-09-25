# provenance-latex/build_all.ps1 -- compile the LaTeX twins of provenance pages 14, 15 and 16 to PDF.
# Run it from anywhere:   powershell -ExecutionPolicy Bypass -File provenance-latex\build_all.ps1
# MiKTeX's latexmk needs Perl on the PATH; Git for Windows ships one:
#     $env:PATH += ";C:\Program Files\Git\usr\bin"
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$docs = @(
  "PROVENANCE-14-FERMION-FABLE-CANONICAL-QUANTIZATION",
  "PROVENANCE-15-FERMION-FABLE-AND-THE-PRIMORDIAL-GRAVITATIONAL-FIELD",
  "PROVENANCE-16-THE-COMPLETE-SOLUTION-AND-ITS-COMMANDS"
)
foreach ($doc in $docs) {
  Write-Host "== $doc"
  latexmk -pdf -interaction=nonstopmode -halt-on-error "$doc.tex" *> "$doc.latexmk.log"
  # $ErrorActionPreference does not stop on a failing native command, so check its exit code
  if ($LASTEXITCODE -ne 0) { throw "latexmk failed for $doc; see provenance-latex\$doc.latexmk.log and $doc.log" }
  if (Select-String -Path "$doc.log" -Pattern "undefined|Rerun to get" -Quiet) { Write-Warning "undefined references in $doc.log" }
  Get-Item "$doc.pdf" | Select-Object Name, Length
}
Write-Host "== all three PDFs built"
