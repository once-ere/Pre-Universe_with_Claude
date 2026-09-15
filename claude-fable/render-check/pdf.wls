src = "C:/Users/nsh/Documents/8-dim/claude-fable_Einstein-Rosen-2-Planes.nb";
pdf = "C:/Users/nsh/Documents/8-dim/render3/rendered.pdf";
UsingFrontEnd[
  nb = NotebookOpen[src, Visible -> False];
  Export[pdf, nb];
  NotebookClose[nb]];
n = Import[pdf, "PageCount"];
Print["pdf : ", FileByteCount[pdf], " bytes   pages: ", n];
(* locate the blocks changed this session *)
needles = {"A word first on WHICH split", "the yZ split at 8 is NOT",
           "sigma16 alone is SYMMETRIC", "Count the gammas",
           "counts the times stage 3 returned TRUE",
           "identities accepted on numerical evidence alone"};
Do[Module[{hits = {}},
   Do[Module[{t = Quiet@Check[Import[pdf, {"Plaintext", k}], ""]},
      If[StringQ[t] && StringContainsQ[t, needle], AppendTo[hits, k]]], {k, n}];
   Print["  ", If[hits === {}, "NOT FOUND", "pages " <> ToString[hits]], "  <- ", needle]],
  {needle, needles}];
Print["source unchanged: ", IntegerString[Hash[ReadByteArray[src], "SHA256"], 16]];
