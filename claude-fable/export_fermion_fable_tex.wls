(* export_fermion_fable_tex.wls -- evaluate the notebook's Input cells through the end of Part VII and
   write TeX (TeXForm) and plain-text renderings of the fermion-fable results into
   <repo>/provenance-latex/generated/ :

     fermion_fable_field_equations.tex/.txt           the 16 component field equations on the canonical frame
     fermion_fable_adjoint_equations.tex/.txt         the 16 component adjoint (Psibar) equations
     fermion_fable_field_equations_8plus8.tex/.txt    the split-octonion 8+8 form (type-1 psi^(1), type-2 psi^(2))
     fermion_fable_field_equations_rescaled.tex/.txt  the 16 equations for Psi' = Psi/Sqrt[Sin[6 H x0]] (no connection)
     fermion_fable_anticommutator.tex/.txt            {Psi_a, Psi^ddag_b} = H Cos[6 H x0] J_ab delta^7, with the matrix
     fermion_fable_krein_J.tex/.txt                   J = -i T16[0]...T16[4], beta = -i T16[4], sigma16 = J beta
     fermion_fable_eos.tex/.txt                       the Kohn-Sham closed forms n, sigma, eps, P, w (g = 8)

   Every expression written here is taken from a notebook object that Part VII asserts (cfFieldEqTerms,
   cfAdjEqTerms, cfFieldOp16, cfUpper8, cfLower8, cfE8 under the rescaling, cfJK, cfBeta, cfAntiPsiPsiDd,
   cfNKS, cfSigKS, cfEpsKS, cfPKS); the script does no mathematics of its own beyond formatting.
   The fragments need amsmath; the matrix fragments set MaxMatrixCols to 16 themselves.

   Usage (from anywhere):   wolframscript -file claude-fable/export_fermion_fable_tex.wls              *)

