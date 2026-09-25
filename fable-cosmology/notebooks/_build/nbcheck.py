#!/usr/bin/env python3
"""Check every notebook of fable-cosmology against eight stated requirements.

Adapted from rustSolveIt's notebooks/_build/nbcheck.py (the eight requirements every one of
its 128 notebooks meets).  R1-R5 and R7 are kept as they are; R6 names the sections a physics
notebook must have here; R8 -- rustSolveIt's SQLite dataset -- is replaced by the requirement
that the notebook owns its result files (CSV and PNG under results/) and reads one of them back
with plain Python, independently of the solver.

The notebooks run one of two solvers, recorded in the notebook metadata:
  metadata.fable_cosmo.model    notebooks 01-04, rust/fable_cosmo (the classical fields);
  metadata.fable_fermion.model  notebooks 05-07, rust/fable_fermion (the quantized fermion fable);
                                notebook 07 also names the model "waveguide": the wall-state solver
                                fermion/waveguide.py, which R1 then requires it to name, and its
                                glossary must also explain the words of the wall list.

  R1  it explains how to launch a notebook from a terminal CLI (and how to rebuild its own solver)
  R2  it never sends the reader to another notebook
  R3  every code cell is preceded by explanatory markdown
  R4  it asks the user to name the notebook
  R5  it opens a graphical save dialog, with a fallback
  R6  it describes the field, its Lagrangian and energy-momentum tensor, the equations of
      motion, and the first-order system actually handed to SUNDIALS; its glossary explains
      every word of the common list (and, for the fermion notebooks, of the fermion list; for
      the wall-state notebook, of the wall list)
  R7  it is valid nbformat-4 JSON, every non-interactive code cell was executed, and it
      pairs with the solver model(s) it runs (exactly one solver key in its metadata)
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

# solver key in metadata -> (the models it may name, the crate directory named in section 1)
SOLVERS = {
    "fable_cosmo": ({"scalar-flrw", "scalar-cpl", "spinor-flrw", "scalar-pre", "scalar-pre-x0"}, "rust/fable_cosmo"),
    "fable_fermion": ({"fable4d", "fable8d", "gap", "waveguide"}, "rust/fable_fermion"),
}
# a model that is a second program, not a mode of the crate: the file R1 requires the notebook to name
MODEL_FILES = {"waveguide": "fermion/waveguide.py"}

HEADINGS = ["## 1. How to open a notebook like this one, from a terminal",
            "## 2. The words used in this notebook",
            "## 3. The field, its Lagrangian and its energy-momentum tensor",
            "## 4. The equations of motion",
            "### 4.1 The first-order system actually handed to SUNDIALS",
            "## 5. Running the solver",
            "## 6. This notebook's results"]

# glossary words (any one spelling of each entry must occur in the section-2 cell, case-insensitive)
GLOSSARY_COMMON = [("field",), ("Lagrangian",), ("energy-momentum tensor",), ("energy density",), ("pressure",),
                   ("equation of state",), ("scale factor",), ("redshift",), ("N = ln a",), ("Hubble rate",),
                   ("Omega_i", "Ω_i"), ("CPL",), ("thawing",), ("freezing",), ("phantom",), ("dust",),
                   ("cosmological constant",), ("kination",), ("SUNDIALS",), ("CVODE",), ("BDF",), ("Adams",),
                   ("tolerance",)]
GLOSSARY_FERMION = [("complex 16-spinor",), ("Grassmann",), ("Dirac conjugate",), ("anticommutator",), ("Krein space",),
                    ("fundamental symmetry J",), ("Fock space",), ("Dirac sea",), ("Kohn-Sham", "Kohn–Sham"),
                    ("gap equation",), ("Fermi momentum",), ("degenerate gas",), ("ΔN_eff", "Delta N_eff"),
                    ("stabilizing stress",), ("null energy condition",), ("Bianchi-I",), ("hidden sheet",),
                    ("Newton constant variation",)]
GLOSSARY_WALL = [("Hohenberg-Kohn", "Hohenberg–Kohn"), ("Kohn-Sham reference system", "Kohn–Sham reference system"),
                 ("exchange-correlation", "exchange–correlation"), ("local-density approximation",),
                 ("self-consistent field",), ("Delta-SCF", "ΔSCF"), ("Walecka functional",), ("minimax",),
                 ("particle-hole", "particle–hole"), ("pair continuum",), ("wall",), ("proper distance",),
                 ("transverse momentum",), ("self-adjoint extension",), ("MIT condition",), ("irrep",),
                 ("Prüfer angle", "Prufer angle"), ("threshold",), ("edge state",), ("band",),
                 ("surface density",), ("Fermi level",)]


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
    meta = nb.get("metadata", {})
    solver_keys = [k for k in SOLVERS if k in meta]

    # R1
    for needle in ["jupyter lab", "Python 3 (ipykernel)", "cargo build --release", "Shift+Enter",
                   "setup.sh", "setup.ps1"]:
        if needle not in text:
            bad.append(f"R1 launch instructions missing {needle!r}")
    models = set()
    for key in solver_keys:
        if SOLVERS[key][1] not in text:
            bad.append(f"R1 the solver's crate {SOLVERS[key][1]!r} is never named")
        model = meta[key].get("model") or []
        models |= set([model] if isinstance(model, str) else model)
    for mdl, fname in MODEL_FILES.items():
        if mdl in models and fname not in text:
            bad.append(f"R1 the program {fname!r} of model {mdl!r} is never named")
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
    for heading in HEADINGS:
        if heading not in mdtext:
            bad.append(f"R6 missing section {heading!r}")
    glossary = next(("".join(c["source"]) for c in cells if c["cell_type"] == "markdown"
                     and "".join(c["source"]).lstrip().startswith("## 2. The words used in this notebook")), "")
    words = GLOSSARY_COMMON + (GLOSSARY_FERMION if "fable_fermion" in solver_keys else [])         + (GLOSSARY_WALL if "waveguide" in models else [])
    for spellings in words:
        if not any(sp.lower() in glossary.lower() for sp in spellings):
            bad.append(f"R6 the glossary does not explain {spellings[0]!r}")
    # R7
    if len(solver_keys) != 1:
        bad.append(f"R7 the metadata must name exactly one solver ({' or '.join(f'metadata.{k}.model' for k in SOLVERS)}), found {solver_keys}")
    for key in solver_keys:
        model = meta[key].get("model")
        if not model:
            bad.append(f"R7 no solver model recorded in metadata.{key}.model")
            continue
        for mdl in ([model] if isinstance(model, str) else model):
            if mdl not in SOLVERS[key][0]:
                bad.append(f"R7 unknown {key} model {mdl!r}")
    for i, c in enumerate(cells):
        if c["cell_type"] == "code" and "interactive" not in c.get("metadata", {}).get("tags", []):
            if c.get("execution_count") is None:
                bad.append(f"R7 code cell {i} was never executed")
            for o in c.get("outputs", []):
                if o.get("output_type") == "error":
                    bad.append(f"R7 code cell {i} raised {o.get('ename')}")
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
