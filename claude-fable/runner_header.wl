(* runner_header.wl -- harness used by run_all.wls to evaluate every notebook Input cell
   in order, in one kernel, reporting timing and every message raised. *)

$cfCellLog = {};
$cfMessages = {};

cfRunCell[n_Integer, held_Hold] := Module[{t, r, msgs},
  t = 0; r = Null;
  msgs = Block[{$MessageList = {}},
    {t, r} = AbsoluteTiming[ReleaseHold[held]];
    $MessageList];
  msgs = DeleteDuplicates[ToString[#, InputForm] & /@ msgs];
  AppendTo[$cfCellLog, <|"cell" -> n, "seconds" -> t, "messages" -> msgs|>];
  If[msgs =!= {}, AppendTo[$cfMessages, {n, msgs}]];
  Print["CELL ", n, "  t=", ToString[NumberForm[N[t], {8, 3}, ExponentFunction -> (Null &)]], " s",
    If[msgs === {}, "", "   MESSAGES: " <> ToString[msgs]]];
  r];

cfRunSummary[] := Module[{tot, slow},
  tot = Total[#["seconds"] & /@ $cfCellLog];
  slow = Reverse[SortBy[$cfCellLog, #["seconds"] &]][[1 ;; Min[12, Length[$cfCellLog]]]];
  Print["==================== RUN SUMMARY ===================="];
  Print["cells evaluated : ", Length[$cfCellLog]];
  Print["total seconds   : ", ToString[NumberForm[N[tot], {10, 3}, ExponentFunction -> (Null &)]]];
  Print["cells w/ msgs   : ", Length[$cfMessages]];
  If[$cfMessages =!= {},
    Print["---- messages ----"];
    Scan[Print["  cell ", #[[1]], ": ", #[[2]]] &, $cfMessages]];
  Print["---- slowest cells ----"];
  Scan[Print["  cell ", #["cell"], "  ", ToString[NumberForm[N[#["seconds"]], {8, 3}, ExponentFunction -> (Null &)]], " s"] &, slow];
  Print["==================== ASSERTIONS ===================="];
  Module[{n = Length[$cfAssertLog], bad = Cases[$cfAssertLog, {l_, False} :> l]},
    Print["assertions run  : ", n];
    Print["passed          : ", n - Length[bad]];
    Print["FAILED          : ", Length[bad]];
    Scan[Print["  FAIL: ", #] &, bad]];
  Print["===================================================="];
  ];
