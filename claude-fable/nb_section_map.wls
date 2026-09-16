(* nb_section_map.wls -- print the section-to-Input-cell map of the delivered notebook, in     *)
(* document order, without evaluating anything.  Used to keep the provenance tables honest.    *)
cfHere = DirectoryName[ExpandFileName[$InputFileName]];
nb = Import[FileNameJoin[{cfHere, "claude-fable_Einstein-Rosen-2-Planes.nb"}], "Notebook"];
cells = Cases[nb, Cell[_, "Title" | "Section" | "Input", ___], Infinity];
n = 0; current = None; first = 0;
flush[] := If[current =!= None, Print[current, "  |  Input cells ", If[first > n, "none", ToString[first] <> "-" <> ToString[n]]]];
Do[Switch[c[[2]],
   "Title",   flush[]; current = None; Print["== ", First[Cases[c, _String, Infinity]]],
   "Section", flush[]; current = First[Cases[c, _String, Infinity]]; first = n + 1,
   "Input",   n++],
  {c, cells}];
flush[];
Print["total Input cells: ", n];