(* --- self-locating, as run_from_nb.wls ---------------------------------------------------------- *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
cfRepo = ParentDirectory[cfHere];
cfNB   = FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}];
(* the notebook resolves its helper packages and reference files relative to the working directory *)
SetDirectory[cfHere];
Get[FileNameJoin[{cfHere, "runner_header.wl"}]];
nb = Import[cfNB, "Notebook"];
inputs = Cases[nb, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["evaluating ", Length[inputs], " Input cells of ", cfNB, " (output suppressed)"];
asOne[h_Hold] := Replace[h, Hold[args___] :> Hold[CompoundExpression[args]]];
Block[{$Output = {}}, Do[cfRunCell[i, asOne[ToExpression[inputs[[i]], InputForm, Hold]]], {i, Length[inputs]}]];
Print["assertions: ", Length[$cfAssertLog], "   failed: ", Count[$cfAssertLog, {_, False}], "   cells with messages: ", Length[$cfMessages]];
If[! ValueQ[cfFieldEqTerms] || ! ValueQ[cfJK] || ! ValueQ[cfEpsKS],
  Print["Part VII objects are missing -- is the notebook built with cells_part7.wl?"]; Exit[1]];

(* --- output directory -------------------------------------------------------------------------- *)
outDir = FileNameJoin[{cfRepo, "provenance-latex", "generated"}];
If[! DirectoryQ[outDir], CreateDirectory[outDir, CreateIntermediateDirectories -> True]];

(* --- rendering helpers --------------------------------------------------------------------------- *)
(* readable symbols: x_mu, a_4, V'(s); the placeholder symbols below never occur in the notebook      *)
texRules = Join[Thread[X -> Table[Subscript[zzx, i], {i, 0, 7}]], {a4 -> Subscript[zza, 4], cfVp -> zzVp}];
texClean[str_String] := StringReplace[str, {"\\text{zzx}" -> "x", "\\text{zza}" -> "a", "\\text{zzVp}" -> "V'(s)",
    "zzx" -> "x", "zza" -> "a", "zzVp" -> "V'(s)"}];
tex[e_] := texClean[ToString[TeXForm[e /. texRules]]];
txt[e_] := StringReplace[ToString[e /. cfVp -> zzVp, InputForm], {"zzVp" -> "V'[s]"}];
negQ[c_] := MatchQ[c, Times[n_?NumericQ, ___] /; Re[n] < 0] || (NumericQ[c] && Re[c] < 0);
(* one signed term: coefficient c times the symbol string sym *)
texTerm[c_, sym_String, first_] := Module[{neg = negQ[c], a},
  a = If[neg, -c, c];
  StringJoin[If[first, If[neg, "-", ""], If[neg, " - ", " + "]], If[a === 1, "", tex[a] <> "\\,"], sym]];
txtTerm[c_, sym_String, first_] := Module[{neg = negQ[c], a},
  a = If[neg, -c, c];
  StringJoin[If[first, If[neg, "-", ""], If[neg, " - ", " + "]], If[a === 1, "", "(" <> txt[a] <> ") "], sym]];
(* an equation from a term list {derivative terms {c, k, mu}, field terms {c, k}}; the V' term is moved right *)
splitV[c_] := {Expand[c /. cfVp -> 0], Coefficient[Expand[c], cfVp]};
renderEq[terms_, r_, fieldTeX_, fieldTxt_, rhsSign_] := Module[{der = terms[[1]], fld = terms[[2]], lhsT = {}, lhsX = {}, rhsC = 0, cnt = 0},
  Do[cnt++; AppendTo[lhsT, texTerm[t[[1]], "\\partial_{" <> ToString[t[[3]]] <> "}" <> fieldTeX[t[[2]]], cnt == 1]];
     AppendTo[lhsX, txtTerm[t[[1]], "d_" <> ToString[t[[3]]] <> " " <> fieldTxt[t[[2]]], cnt == 1]], {t, der}];
  Do[With[{sv = splitV[t[[1]]]},
      If[sv[[2]] =!= 0 && t[[2]] === r, rhsC = -sv[[2]] cfVp];
      If[sv[[1]] =!= 0, cnt++; AppendTo[lhsT, texTerm[sv[[1]], fieldTeX[t[[2]]], cnt == 1]]; AppendTo[lhsX, txtTerm[sv[[1]], fieldTxt[t[[2]]], cnt == 1]]]],
    {t, fld}];
  {lhsT, lhsX, rhsC}];
(* TeX: an align* block, three terms per line *)
alignBlock[label_String, lhsT_List, rhsTeX_String] := Module[{chunks = Partition[lhsT, UpTo[3]]},
  StringJoin["\\begin{align*}\n", label, "\\quad & ", StringRiffle[StringJoin /@ chunks, " \\\\\n & "], " \\\\\n & = ", rhsTeX, "\n\\end{align*}\n"]];
psiTeX[k_]   := "\\psi_{" <> ToString[k] <> "}";           psiTxt[k_]   := "psi_" <> ToString[k];
psibTeX[k_]  := "\\bar\\psi_{" <> ToString[k] <> "}";      psibTxt[k_]  := "psibar_" <> ToString[k];
psipTeX[k_]  := "\\psi'_{" <> ToString[k] <> "}";          psipTxt[k_]  := "psi'_" <> ToString[k];
psi88TeX[k_] := If[k < 8, "\\psi^{(1)}_{" <> ToString[k] <> "}", "\\psi^{(2)}_{" <> ToString[k - 8] <> "}"];
psi88Txt[k_] := If[k < 8, "psi1_" <> ToString[k], "psi2_" <> ToString[k - 8]];
header[title_String] := "% " <> title <> "\n% generated by claude-fable/export_fermion_fable_tex.wls from the notebook's Part VII objects, " <>
   DateString[{"Year", "-", "Month", "-", "Day"}] <> "\n% notation: x_0..x_7 are the coordinates (x_4 = the observer's time), a_4 = the free function a4 (never given a value),\n" <>
   "% q = e^{-a_4(H x_4)}/sin^{1/6}(6 H x_0), p = e^{+a_4(H x_4)}/sin^{1/6}(6 H x_0), s = bar(psi) psi.\n";
writeBoth[name_String, texStr_String, txtStr_String] := (
  Export[FileNameJoin[{outDir, name <> ".tex"}], texStr, "Text", CharacterEncoding -> "UTF-8"];
  Export[FileNameJoin[{outDir, name <> ".txt"}], txtStr, "Text", CharacterEncoding -> "UTF-8"];
  Print["  wrote ", FileNameJoin[{outDir, name}], ".tex / .txt"]);

(* --- 1. the sixteen field equations and the sixteen adjoint equations ------------------------------ *)
Module[{texS = header["fermion fable: the sixteen component field equations gamma^mu D_mu Psi = H V'(s) Psi on the canonical frame"], txtS = "fermion fable -- the 16 component field equations on the canonical frame\n\n"},
  Do[With[{e = renderEq[cfFieldEqTerms[[r]], r - 1, psiTeX, psiTxt, 1]},
     texS = texS <> alignBlock["(E_{" <> ToString[r - 1] <> "})", e[[1]], texTerm[e[[3]], psiTeX[r - 1], True]];
     txtS = txtS <> "E_" <> ToString[r - 1] <> ":  " <> StringJoin[e[[2]]] <> "  ==  " <> txtTerm[e[[3]], psiTxt[r - 1], True] <> "\n"], {r, 16}];
  writeBoth["fermion_fable_field_equations", texS, txtS]];
Module[{texS = header["fermion fable: the sixteen component adjoint equations (D_mu Psibar) gamma^mu = -H V'(s) Psibar"], txtS = "fermion fable -- the 16 component adjoint equations on the canonical frame\n\n"},
  Do[With[{e = renderEq[cfAdjEqTerms[[r]], r - 1, psibTeX, psibTxt, -1]},
     texS = texS <> alignBlock["(\\bar E_{" <> ToString[r - 1] <> "})", e[[1]], texTerm[e[[3]], psibTeX[r - 1], True]];
     txtS = txtS <> "Ebar_" <> ToString[r - 1] <> ":  " <> StringJoin[e[[2]]] <> "  ==  " <> txtTerm[e[[3]], psibTxt[r - 1], True] <> "\n"], {r, 16}];
  writeBoth["fermion_fable_adjoint_equations", texS, txtS]];

(* --- 2. the 8+8 form: compact statement plus the components relabelled psi^(1), psi^(2) -------------- *)
Module[{texS, txtS},
  texS = header["fermion fable: the split-octonion 8+8 form, Psi = (psi^(1), psi^(2))"] <>
    "\\begin{align*}\n" <>
    "& " <> tex[Cot[6 H x0]] <> "\\,\\partial_0\\psi^{(2)} + " <> tex[1/cfQminus] <> "\\sum_{i=1}^{3}\\bar\\tau_i\\partial_i\\psi^{(2)} + \\bar\\tau_4\\partial_4\\psi^{(2)} \\\\\n& \\quad + " <>
    tex[1/cfQplus] <> "\\sum_{h=5}^{7}\\bar\\tau_h\\partial_h\\psi^{(2)} - 3H" <> tex[Cot[6 H x0]^2] <> "\\,\\psi^{(2)} = H V'(s)\\,\\psi^{(1)}, \\\\[4pt]\n" <>
    "& " <> tex[Cot[6 H x0]] <> "\\,\\partial_0\\psi^{(1)} + " <> tex[1/cfQminus] <> "\\sum_{i=1}^{3}\\tau_i\\partial_i\\psi^{(1)} + \\tau_4\\partial_4\\psi^{(1)} \\\\\n& \\quad + " <>
    tex[1/cfQplus] <> "\\sum_{h=5}^{7}\\tau_h\\partial_h\\psi^{(1)} - 3H" <> tex[Cot[6 H x0]^2] <> "\\,\\psi^{(1)} = H V'(s)\\,\\psi^{(2)}, \\\\[4pt]\n" <>
    "& s = -\\psi^{(1)\\ddagger}\\sigma\\,\\psi^{(1)} + \\psi^{(2)\\ddagger}\\sigma\\,\\psi^{(2)} .\n\\end{align*}\n" <>
    "Component form (rows 0--7: the $\\bar\\tau$ equations for $\\psi^{(2)}$; rows 8--15: the $\\tau$ equations for $\\psi^{(1)}$):\n";
  txtS = "fermion fable -- the split-octonion 8+8 form\n\n" <>
    "Cot[6 H x0] d_0 psi2 + (1/q) Sum_i taubar_i d_i psi2 + taubar_4 d_4 psi2 + (1/p) Sum_h taubar_h d_h psi2 - 3 H Cot[6 H x0]^2 psi2 == H V'[s] psi1\n" <>
    "Cot[6 H x0] d_0 psi1 + (1/q) Sum_i tau_i d_i psi1 + tau_4 d_4 psi1 + (1/p) Sum_h tau_h d_h psi1 - 3 H Cot[6 H x0]^2 psi1 == H V'[s] psi2\n" <>
    "s == -psi1^ddag sigma psi1 + psi2^ddag sigma psi2\n" <>
    "q = " <> txt[cfQminus] <> ",  p = " <> txt[cfQplus] <> "\n\ncomponents:\n";
  Do[With[{e = renderEq[cfFieldEqTerms[[r]], r - 1, psi88TeX, psi88Txt, 1]},
     texS = texS <> alignBlock["(E_{" <> ToString[r - 1] <> "})", e[[1]], texTerm[e[[3]], psi88TeX[r - 1], True]];
     txtS = txtS <> "E_" <> ToString[r - 1] <> ":  " <> StringJoin[e[[2]]] <> "  ==  " <> txtTerm[e[[3]], psi88Txt[r - 1], True] <> "\n"], {r, 16}];
  writeBoth["fermion_fable_field_equations_8plus8", texS, txtS]];

(* --- 3. the rescaled equations: the notebook's rescaled operator, divided by Sqrt[Sin[6 H x0]] -------- *)
Module[{resc, terms, texS, txtS},
  (* the rescaled operator in the form asserted in Section 27 (iv): (cfE8 /. cfRescale8) == Sqrt[Sin[6 H x0]] resc *)
  resc = Expand[Cot[6 H x0] T16[0] . D[cfPsiP8, x0] + (1/cfQminus) Sum[T16[i] . D[cfPsiP8, X[[i + 1]]], {i, 1, 3}] + T16[4] . D[cfPsiP8, x4]
     + (1/cfQplus) Sum[T16[h] . D[cfPsiP8, X[[h + 1]]], {h, 5, 7}] - H cfVp cfPsiP8];
  terms = Table[cfTermsOf[resc[[r]], cfPsiPA], {r, 16}];
  texS = header["fermion fable: the rescaled field equations, Psi = Sqrt[Sin[6 H x0]] Psi' (the spin connection disappears); V' is evaluated at s = Sin[6 H x0] s'"];
  txtS = "fermion fable -- the rescaled field equations, Psi = Sqrt[Sin[6 H x0]] Psi', V' evaluated at s = Sin[6 H x0] Psi'bar Psi'\n\n";
  Do[With[{e = renderEq[terms[[r]], r - 1, psipTeX, psipTxt, 1]},
     texS = texS <> alignBlock["(E'_{" <> ToString[r - 1] <> "})", e[[1]], texTerm[e[[3]], psipTeX[r - 1], True]];
     txtS = txtS <> "E'_" <> ToString[r - 1] <> ":  " <> StringJoin[e[[2]]] <> "  ==  " <> txtTerm[e[[3]], psipTxt[r - 1], True] <> "\n"], {r, 16}];
  writeBoth["fermion_fable_field_equations_rescaled", texS, txtS]];

(* --- 4. the anticommutator and the Krein structure -------------------------------------------------- *)
matTeX[m_] := "\\setcounter{MaxMatrixCols}{16}\n\\left(\\begin{smallmatrix}\n" <>
   StringRiffle[Table[StringRiffle[Table[tex[m[[i, j]]], {j, Length[m[[i]]]}], " & "], {i, Length[m]}], " \\\\\n"] <> "\n\\end{smallmatrix}\\right)";
matTxt[m_] := StringRiffle[Table[StringRiffle[ToString[#, InputForm] & /@ m[[i]], "  "], {i, Length[m]}], "\n"];
Module[{acomm = cfAntiPsiPsiDd /. cfCK -> cfSqrtg/H},
  writeBoth["fermion_fable_anticommutator",
    header["fermion fable: the canonical anticommutator on the canonical frame"] <>
      "\\begin{align*}\n\\{\\Psi_a(x),\\Psi^{\\ddagger}_b(y)\\}_{x_4=y_4} &= \\frac{H}{\\sqrt{|g|}}\\,J_{ab}\\,\\delta^7(x-y) = " <> tex[H Cos[6 H x0]] <>
      "\\,J_{ab}\\,\\delta^7(x-y), \\qquad \\{\\Psi_a,\\Psi_b\\}=0, \\\\\n\\{\\Psi_a(x),\\Psi^{\\dagger}_b(y)\\}_{x_4=y_4} &= \\frac{H}{\\sqrt{|g|}}\\,\\delta_{ab}\\,\\delta^7(x-y)\n\\end{align*}\n" <>
      "with $\\Psi^\\dagger = \\Psi^\\ddagger J$; the anticommutator matrix is $\\frac{H}{\\sqrt{|g|}}J = " <> tex[H Cos[6 H x0]] <> "\\,J$ with\n\\[ J = " <>
      matTeX[cfSimpArray[acomm/(H Cos[6 H x0])]] <> " \\]\n",
    "{Psi_a(x), Psi^ddag_b(y)} = (H/Sqrt[g]) J_ab delta^7(x-y) = " <> txt[H Cos[6 H x0]] <> " J_ab delta^7(x-y);  {Psi_a, Psi_b} = 0;  " <>
      "{Psi_a, Psi^dagger_b} = (H/Sqrt[g]) delta_ab delta^7 with Psi^dagger = Psi^ddag J\n\nmatrix (H/Sqrt[g]) J:\n" <> matTxt[cfSimpArray[acomm]] <> "\n"]];
writeBoth["fermion_fable_krein_J",
  header["fermion fable: the Krein fundamental symmetry J, the Dirac-adjoint matrix beta, sigma16 = J beta"] <>
    "\\[ J = -i\\,T_{16}[0]T_{16}[1]T_{16}[2]T_{16}[3]T_{16}[4] = -i\\,\\sigma_{16}T_{16}[4] = " <> matTeX[cfJK] <> " \\]\n" <>
    "\\[ \\beta = -i\\,T_{16}[4] = " <> matTeX[cfBeta] <> ", \\qquad \\sigma_{16} = J\\beta, \\quad J^2=\\beta^2=1, \\quad \\bar\\Psi = \\Psi^\\dagger\\beta . \\]\n",
  "J = -I T16[0].T16[1].T16[2].T16[3].T16[4] = -I sigma16.T16[4]:\n" <> matTxt[cfJK] <> "\n\nbeta = -I T16[4]:\n" <> matTxt[cfBeta] <>
    "\n\nsigma16 = J.beta, J^2 = beta^2 = 1, Psibar = Psi^dagger beta\n"];

(* --- 5. the equation of state of the Kohn-Sham Fermi sea (g = 8) ---------------------------------- *)
Module[{rl = {cfKF -> Subscript[zzk, "F"], cfMm -> zzm, cfGdeg -> 8}, ks},
  ks = {{"n", cfNKS}, {"\\sigma_{KS}", cfSigKS}, {"\\varepsilon_{KS}", cfEpsKS}, {"P_{KS}", cfPKS}};
  writeBoth["fermion_fable_eos",
    header["fermion fable: the Kohn-Sham Fermi sea in closed form, g = 8 (canonical normalization chi = Psi/Sqrt[H], m = W'(sigma) > 0)"] <>
      "\\begin{align*}\n" <> StringRiffle[Table[e[[1]] <> " &= " <> StringReplace[tex[e[[2]] /. rl], {"\\text{zzk}" -> "k", "\\text{zzm}" -> "m", "\\text{F}" -> "F"}], {e, ks}], " \\\\\n"] <>
      " \\\\\n\\rho &= \\varepsilon_{KS} + W - \\sigma W', \\quad P_{obs} = P_{KS} + \\sigma W' - W, \\quad P_{hid} = \\sigma W' - W, \\quad \\rho + P_{obs} = w_F\\, n, \\quad w_F = \\sqrt{k_F^2+m^2}" <>
      " \\\\\nw &= P_{KS}/\\varepsilon_{KS} \\in [0, 1/3] \\text{ for the mass term } W = m\\sigma \\quad (w \\to k_F^2/(5m^2) \\text{ as } k_F/m\\to 0,\\ w\\to 1/3 \\text{ as } k_F/m\\to\\infty)\n\\end{align*}\n",
    StringRiffle[Table[e[[1]] <> " = " <> ToString[e[[2]] /. {cfKF -> kF, cfMm -> m, cfGdeg -> 8}, InputForm], {e, ks}], "\n"] <>
      "\nrho = eps_KS + W - sigma W',  P_obs = P_KS + sigma W' - W,  P_hid = sigma W' - W,  rho + P_obs = wF n,  wF = Sqrt[kF^2 + m^2]\n" <>
      "w = P_KS/eps_KS in [0, 1/3] for the mass term W = m sigma (w -> kF^2/(5 m^2) as kF/m -> 0, w -> 1/3 as kF/m -> Infinity)\n"]];
Print["done: ", Length[FileNames["*", outDir]], " files in ", outDir];
