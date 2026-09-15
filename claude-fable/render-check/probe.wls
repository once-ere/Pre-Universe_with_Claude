(* Open the delivered notebook in a front end and inspect what the front end actually made of
   it.  Read-only: opened Visible->False and closed without saving. *)
src = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
Print["file      : ", FileByteCount[src], " bytes  sha256 ",
      IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
UsingFrontEnd[
  nb  = NotebookOpen[src, Visible -> False];
  got = NotebookGet[nb];
  NotebookClose[nb]];

cells = Cases[got, Cell[_, s_String, ___] :> s, Infinity];
Print["cells     : ", Length[cells]];
Print["by style  : ", SortBy[Tally[cells], -Last[#] &]];
Print["ErrorBox  : ", Length[Cases[got, ErrorBox[___], Infinity]]];

(* An Input cell is stored in the file as Cell[BoxData["<code string>"], "Input"].  The front
   end must PARSE that string into boxes.  Any cell still holding a bare string after the
   front end has opened it is one the front end could not parse. *)
raw = Cases[got, Cell[BoxData[s_String], "Input", ___] :> s, Infinity];
Print["Input cells left as an unparsed string : ", Length[raw]];
If[raw =!= {}, Scan[Print["   UNPARSED: ", StringTake[#, Min[120, StringLength[#]]]] &, raw]];

(* Any box head the front end does not know would show up as a symbol with no rendering rule. *)
heads = DeleteDuplicates[Cases[got, h_Symbol[___] /; StringMatchQ[SymbolName[h], "*Box"] :> SymbolName[h], Infinity]];
Print["box heads : ", Sort[heads]];
Print["private-use chars remaining: ",
  Length[Select[Union[Flatten[Characters /@ Cases[got, _String, Infinity]]],
    57344 <= First[ToCharacterCode[#]] <= 63743 &]]];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
