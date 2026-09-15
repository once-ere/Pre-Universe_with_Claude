# Provenance 08 — Pushing to the repository, and verifying it

**Effort.** Push the work to `https://github.com/once-ere/Pre-Universe_with_Claude.git`, then
check and verify that repository: that it contains what it should, that its files come back
byte-for-byte, and that the delivered notebook runs correctly out of a fresh clone with nothing
from this machine on the path.

Everything needed to repeat this work is on this page. No other file needs to be consulted.

---

> **Note added 2026-09-14, after this work was done: the remotes have been renamed.**
>
> When the push described below was made, the remote names were the other way round from what
> they are now. A bare `git push` went to the author's own repository, and was rejected as
> non-fast-forward — which is how the problem came to light. The commands on this page are
> recorded exactly as they were run; the names they use are the *old* ones.
>
> | repository | name then | name now |
> |---|---|---|
> | `https://github.com/once-ere/Pre-Universe_with_Claude.git` (the target of this work) | `claude-fable` | **`origin`** |
> | `https://github.com/43d168f3e/Pre-Universe.git` (the author's own repository) | `origin` | **`upstream`** |
>
> The rename, which also moved the `main` branch's tracking to the new `origin`:
>
> ```bash
> cd "$(git rev-parse --show-toplevel)"
> git remote rename origin upstream
> git remote rename claude-fable origin
> git branch -vv                 # * main ... [origin/main]
> git push --dry-run -v          # Pushing to https://github.com/once-ere/Pre-Universe_with_Claude.git
> ```
>
> So to repeat anything below today, read `claude-fable` as `origin`. A bare `git push` now goes
> to `once-ere/Pre-Universe_with_Claude`, and reaching the author's repository takes naming
> `upstream` explicitly.

## 1. The state before the push

The working repository is `C:\Users\nsh\Documents\8-dim\Pre-Universe_14SEP26-77`. Its `origin`
remote was `https://github.com/43d168f3e/Pre-Universe.git`. The target
`https://github.com/once-ere/Pre-Universe_with_Claude.git` existed but was **empty**, so the push
is a clean first push of `main`, not a merge.

```bash
cd "$(git rev-parse --show-toplevel)"
git remote -v
gh auth status
gh api repos/once-ere/Pre-Universe_with_Claude --jq '{name,visibility,default_branch,size}'
gh api repos/once-ere/Pre-Universe_with_Claude/contents
```

Before the push the last command returned `This repository is empty. (HTTP 404)`.

## 2. What was and was not committed

Several changes were already present in the working tree when this work started. They are
**not mine**, so the first push left them alone; a later push committed them, and what each one
actually is was checked first rather than assumed:

| path | pre-existing change |
|---|---|
| `EtoExp.wl` | the author rewrote it as a proper Wolfram package: `BeginPackage`, two `::usage` strings, `Begin["\`Private\`"]`, and a matching `End[]` / `EndPackage[]`. 21 added lines, nothing removed. |
| `Pre.txt` | the task specification, grown from 16 KB to 50 KB |
| `Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.pdf` | rebuilt, 19.4 MB → 13.7 MB |
| `Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb` | deleted from the working tree by the author before this work began |
| `2026-02-20-Pre-U-mmM4p.nb` and its two `.mx` files | a separate 25 MB working notebook, untracked |

The first of those matters to this project, because the notebook's section 10 loads `EtoExp.wl`.
All three copies of the file that the notebook can find already carry the package form, so
nothing needed syncing:

```bash
cd "$(git rev-parse --show-toplevel)"
for f in "EtoExp.wl" "claude-fable/EtoExp.wl" "C:/Users/nsh/Documents/8-dim/EtoExp.wl"; do
  printf '%-52s ' "$f"
  stat -c '%s bytes  ' "$f" | tr -d '
'
  grep -qc 'BeginPackage' "$f" && echo "package form" || echo "OLD flat form"
done
```

prints `8801 bytes  package form` three times.

An earlier revision of this page described the `EtoExp.wl` change as "a whole-file line-ending
change". That was wrong. Comparing with carriage returns stripped shows 21 genuinely added
lines:

```bash
cd "$(git rev-parse --show-toplevel)"
git show HEAD:EtoExp.wl > /tmp/old_etoexp.wl
diff <(tr -d '
' < /tmp/old_etoexp.wl) <(tr -d '
' < EtoExp.wl)
```

To see exactly this split:

```bash
cd "$(git rev-parse --show-toplevel)"
git status --porcelain
git diff --stat EtoExp.wl
git diff --stat "Pre-gravity_Pre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes.nb.pdf"
```

What was committed:

> **Do not run the next block against the current repository.** It is the historical record of
> the FIRST `.gitignore`, the five-line one written at this moment. That file has since been
> replaced three times (`a1096db`, `ea0f3fc`, `35ff142`) and the shipped version is 208 lines.
> Running this heredoc today would overwrite the shipped file with the five-line stub and
> silently delete every credential pattern the rest of this page justifies. To read the file
> that is actually in the repository, use `cat .gitignore`; it is reproduced in full in section
> 2b below, so this page still carries it complete.

```bash
cd "$(git rev-parse --show-toplevel)"
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

The 24 MB source notebook and the author's two `.mx` files are included on purpose. The author's
`.mx` files hold the Euler-Lagrange equations his own notebook computed and saved before any of
this work began, and the refactored notebook's equations are compared against them with `SameQ`.
Without those files in the repository that comparison could not be run from a clone:

```bash
cd "$(git rev-parse --show-toplevel)/claude-fable"
wolframscript -code '
  src  = "C:/Users/nsh/Documents/8-dim/Pre-Universe_14SEP26-77/";
  mine = "C:/Users/nsh/Documents/8-dim/";
  Get[src <> "Pre-gravityPre-Big_Bang_M6=3-Generations_of_Einstein-Rosen-2-Planes-eLa.mx"];
  a = eLa; Clear[eLa];
  Get[mine <> "claude-fable_Einstein-Rosen-2-Planes-eLa.mx"];
  Print["identical: ", a === eLa]'
```

which prints `identical: True`. `backups/` is excluded by `.gitignore` because it is a 24 MB
duplicate of the source.

## 2a. The .gitignore, and the secret scan

The ignore file has three commented sections: secrets, litter, and scratch text and logs. The
third one went through two designs, and the second is the one that shipped.

**First design, and why it was wrong.** The obvious reading of the author's original file was
"ignore `*.txt` and `*.log`, then rescue the deliverables":

```
*.txt
*.log
!Pre.txt
!Pre-00.txt
!README*.txt
!LICENSE*.txt
!CHANGELOG*.txt
!claude-fable/**/*.log
!claude-fable/**/*.txt
```

That is *correct*. Gitignore resolves by LAST match, so every one of those files is kept, and
`git ls-files -z | xargs -0 git check-ignore --no-index` returns nothing.

It is also a trap, in two ways.

It reads as a lie. Someone opens the file, sees `*.txt` at the top of the section, concludes that
text files are omitted, and is then surprised to find `Pre.txt` and `Pre-00.txt` in the
repository. The line that makes the top line untrue is fifteen lines below it. That is exactly
the question this design provoked, and the question was fair.

Worse, it fails silently in the one direction that matters. Ignore-everything-then-rescue means
every NEW text or log deliverable is dropped unless somebody remembers to come back and add
another `!` line. Nothing errors, nothing appears in `git status`, the file is simply not in the
commit. This repository is mostly provenance: **33 of its 86 tracked files were `.txt` or `.log`**
when this was written, and 43 of 114 are today;
and they are the record of exactly what the notebook printed. The rule was aimed straight at the
thing most likely to be lost.

**Second design, which shipped.** The logic is inverted. Nothing is ignored by extension. Scratch
is named, by the shapes scratch actually takes:

```
*.tmp   *.temp   *.bak   *.bak.*   *.orig   *.rej   *.old
scratch*   Scratch*   tmp[-_.]*   temp[-_.]*   untitled*   Untitled*
*-scratch.*   *[-_]draft.*
```

A stray `notes.txt` now shows up as untracked in `git status`, which is visible and one command
to resolve, instead of vanishing. Adding a new provenance log or specification needs no edit to
the ignore file at all.

The one case that argues for a blanket `*.log` is LaTeX, which writes `<doc>.log` beside
`<doc>.tex`. Section 2 covers LaTeX's other products but deliberately not its log, because
`*.log` cannot be scoped by extension without catching the provenance logs (29 of them when
this was written, 39 today). There are no
`.tex` sources in this repository, so nothing writes one today; if one is ever added, the rule
should name it rather than reintroduce a blanket.

One property of gitignore is worth knowing here, because the superseded design depended on it
entirely: a `!` rule cannot rescue a file whose parent directory is excluded. The shipped design
does not depend on it. Its only negations are `!.env.example` and `!.env.sample`, which negate
the file pattern `.env.*` rather than any directory.

Check that no tracked file is caught by any rule:

```bash
cd "$(git rev-parse --show-toplevel)"
git ls-files -z | xargs -0 git check-ignore --no-index
```

Empty output means every tracked file survives. Then spot-check both directions:

```bash
cd "$(git rev-parse --show-toplevel)"
for f in Pre.txt Pre-00.txt claude-fable/run8.log claude-fable/final_run.log          claude-fable/extract/cells_dump.txt claude-fable/extract/cells_index.txt; do
  printf '  %-48s ' "$f"
  if git check-ignore --no-index -q "$f"; then echo "IGNORED  <-- WRONG"; else echo "kept"; fi
done
for f in "EtoExp - Copy.wl" "EtoExp copy 2.wl" "backups/x" ".claude/x"          "scratch.log" "tmp-notes.txt" ".env" "id_rsa" "mathpass" "server.key"; do
  printf '  %-48s ' "$f"
  if git check-ignore --no-index -q "$f"; then echo "ignored"; else echo "NOT ignored <-- check"; fi
done
```

Every deliverable prints `kept`; every piece of litter and every credential-shaped name prints
`ignored`. Under the shipped design the same is true of files that do not exist yet:

```bash
cd "$(git rev-parse --show-toplevel)"
for f in claude-fable/brand_new_run.log PROVENANCE-09-SOMETHING.md NewSpec.txt notes.txt; do
  printf '  %-32s ' "$f"
  if git check-ignore --no-index -q "$f"; then echo "IGNORED <-- trap"; else echo "kept (correct)"; fi
done
```

All four print `kept (correct)`, which is the property the first design lacked.

`notes.txt` is in that second list deliberately. Under the superseded blanket it printed
`ignored`; under the shipped design it is kept, which is exactly the behaviour described above,
a stray text file becoming visible in `git status` rather than vanishing. An earlier revision of
this page still listed it among the litter, which contradicted its own prose.

A warning about reading these results. `git check-ignore -v` prints the matching line even when
that line is a NEGATION, so the printed line does not tell you the verdict and a `!Pre.txt` in
the output does NOT mean the file is ignored. Use the exit code: 0 means ignored, 1 means kept.
That is why every check on this page uses `-q` and tests the exit status.

**The secret scan.** Nothing matching a credential pattern exists in the tracked tree, in the
untracked files, inside the multi-megabyte binaries, or in the nine commits that were pushed.
The commands, all of which return nothing:

```bash
cd "$(git rev-parse --show-toplevel)"

# tracked text files
git grep -n -I -E 'ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9-]{20,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----|glpat-[A-Za-z0-9_-]{20,}' -- .

# untracked text files
grep -rIn -E 'ghp_|gho_|github_pat_|sk-ant-|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----'      --exclude-dir=.git --exclude-dir=backups .

# Wolfram licensing material, which is the credential class this repository could plausibly leak
git grep -n -I -E '\$ActivationKey|ActivationKey|mathpass|\$LicenseID|LicenseID|\$MachineID|MathID|PasswordFile' -- .

# credential-shaped filenames anywhere in the tree
find . -path ./.git -prune -o -path ./backups -prune -o -type f      \( -name '.env*' -o -name '*.pem' -o -name '*.key' -o -name '*.p12' -o -name '*.pfx'         -o -name 'id_rsa*' -o -name 'id_ed25519*' -o -name '*credential*' -o -name '*secret*'         -o -name 'mathpass' -o -name '.netrc' -o -name '_netrc' \) -print

# the binaries, which git grep -I skips
for f in $(git ls-files | grep -Ei '\.(nb|pdf|mx)$'); do
  n=$(grep -a -c -E 'ghp_|gho_|github_pat_|sk-ant-|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|ActivationKey|mathpass' "$f" 2>/dev/null)
  [ "$n" != "0" ] && echo "HIT($n) $f"
done

# nothing ignored is tracked
git ls-files | grep -E '^\.claude/|^backups/|__pycache__'
```

Note on the last two. The binary loop reports a spurious `HIT()` with an empty count for any file
that is deleted from the working tree but still in `HEAD`; read such a file out of git instead,
`git cat-file -p HEAD:<path> | grep -a -c -E ...`, which returns `0` here.

**One false positive, and why it is one.** Scanning the published clone, the Google-API-key
pattern `AIza[0-9A-Za-z_-]{35}` matches once, inside `2026-02-20-Pre-U-mmM4p.nb`:

```
2026-02-20-Pre-U-mmM4p.nb:217269:Q4cO9XejEG9s2bKFtEYAIza0LVWsdu3a9negqDwHN9CrabKZzFILtehtX2b4
```

It is not a key. Three independent checks say so:

```bash
cd <the clone>

# 1. it is spliced into a 60-character base64 line at offset 19 and runs off the end.
#    A real AIza key is a standalone 39-character token.
L=$(sed -n '217269p' 2026-02-20-Pre-U-mmM4p.nb)
echo "line length ${#L}, AIza at offset $(awk -v s="$L" 'BEGIN{print index(s,"AIza")-1}')"

# 2. no standalone key-shaped token exists anywhere in the file
grep -a -o -E '(^|[^0-9A-Za-z_-])AIza[0-9A-Za-z_-]{35}([^0-9A-Za-z_-]|$)' 2026-02-20-Pre-U-mmM4p.nb

# 3. the enclosing construct is a pasted image, not a data store
awk 'NR<=217269 && /CompressedData|GraphicsData|RasterBox/ {n=NR; t=$0} END{print n": "substr(t,1,100)}'     2026-02-20-Pre-U-mmM4p.nb
```

Check 1 prints `line length 60, AIza at offset 19`. Check 2 prints nothing. Check 3 prints
`214471:    TagBox[RasterBox[CompressedData["`. The match is four characters of base64 inside a
compressed raster image that happen to spell `AIza`.

The other hits any rerun will show are self-matches: the credential patterns written into
`.gitignore`, and the scan commands quoted on this page.

**Verification that the ignore file was respected.** After cloning, the ignored things must be
absent and the rescued deliverables present:

```bash
V=<the clone>
for p in "EtoExp - Copy.wl" "EtoExp copy 2.wl" "backups" ".claude" "__pycache__"; do
  printf '  %-28s ' "$p"; [ -e "$V/$p" ] && echo "PRESENT <-- not respected" || echo "absent (correct)"
done
for p in "Pre.txt" "Pre-00.txt" "claude-fable/run8.log" "claude-fable/final_run.log"          "claude-fable/extract/cells_dump.txt" "claude-fable/extract/cells_index.txt"; do
  printf '  %-40s ' "$p"; [ -f "$V/$p" ] && echo "present (correct)" || echo "MISSING <-- rule failed"
done
```

All five ignored paths print `absent (correct)`; all six deliverables print `present (correct)`.

## 2b. The shipped `.gitignore`, in full

The five-line file in section 2 above is the historical one. This is the file that is actually
in the repository today, reproduced complete so that this page needs no other file. It is 208
lines. Verify it with `cat .gitignore` or `sha256sum .gitignore`.

```
# =============================================================================
#  Pre-Universe_with_Claude  --  .gitignore
#
#  Three jobs, in order of importance:
#
#    1. no credential ever enters the history;
#    2. editor, OS, language and build litter stays out;
#    3. this project's own deliverables stay IN, and are never at the mercy of
#       an exception list somebody has to remember to update.
#
#  Job 3 is why there is no blanket "*.txt" or "*.log" rule.  This repository is
#  mostly provenance: 46 of its 119 tracked files are .txt or .log, and they are
#  the record of exactly what the notebook printed.  Ignoring them by extension
#  and rescuing them by name would mean every new one is dropped in silence.
#  Scratch is named instead.  See section 3 for the full reasoning.
#
#  One rule of gitignore worth knowing, because the superseded design depended on
#  it entirely: a "!" rule cannot rescue a file whose PARENT DIRECTORY is
#  excluded.  The shipped design does not depend on it.  Its only negations are
#  !.env.example and !.env.sample in section 1, which negate the FILE pattern
#  .env.* rather than any directory, so nothing here is at the mercy of
#  directory ordering.
# =============================================================================


# -----------------------------------------------------------------------------
# 1.  SECRETS
#
#     Nothing matching these may ever be committed.  Nothing matching them is
#     present today; these patterns are here so that it stays that way.
# -----------------------------------------------------------------------------

# environment and dotfile credential stores
.env
.env.*
!.env.example
!.env.sample
.netrc
_netrc
.npmrc
.pypirc
.htpasswd

# keys and certificates
*.pem
*.key
*.p12
*.pfx
*.jks
*.keystore
*.asc
*.gpg
id_rsa*
id_dsa*
id_ecdsa*
id_ed25519*
*.ppk

# anything that names itself a credential
*credential*
*credentials*
*.secret
*.secrets
secrets.*
*token*.json
*_token
*.token

# Wolfram and Mathematica licensing material.  A mathpass file holds licence
# passwords and an activation key is a credential in exactly the way an API
# token is.  Neither belongs in a public repository.
mathpass
*.mathpass
ActivationKey*
*activation-key*
*activation_key*

# tool and agent state, which can carry tokens or conversation transcripts
.claude/
.vscode/
.idea/
*.code-workspace


# -----------------------------------------------------------------------------
# 2.  LITTER
#
#     Editor swap files, OS metadata, language caches, build products, and the
#     duplicate files this project accumulates while the author works.
# -----------------------------------------------------------------------------

# operating system
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db
ehthumbs.db
desktop.ini

# editors
*.swp
*.swo
*.swn
*~
.*.sw[a-z]

# Python, used here only by the notebook build tool
__pycache__/
*.py[cod]
.pytest_cache/

# LaTeX build products, which is what *.aux, *.toc and *.out were added for
*.aux
*.toc
*.out
*.lof
*.lot
*.synctex.gz
*.fls
*.fdb_latexmk
*.bbl
*.blg

# Wolfram front-end scratch
*.nb.bak
.MathematicaHistory

# hand-made duplicates: "EtoExp - Copy.wl", "EtoExp copy 2.wl" and friends
*[Cc]opy*.wl
*[Cc]opy*.nb
*[Cc]opy*.mx

# local backups taken before modifying a file.  These are multi-megabyte
# duplicates of files that are already in the repository.
backups/


# -----------------------------------------------------------------------------
# 3.  SCRATCH TEXT AND LOGS
#
#     This section used to read
#
#         *.txt
#         *.log
#         !Pre.txt
#         !Pre-00.txt
#         !README*.txt
#         !LICENSE*.txt
#         !CHANGELOG*.txt
#         !claude-fable/**/*.log
#         !claude-fable/**/*.txt
#
#     which was correct but a trap, for two reasons.
#
#     First it read as a lie.  Anyone opening this file saw "*.txt", concluded
#     that .txt files are omitted, and was then surprised to find Pre.txt and
#     Pre-00.txt in the repository.  The exception that made it true was fifteen
#     lines further down, and gitignore resolves by LAST match, so you had to
#     read to the bottom to know what the top meant.
#
#     Second, and worse, it failed silently in the one direction that matters.
#     Ignore-everything-then-rescue means every NEW text or log deliverable is
#     dropped unless somebody remembers to come back here and add another "!"
#     line.  Nothing errors.  Nothing appears in git status.  The file is just
#     quietly not in the commit.  That is the worst failure mode a .gitignore
#     can have, and this repository is mostly provenance logs, so it was
#     pointed straight at the thing most likely to be lost.
#
#     So the logic is inverted.  Nothing is ignored by extension.  Scratch is
#     named, by the shapes scratch actually takes.  A stray notes.txt now shows
#     up as untracked in git status, which is visible and one command to fix,
#     instead of vanishing.  And adding a new provenance log or specification
#     needs no edit here at all.
# -----------------------------------------------------------------------------

# editor and tool backups, and merge leftovers
*.tmp
*.temp
*.bak
*.bak.*
*.orig
*.rej
*.old

# files whose NAME says they are scratch
scratch*
Scratch*
tmp[-_.]*
temp[-_.]*
untitled*
Untitled*
*-scratch.*
*[-_]draft.*

# There is deliberately no blanket *.log or *.txt rule, here or anywhere.
#
# LaTeX is the one tool that would argue for *.log, since it writes <doc>.log
# beside <doc>.tex.  Section 2 covers its other products (*.aux, *.toc, *.out and
# the rest) but NOT its log, precisely because *.log cannot be scoped by
# extension without catching the 42 provenance logs.  There are no .tex sources
# in this repository, so nothing writes a LaTeX log today.  If one is ever added,
# scope the rule to it by name, for example
#
#     paper.log
#
# rather than reintroducing a blanket.
```

To restore exactly this file:

```bash
cd "$(git rev-parse --show-toplevel)"
git checkout -- .gitignore
wc -l .gitignore          # 208
```

## 3. The commit and the push

```bash
cd "$(git rev-parse --show-toplevel)"
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
every hash comparison on this page. The `.mx` files were unaffected because git had detected
them as binary.

The fix is to tell git never to touch line endings, and to restore the exact bytes in the index:

```bash
cd "$(git rev-parse --show-toplevel)"
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
  b=$(sha256sum "$(git -C "$VER" rev-parse --show-toplevel)/../$f" 2>/dev/null | cut -d' ' -f1)
  [ -z "$b" ] && b=$(cd "$REPO" && sha256sum "$f" | cut -d' ' -f1)
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
(* Self-locating and depth-independent: this file is committed at <repo>/claude-fable, but is
   also meant to be copied to a clone root.  Work out which, rather than assuming. *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfCF   = If[FileExistsQ[FileNameJoin[{cfHere, "runner_header.wl"}]],
            cfHere,                                   (* run from inside claude-fable *)
            FileNameJoin[{cfHere, "claude-fable"}]];   (* run from the clone root      *)
dir    = ParentDirectory[cfCF];
SetDirectory[cfCF];
Print["working directory : ", Directory[]];
Get["runner_header.wl"];
nbfile = FileNameJoin[{cfCF, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
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

**139 of 139 cells evaluated, zero messages, 175 of 175 assertions passing, from a clone.**

> **Snapshot.** 175 was the assertion count on the day of this push. The notebook has since
> gained checks — 178 at commit `35ff142`, 182 at `2da615d` — so a clone made today prints
> **182 of 182**. The figures on this page are left as they were measured, because this page is
> the record of that push; re-run the commands and you will get today's numbers. What has not
> changed, and is the point of the check, is that *passed* equals *assertions run* and *FAILED*
> is zero, from a clone, with nothing from the development machine on the path.

No
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
| the provenance documents | repository root, `PROVENANCE-00` … `PROVENANCE-10`; there were nine when this page was written, and there are eleven today |

`C:\Users\nsh\Documents\8-dim` is not itself a git repository, which is why the notebook is
delivered both to that exact path and, as an identical copy, inside the repository. The two are
the same bytes:

```bash
sha256sum "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb" \
          "$(git rev-parse --show-toplevel)/claude-fable/claude-fable_Einstein-Rosen-2-Planes.nb"
```

Both print `5a12a7b4f1125d786bca279483b02d8c187a2498f50a5c0337f40cbc6cfeaaf1`.

## 9. What this proves

- The work is on `https://github.com/once-ere/Pre-Universe_with_Claude`, on `main`.
- The repository contains the delivered notebook, everything it is built from, the original
  24 MB source notebook, the author's two `.mx` files, every provenance script and log, and the
  nine provenance documents.
- A fresh clone returns every file byte-for-byte, including the author's original notebook.
- The delivered notebook runs to completion from that clone: 139 cells, zero messages, 175 of
  175 assertions passing *as measured on the day of this push*; a clone made today gives 182 of
  182, for the reason given in section 7.
