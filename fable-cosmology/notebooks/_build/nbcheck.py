#!/usr/bin/env python3
"""Check every notebook of fable-cosmology against eight stated requirements.

Adapted from rustSolveIt's notebooks/_build/nbcheck.py (the eight requirements every one of
its 128 notebooks meets).  R1-R5 and R7 are kept as they are; R6 names the sections a physics
notebook must have here; R8 -- rustSolveIt's SQLite dataset -- is replaced by the requirement
that the notebook owns its result files (CSV and PNG under results/) and reads one of them back
with plain Python, independently of the solver.

  R1  it explains how to launch a notebook from a terminal CLI
  R2  it never sends the reader to another notebook
  R3  every code cell is preceded by explanatory markdown
  R4  it asks the user to name the notebook
  R5  it opens a graphical save dialog, with a fallback
  R6  it describes the field, its Lagrangian and energy-momentum tensor, the equations of
      motion, and the first-order system actually handed to SUNDIALS
  R7  it is valid nbformat-4 JSON, every non-interactive code cell was executed, and it
      pairs with the solver model it runs
  R8  it owns its results: a results section naming files under results/, and a plain-Python
      read-back cell (csv module) independent of the solver
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]   # fable-cosmology/

CROSSREF = re.compile(
    r"(see|refer to|as (?:explained|described|shown|covered) in|documented in)\s+"
    r"(the\s+)?(other|another|previous|next|companion|first|earlier|following)?\s*"
    r"notebook", re.I)

MODELS = {"scalar-flrw", "scalar-cpl", "spinor-flrw", "scalar-pre", "scalar-pre-x0"}

def check(path):
    bad = []
    try:
        nb = json.loads(Path(path).read_text(encoding="utf-8"))
    except Exception as exc:
        return [f"R7 not valid JSON: {exc}"]
    if nb.get("nbformat") != 4:
        bad.append("R7 nbformat is not 4")
    cells = nb["cells"]
    text = "\n".join("".join(c["source"]) for c in cells)
    mdtext = "\n".join("".join(c["source"]) for c in cells if c["cell_type"] == "markdown")

    # R1
    for needle in ["jupyter lab", "Python 3 (ipykernel)", "cargo build --release", "Shift+Enter",
                   "setup.sh", "setup.ps1"]:
        if needle not in text:
            bad.append(f"R1 launch instructions missing {needle!r}")
    # R2
    m = CROSSREF.search(mdtext)
    if m:
        bad.append(f"R2 sends the reader elsewhere: {m.group(0)!r}")
    for m in re.finditer(r"[\w./-]+\.ipynb", mdtext):
        if Path(m.group(0)).name != Path(path).name:
            bad.append(f"R2 markdown names another notebook file: {m.group(0)!r}")
    # R3
    for i, c in enumerate(cells):
        if c["cell_type"] == "code":
            if i == 0 or cells[i - 1]["cell_type"] != "markdown":
                bad.append(f"R3 code cell {i} has no explanation before it")
            elif len("".join(cells[i - 1]["source"]).strip()) < 80:
                bad.append(f"R3 explanation before code cell {i} is too thin")
    # R4 / R5
    if "Name for this notebook" not in text:
        bad.append("R4 does not ask the user to name the notebook")
    for needle in ["tkinter", "asksaveasfilename", "Falling back to a typed folder path"]:
        if needle not in text:
            bad.append(f"R5 save dialog missing {needle!r}")
    # R6
    for heading in ["## 1. How to open a notebook like this one, from a terminal",
                    "## 2. The words used in this notebook",
                    "## 3. The field, its Lagrangian and its energy-momentum tensor",
                    "## 4. The equations of motion",
                    "### 4.1 The first-order system actually handed to SUNDIALS",
                    "## 5. Running the solver",
                    "## 6. This notebook's results"]:
        if heading not in mdtext:
            bad.append(f"R6 missing section {heading!r}")
    # R7
    model = nb.get("metadata", {}).get("fable_cosmo", {}).get("model")
    if not model:
        bad.append("R7 no solver model recorded in metadata.fable_cosmo.model")
    else:
        for mdl in ([model] if isinstance(model, str) else model):
            if mdl not in MODELS:
                bad.append(f"R7 unknown solver model {mdl!r}")
    for i, c in enumerate(cells):
        if c["cell_type"] == "code" and "interactive" not in c.get("metadata", {}).get("tags", []):
            if c.get("execution_count") is None:
                bad.append(f"R7 code cell {i} was never executed")
    # R8
    if "import csv" not in text:
        bad.append("R8 no plain-Python csv read-back cell")
    if "results/" not in mdtext:
        bad.append("R8 the results' file path is never named")
    return bad

if __name__ == "__main__":
    paths = sys.argv[1:] or sorted(str(p) for p in (ROOT / "notebooks").glob("*.ipynb"))
    failed = 0
    for p in paths:
        problems = check(p)
        if problems:
            failed += 1
            print(f"FAIL {p}")
            for q in problems:
                print(f"       {q}")
    print(f"\n{len(paths) - failed}/{len(paths)} notebooks pass all eight requirements")
    sys.exit(1 if failed else 0)
