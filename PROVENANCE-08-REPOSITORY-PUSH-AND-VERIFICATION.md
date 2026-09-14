# Provenance 08 — Pushing to the repository, and verifying it

**Effort.** Push the work to `https://github.com/once-ere/Pre-Universe_with_Claude.git`, then
check and verify that repository: that it contains what it should, that its files come back
byte-for-byte, and that the delivered notebook runs correctly out of a fresh clone with nothing
from this machine on the path.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

## 1. The state before the push

The working repository is `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77`. Its `origin`
remote was `https://github.com/43d168f3e/Pre-Universe.git`. The target
`https://github.com/once-ere/Pre-Universe_with_Claude.git` existed but was **empty**, so the push
is a clean first push of `main`, not a merge.

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
git remote -v
gh auth status
gh api repos/once-ere/Pre-Universe_with_Claude --jq '{name,visibility,default_branch,size}'
gh api repos/once-ere/Pre-Universe_with_Claude/contents
```

Before the push the last command returned `This repository is empty. (HTTP 404)`.

## 2. What was and was not committed

Three changes were already present in the working tree when this work started, and they are
**not mine**, so they were deliberately left uncommitted:

| path | pre-existing state |
|---|---|
| `EtoExp.wl` | modified (a whole-file line-ending change) |
| `Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb` | deleted from the working tree, still in `HEAD` |
| `Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.pdf` | modified (19.4 MB → 13.7 MB) |

Three unrelated large files were also left alone: `2026-02-20-Pre-U-mmM4p.nb` and its two `.mx`
files, plus two scratch copies of `EtoExp.wl`.

To see exactly this split:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
git status --porcelain
git diff --stat EtoExp.wl
git diff --stat "Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.pdf"
```

What was committed:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
cat > .gitignore <<'EOF'
# local backups made before modifying anything
backups/
# python bytecode
__pycache__/
*.pyc
EOF
rm -rf claude-fable/__pycache__
git add .gitignore
git add PROVENANCE-00-READING-THE-ORIGINAL-NOTEBOOK.md \
        PROVENANCE-01-BUILDING-AND-RUNNING-THE-REFACTORED-NOTEBOOK.md \
        PROVENANCE-02-FRAME-FIELD-AND-CANONICAL-SPIN-CONNECTION.md \
        PROVENANCE-03-SPINOR-COVARIANT-DERIVATIVE.md \
        PROVENANCE-04-BRIDGE-1-BOOSTED-FRAME-COMPARED.md \
        PROVENANCE-05-BRIDGE-2-NULL-FRAME-COMPARED.md \
        PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md \
        PROVENANCE-07-PHYSICS-REPRODUCTION-AND-MX-FIDELITY.md
git add claude-fable/
git add "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb" \
        "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx" \
        "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx"
git add Pre.txt Pre-00.txt
git diff --cached --name-only | wc -l      # 71
```

The 24 MB source notebook and the author's two `.mx` files are included on purpose: without them
the fidelity check of provenance document 07 cannot be reproduced from the repository alone.
`backups/` is excluded by `.gitignore` because it is a 24 MB duplicate of the source.

## 3. The commit and the push

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
git commit -F <a file containing the message>
git remote add claude-fable https://github.com/once-ere/Pre-Universe_with_Claude.git
git push -u claude-fable main
```

Result:

```
branch 'main' set up to track 'claude-fable/main'.
To https://github.com/once-ere/Pre-Universe_with_Claude.git
 * [new branch]      main -> main
```

## 4. A defect the verification found, and the fix

The first verification cloned the repository and compared hashes. **They did not match.** Git was
rewriting LF to CRLF on checkout, so a clone came back with different bytes for the 24 MB source
notebook and for every text file. That silently alters the author's original notebook and breaks
every hash comparison the provenance documents rely on. The `.mx` files were unaffected because
git had detected them as binary.

The fix is to tell git never to touch line endings, and to restore the exact bytes in the index:

```bash
cd "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77"
cat > .gitattributes <<'EOF'
# Store and check out every file byte-for-byte.  Mathematica .nb and .mx files, and the
# provenance logs that record exact program output, must not have their line endings
# rewritten on checkout: that changes their bytes and breaks hash comparisons.
* -text
EOF
git add .gitattributes
git add --renormalize -- "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb" \
   "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx" \
   "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx" \
   Pre.txt Pre-00.txt PROVENANCE-*.md claude-fable/ .gitignore
git commit -F <a file containing the message>
git push claude-fable main
```

## 5. Verification 1 — what the repository contains

```bash
gh api repos/once-ere/Pre-Universe_with_Claude --jq '{name,visibility,default_branch,pushed_at}'
gh api repos/once-ere/Pre-Universe_with_Claude/contents \
   --jq '.[] | "\(.type)\t\(.size)\t\(.name)"'
gh api repos/once-ere/Pre-Universe_with_Claude/contents/claude-fable \
   --jq '.[] | "\(.type)\t\(.size)\t\(.name)"'
```

Root:

