ssX = H > 0 && x0 > 0 && x4 > 0 && 6 H x0 > 0 && 2 la[x4] > 0 && Cot[6 H x0] > 0 && Sin[6 H x0] > 0;
q = Exp[-a4[H x4]]/Sin[6 H x0]^(1/6);
p = Exp[+a4[H x4]]/Sin[6 H x0]^(1/6);
fr = DiagonalMatrix[{Tan[6 H x0], q, q, q, 1, p, p, p}];
eta = DiagonalMatrix[{1,1,1,1,-1,-1,-1,-1}];
g = Simplify[fr . eta . Transpose[fr], ssX];
Print["A) exact, assumption-free: Diagonal[g] == Diagonal[eta] * Diagonal[frame]^2"];
Print["   residual = ",
  Simplify[Diagonal[g] - Diagonal[eta] * Diagonal[fr]^2, ssX]];
Print[];
Print["B) signature, GIVEN a4 real-valued and 0 < 6 H x0 < Pi/2"];
asm = ssX && Element[a4[H x4], Reals] && 0 < 6 H x0 < Pi/2;
s = Simplify[# > 0, asm] & /@ Diagonal[g];
Print["   ", s];
Print["   positive: ", Count[s, True], "   negative: ", Count[s, False]];
