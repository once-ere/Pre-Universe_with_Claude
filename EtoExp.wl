(* ::Package:: *)

(* EtoExp.wl \[LongDash] convert textual Wolfram expressions that use Power[E, \[Ellipsis]] or E^(\[Ellipsis]) into Exp[\[Ellipsis]] form. *)

(* ============================================================================ *)
(* Patrick L. Nash, Ph.D.    (c) 2022, under GPL ; do not remove this notice   *)
(* Professor, UTSA Physics and Astronomy, Retired (UTSA)                        *)
(* Patrick299Nash  at    gmail   ...                                            *)
(* use at your own risk; this probably does not work correctly                  *)
(* blame: PLN and friends (VS code invoking GPT-5.3-Codex)                      *)
(* ====================================================================== *)
ClearAll[
    EtoExp,
    EtoExpValue,
    etoExpConvertHeldToString,
    etoExpConvertHeldToExpression,
    $etoExpRules,
    verifyEtoExpEquivalence,
    runEtoExpSelfTests,
    $etoExpTestInputs,
    $etoExpExpressionTests,
    $etoExpTestReport
];

SetAttributes[EtoExp, HoldAllComplete];

$etoExpRules = {
    HoldPattern[Power[E, arg_]] :> Exp[arg]
};

EtoExp::failed = "Unable to eliminate all exponential Power terms in `1`. Please check the input syntax.";
EtoExp::parse = "Unable to parse a single unambiguous expression from the input string: `1`. Use ToString[expr, InputForm] for reliable conversion.";

etoExpConvertHeldToString[heldExpr_HoldComplete] := Module[
    {convertedExpr, outputString},
    convertedExpr = heldExpr //. $etoExpRules;
    outputString = Replace[
        convertedExpr,
        HoldComplete[expr_] :> ToString[Unevaluated[expr], InputForm]
    ];
    If[! StringQ[outputString],
        outputString = ToString[outputString, InputForm]
    ];

    If[StringFreeQ[outputString, "Power[E"] && StringFreeQ[outputString, "E^"],
        Return[outputString],
        Message[EtoExp::failed, outputString];
        Return[$Failed]
    ]
];

etoExpConvertHeldToExpression[heldExpr_HoldComplete] := Module[{convertedExpr},
    convertedExpr = heldExpr //. $etoExpRules;
    convertedExpr = convertedExpr /. HoldPattern[Exp[arg_]] :> Inactive[Exp][arg];
    ReleaseHold[convertedExpr]
];

EtoExp[input_String?StringQ] := Module[
    {heldExpr},
    heldExpr = Quiet @ Check[ToExpression[input, InputForm, HoldComplete], $Failed];
    If[heldExpr === $Failed,
        heldExpr = Quiet @ Check[ToExpression[input, StandardForm, HoldComplete], $Failed]
    ];
    If[heldExpr === $Failed,
        Message[EtoExp::parse, input];
        Return[$Failed]
    ];
    If[MatchQ[heldExpr, HoldComplete[_, __]],
        Message[EtoExp::parse, input];
        Return[$Failed]
    ];

    etoExpConvertHeldToString[heldExpr]
];

EtoExp[input_] := Module[{heldExpr},
    heldExpr = HoldComplete[input];
    etoExpConvertHeldToExpression[heldExpr]
];

EtoExpValue[input_] := Activate[EtoExp[input]];

verifyEtoExpEquivalence[input_String?StringQ] := Module[
    {lhs, rhs},
    lhs = ReleaseHold @ ToExpression[input, InputForm, HoldComplete];
    rhs = ReleaseHold @ ToExpression[EtoExp[input], InputForm, HoldComplete];
    SameQ[lhs, rhs]
];

verifyEtoExpEquivalence[input_] := Module[
    {lhs, rhs},
    lhs = HoldComplete[input] /. HoldComplete[expr_] :> expr;
    rhs = Activate[HoldComplete[EtoExp[input]] /. HoldComplete[expr_] :> expr];
    SameQ[lhs, rhs]
];