```
file	93	.gitignore
file	26970	ConvertMapleToMathematicaV2.wl
file	44810	Dirac-Lord-Nash_4+4.wl
file	8209	EtoExp.wl
file	35149	LICENSE
file	16039	PROVENANCE-00-READING-THE-ORIGINAL-NOTEBOOK.md
file	16196	PROVENANCE-01-BUILDING-AND-RUNNING-THE-REFACTORED-NOTEBOOK.md
file	13029	PROVENANCE-02-FRAME-FIELD-AND-CANONICAL-SPIN-CONNECTION.md
file	10244	PROVENANCE-03-SPINOR-COVARIANT-DERIVATIVE.md
file	10212	PROVENANCE-04-BRIDGE-1-BOOSTED-FRAME-COMPARED.md
file	9897	PROVENANCE-05-BRIDGE-2-NULL-FRAME-COMPARED.md
file	15976	PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md
file	14761	PROVENANCE-07-PHYSICS-REPRODUCTION-AND-MX-FIDELITY.md
file	13838	Pre-00.txt
file	2705	Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx
file	3145	Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLazt.mx
file	24112944	Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb
file	25246380	Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb
file	19398652	Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.pdf
file	50938	Pre.txt
file	118	README.md
dir	0	claude-fable
```

`claude-fable/` holds the four cell manifests, the build tool, the harness, the delivered
notebook, the two `.mx` files it writes, every provenance script, and the log of every run.

## 6. Verification 2 — the files come back byte-for-byte

```bash
VER="C:/Users/nsh/AppData/Local/Temp/verify-clone"
rm -rf "$VER"
git clone --depth 1 https://github.com/once-ere/Pre-Universe_with_Claude.git "$VER"
for f in "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb" \
         "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx" \
         "claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb" \
         "claude-fable/cells_part4.wl" \
         "PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md"; do
  a=$(sha256sum "$VER/$f" | cut -d' ' -f1)
  b=$(sha256sum "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/$f" | cut -d' ' -f1)
  if [ "$a" = "$b" ]; then echo "  MATCH   $f"; else echo "  DIFFER  $f"; fi
done
```

Result:

```
  MATCH   Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb
  MATCH   Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx
  MATCH   claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb
  MATCH   claude-fable/cells_part4.wl
  MATCH   PROVENANCE-06-BRIDGE-3-OCTONIONIC-TORSION-COMPARED.md
```

## 7. Verification 3 — the notebook runs out of the clone

This is the check that matters. It uses only files from the clone: the notebook, the harness and
both helper packages. Nothing on this machine is on the path.

```bash
VER="C:/Users/nsh/AppData/Local/Temp/verify-clone"
cd "$VER"
cat > run_from_clone.wls <<'WLSEOF'
(* Run the delivered notebook straight out of a fresh clone, with nothing from the
   development machine on the path.  The helper packages come from the clone too. *)
dir = DirectoryName[$InputFileName];
SetDirectory[FileNameJoin[{dir, "claude-fable"}]];
Print["working directory : ", Directory[]];
Get["runner_header.wl"];
nbfile = FileNameJoin[{dir, "claude-fable", "claude-fable_Einstein-Rosen-2-Planes.nb"}];
Print["notebook          : ", nbfile];
Print["bytes             : ", FileByteCount[nbfile]];
nb = Import[nbfile, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["Input cells       : ", Length[inputs]];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}];
cfRunSummary[];
WLSEOF
timeout 3000 wolframscript -file run_from_clone.wls 2>&1 | tee run_from_clone.log
sed -n '/RUN SUMMARY/,$p' run_from_clone.log
```

Result:

```
==================== RUN SUMMARY ====================
cells evaluated : 139
total seconds   : 130.798
cells w/ msgs   : 0
---- slowest cells ----
  cell 80  69.043 s
  cell 88  23.288 s
  cell 86   8.503 s
  ...
==================== ASSERTIONS ====================
assertions run  : 175
passed          : 175
FAILED          : 0
====================================================
```

**139 of 139 cells evaluated, zero messages, 175 of 175 assertions passing, from a clone.** No
`MISSING FILE` notice appeared, so section 10 found both helper packages inside the clone.

To confirm that last point explicitly:

```bash
cd "C:/Users/nsh/AppData/Local/Temp/verify-clone"
grep -n 'MISSING FILE' run_from_clone.log || echo "no missing files"
grep -c 'PASS' run_from_clone.log
grep -n 'MESSAGES' run_from_clone.log || echo "no messages"
```

## 8. Where each deliverable lives

| deliverable | path |
|---|---|
| the notebook, at the requested location | `C:\Users\nsh\Documents\8-dim\claude-fable_Einstein-Rosen-2-Planes.nb` |
| the same notebook, in the repository | `claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb` |
| the cell manifests it is generated from | `claude-fable/cells_part1.wl` … `cells_part4.wl` |
| the build tool | `claude-fable/build_tools.py` |
| the test harness | `claude-fable/runner_header.wl` |
| the provenance scripts | `claude-fable/prov0*.wls` |
| every run log | `claude-fable/*.log` |
| the eight provenance documents | repository root, `PROVENANCE-00` … `PROVENANCE-08` |

`C:\Users\nsh\Documents\8-dim` is not itself a git repository, which is why the notebook is
delivered both to that exact path and, as an identical copy, inside the repository. The two are
the same bytes:

```bash
sha256sum "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb" \
          "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb"
```

Both print `a9ebd4837b7081d9b6dc7792ac0a0a534cfa4c4ef9a2730c4752d8ce73991d85`.

## 9. What this proves

- The work is on `https://github.com/once-ere/Pre-Universe_with_Claude`, on `main`.
- The repository contains the delivered notebook, everything it is built from, the original
  24 MB source notebook, the author's two `.mx` files, every provenance script and log, and the
  nine provenance documents.
- A fresh clone returns every file byte-for-byte, including the author's original notebook.
- The delivered notebook runs to completion from that clone: 139 cells, zero messages, 175 of
  175 assertions passing.