$etoExpTestInputs = <|
    "Provided-1" -> StringTrim["
Power[E,
 Plus[Times[-1, Power[C4, -1], Power[H, -2], Power[M, 2],
   Plus[t, Times[Rational[-1, 6], z]]],
  Times[C4, Plus[t, Times[Rational[1, 6], z]]]]]
"],
    "Provided-2" -> StringTrim["
List[List[
  Equal[YZ0[z, t],
   Times[Rational[1, 2], Power[C1, -1],
    Power[E,
     Times[Rational[1, 6], Power[C1, -1], Power[H, -2],
      Plus[Times[-6, Power[M, 2], Plus[t, Times[Rational[-1, 6], z]]],
        Times[6, Power[C1, 2], Power[H, 2],
        Plus[t, Times[Rational[1, 6], z]]]]]], Power[H, -1],
    Power[M, -1],
    Plus[Times[Power[C1, 2], Plus[Times[c11, c12], Times[-1, c13, c14]],
       Power[H, 2]],
     Times[-1, Plus[Times[c11, c12], Times[c13, c14]], Power[M, 2]]]]],
   Equal[YZ1[z, t],
   Times[Rational[-1, 2], Power[C1, -1],
    Power[E,
     Times[Rational[1, 6], Power[C1, -1], Power[H, -2],
      Plus[Times[-6, Power[M, 2], Plus[t, Times[Rational[-1, 6], z]]],
        Times[6, Power[C1, 2], Power[H, 2],
        Plus[t, Times[Rational[1, 6], z]]]]]], Power[H, -1],
    Power[M, -1],
    Plus[Times[Power[C1, 2], Plus[Times[c11, c12], Times[-1, c13, c14]],
       Power[H, 2]],
     Times[Plus[Times[c11, c12], Times[c13, c14]], Power[M, 2]]]]],
  Equal[YZ2[z, t],
   Times[c13, c14,
    Power[E,
     Times[Rational[1, 6], Power[C1, -1], Power[H, -2],
      Plus[Times[-6, Power[M, 2], Plus[t, Times[Rational[-1, 6], z]]],
        Times[6, Power[C1, 2], Power[H, 2],
        Plus[t, Times[Rational[1, 6], z]]]]]]]],
  Equal[YZ3[z, t],
   Times[c11, c12,
    Power[E,
     Times[Rational[1, 6], Power[C1, -1], Power[H, -2],
      Plus[Times[-6, Power[M, 2], Plus[t, Times[Rational[-1, 6], z]]],
        Times[6, Power[C1, 2], Power[H, 2],
        Plus[t, Times[Rational[1, 6], z]]]]]]]]]]
"],
    "Custom-Nested" -> "Plus[Exp[x], E^(a + b*c), Power[E, Plus[Sin[u], Cos[z], Times[p, q]]]]",
    "Custom-Product" -> "Times[Power[E, Times[-1, x, y]], E^(Plus[a, Times[b, c]]), Power[Pi, 2]]",
    "Custom-Matrix" -> "List[List[E^(x + y), Power[E, Times[2, x]]], List[Power[E, -z], Exp[w]]]"
|>;

$etoExpExpressionTests = <|
    "Expr-Rule" -> HoldComplete[YZ15[z, t] -> c41*c42*E^(-((M^2*(t - z/6))/(C4*H^2)) + C4*(t + z/6))],
    "Expr-NestedList" -> HoldComplete[{{E^(x + y), Power[E, 2*z]}, {a, b*Power[E, -k]}}],
    "Expr-Mixed" -> HoldComplete[(Power[E, q] + 3*E^r)/Sqrt[Power[E, s]]]
|>;

$etoExpTestReport = Association @ KeyValueMap[
    Function[{name, input},
        name -> Module[{output = EtoExp[input]},
            <|
                "Converted" -> output,
                "Equivalent" -> If[output === $Failed, False, verifyEtoExpEquivalence[input]]
            |>
        ]
    ],
    $etoExpTestInputs
];

runEtoExpSelfTests[] := Module[{report},
    report = Join[
        Association @ KeyValueMap[
            Function[{name, input},
                name -> Module[{output = EtoExp[input]},
                    <|
                        "Kind" -> "StringInput",
                        "Converted" -> output,
                        "Equivalent" -> If[output === $Failed, False, verifyEtoExpEquivalence[input]]
                    |>
                ]
            ],
            $etoExpTestInputs
        ],
        Association @ KeyValueMap[
            Function[{name, heldInput},
                name -> Module[{inputExpr, outputExpr, outputText},
                    inputExpr = heldInput /. HoldComplete[expr_] :> expr;
                    outputExpr = With[{expr = inputExpr}, EtoExp[expr]];
                    outputText = ToString[HoldComplete[outputExpr], InputForm];
                    <|
                        "Kind" -> "ExpressionInput",
                        "Converted" -> outputExpr,
                        "Equivalent" -> verifyEtoExpEquivalence[inputExpr],
                        "NoForbiddenSyntax" -> StringFreeQ[outputText, "Power[E"] && StringFreeQ[outputText, "E^"]
                    |>
                ]
            ],
            $etoExpExpressionTests
        ]
    ];

    Print["EtoExp verification report:"];
    Scan[
        Function[key,
            With[{entry = report[key]},
                If[KeyExistsQ[entry, "NoForbiddenSyntax"],
                    Print[key, " [", entry["Kind"], "]: Equivalent->", entry["Equivalent"], "; NoForbiddenSyntax->", entry["NoForbiddenSyntax"], "; Converted->", entry["Converted"]],
                    Print[key, " [", entry["Kind"], "]: Equivalent->", entry["Equivalent"], "; Converted->", entry["Converted"]]
                ]
            ]
        ],
        Keys[report]
    ];

    report
];

Print["EtoExp.wl loaded.  BUT, WARNING:  DO NOT USE IF YOU WANT A CORRECT RESULT!"];
