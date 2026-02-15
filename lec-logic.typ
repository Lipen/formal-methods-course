#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Re-introduction to Logic",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

#import curryst: prooftree, rule

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)
#show table.cell.where(y: 0): strong

// Semantic evaluation
#let EvalWith(phi, inter) = $bracket.stroked.l phi bracket.stroked.r_(inter)$
#let Eval(phi) = EvalWith(phi, $nu$)

// Rewrite
#let rewrite = $arrow.double.long$


= Why Formal Methods?

== Motivation

Before we define verification formally, here is _why_ it matters.

#Block(color: orange, inset: 0.8em)[
  Software bugs have caused deaths, \$billion losses, and mission failures --- even when tests passed.
]

#[
  #set text(0.85em)
  #grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.8em,
    [
      *Ariane 5 (1996)* --- Overflow in 64→16-bit conversion destroyed a \$370M rocket 37 s after launch. Reused code from Ariane 4 _without re-verification_.
    ],
    [
      *Intel FDIV (1994)* --- Pentium division error in rare cases. \$475M recall; discovered by a mathematician, not by Intel's tests.
    ],

    [
      *Therac-25 (1985--87)* --- Race condition in radiation machine caused massive overdoses. At least 3 deaths.
    ],
    [
      *Knight Capital (2012)* --- Faulty trading software deployment. Lost \$440M in 45 minutes. Bankrupt within days.
    ],
  )
]

In each case, the system's behavior was never _proven_ to match its specification.

#Block(color: yellow, inset: 0.8em)[
  *Formal methods* turn correctness into a _mathematical question_ that machines can help answer.
  Instead of checking _some_ executions, we reason about _all_ of them.
]

== Formal Reasoning: A Taste

Here is the _kind_ of reasoning formal methods make precise and machine-checkable.

*Scenario:* A server has three properties documented in its specification:
+ If authentication succeeds, a session is created.
+ If a session is created, the user can access the resource.
+ Authentication succeeded.

In logical notation, with propositions $A$ = "auth succeeds", $S$ = "session created", $R$ = "resource accessible":

$
  underbrace(A imply S, "premise 1") quad
  underbrace(S imply R, "premise 2") quad
  underbrace(A, "premise 3")
$

*Derivation:* From $A$ and $A imply S$ we get $S$ (modus ponens).
From $S$ and $S imply R$ we get $R$ (MP again). \
*Conclusion:* the user can access the resource.

#place[
  #v(1em)
  #Block(color: blue)[
    This is a _proof_ --- a finite chain of justified steps from premises to a conclusion.
    Formal methods scale this idea to entire programs: premises are code + pre-conditions, and we prove that post-conditions follow.
  ]
]

== What Is Verification?

Software verification is the process of establishing that a system _meets its specification_.
Three ingredients are needed:

#definition[
  A _model_ is a mathematical representation of a system --- a finite-state machine, a logical formula, a program abstraction.
  It captures _what the system does_ (or can do), abstracting away irrelevant details.
]

#definition[
  A _specification_ is a precise, formal statement of _desired behavior_: a pre-condition/post-condition pair, an invariant, a temporal property.
  It captures _what the system should do_.
]

#definition[
  _Verification_ is checking whether a model satisfies a specification: $"Model" models "Spec"$.
]

#pagebreak()

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let blob = blob.with(shape: shapes.rect)
  #diagram(
    spacing: (3em, 1.5em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 3pt,

    blob((0, 0), [Real\ System], tint: orange, name: <sys>),
    blob((2, 0), [Model\ (abstraction)], tint: blue, name: <model>),
    blob((3, 0), [Verification\ $"Model" models "Spec"$?], tint: green, name: <verify>),
    blob((4, 0), [Specification\ (requirements)], tint: purple, name: <spec>),

    edge(<sys>, <model>, "=>", label: [_modeling_]),
    edge(<model>, <verify>, "-}>"),
    edge(<spec>, <verify>, "-}>"),
  )
]

#example[
  Consider a function `abs(x)` that should return $|x|$. \
  *Model:* the program code (or its logical encoding). \
  *Specification:* $"result" gt.eq 0$ and $("result" = x or "result" = -x)$. \
  *Verification:* prove that for _all_ inputs $x$, the model satisfies the specification.
]

#Block(color: yellow, inset: 0.8em)[
  *Formal methods =* build a model + write a specification + prove that $"Model" models "Spec"$.
]

The three ingredients are inseparable: a model without a spec is meaningless, a spec without verification is wishful thinking.

== The Verification Spectrum

#align(center)[
  #table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Method*][*Rigor*][*Coverage*][*Cost*][*Proves $"M" models "S"$?*],
    [Testing], [Low], [Partial], [Low], [No],
    [Static analysis], [Medium], [Heuristic], [Low], [Partially],
    [Model checking], [High], [Exhaustive (bounded)], [Medium], [Yes (bounded)],
    [Deductive verification], [Highest], [Complete], [High], [Yes],
  )
]

This course moves from left to right, ending with deductive verification in Dafny.

#Block(color: teal)[
  _"Testing shows the presence, not the absence of bugs."_ --- Edsger W. Dijkstra (1969)
]

== Course Roadmap

#align(center)[
  #Block(color: blue)[
    _"How do we make machines reason about correctness?"_
  ]
]

#v(2em)

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, color, ..args) = blob(
    pos,
    label,
    shape: rect,
    tint: color,
    ..args.named(),
  )
  #diagram(
    spacing: (1.5em, 1em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 2pt,

    vertex((0, 0), [Propositional\ Logic], green, name: <prop-logic>),
    vertex((1, 0), [Normal Forms\ & CNF], green, name: <normal-forms>),
    vertex((2, 0), [SAT\ Solving], blue, name: <sat-solving>),
    vertex((3, 0), [DPLL /\ CDCL], blue, name: <dpll-cdcl>),

    edge(<prop-logic>, <normal-forms>, "-}>"),
    edge(<normal-forms>, <sat-solving>, "-}>"),
    edge(<sat-solving>, <dpll-cdcl>, "-}>"),

    vertex((0, 2), [First-Order\ Logic], purple, name: <fol>),
    vertex((1, 2), [FOL\ Theories], purple, name: <fol-theories>),
    vertex((2, 2), [Decidability\ & Complexity], orange, name: <decidability>),
    vertex((3, 2), [SMT\ Solving], red, name: <smt-solving>),

    edge(<dpll-cdcl>, (3, 1), (0, 1), <fol>, "-}>"),
    edge(<fol>, <fol-theories>, "-}>"),
    edge(<fol-theories>, <decidability>, "-}>"),
    edge(<decidability>, <smt-solving>, "-}>"),

    vertex((1, 3), [Program Verification\ (Hoare Logic + Dafny)], yellow, name: <program-verification>),
    edge(<smt-solving.south>, <program-verification.east>, "-}>", bend: 30deg),
  )
]

= Propositional Logic Refresher

== Syntax vs Semantics: Why Two Perspectives?

// You studied propositional logic in Discrete Math.
// Here we revisit it through the lens of _formal methods_ --- focusing on how machines manipulate and decide logical formulas, and why certain representations (CNF, clausal form) are essential for automated reasoning.

Logic has two faces: _syntax_ (the strings we write and transform) and _semantics_ (what they _mean_).

#align(center)[
  #grid(
    columns: 2,
    align: left,
    column-gutter: 2em,
    [
      *Syntactic World ($entails$)*
      - Formulas, rewriting rules
      - Proof systems, derivations
      - _"I can derive $alpha$ from $Gamma$"_
      - Symbol: $Gamma entails alpha$
    ],
    [
      *Semantic World ($models$)*
      - Interpretations, truth values
      - Truth tables, models
      - _"$alpha$ is true whenever $Gamma$ is"_
      - Symbol: $Gamma models alpha$
    ],
  )
]

For propositional logic, these two worlds are _perfectly aligned_ --- soundness + completeness gives us $entails <==> models$.
So why bother distinguishing them?

*Reason 1 --- Different algorithms:*
Semantics gives _truth tables_ ($2^n$ rows --- brute force).
Syntax gives _proof search_ (sometimes exponentially shorter).
For 300 variables, a truth table has $2^300$ rows (more than atoms in the universe), but a proof might take 50 lines.
Same question, vastly different computational cost.

*Reason 2 --- The gap appears later:*
For first-order logic over arithmetic, Gödel's Incompleteness Theorem shows there are true statements that _no_ proof system can derive: $entails subset.neq models$.
When this gap opens, confusing the two perspectives leads to fundamental errors.

#Block(color: yellow)[
  *Bottom line:*
  - Semantics asks _"Is it true?"_ (check all interpretations).
  - Syntax asks _"Can I derive it?"_ (apply inference rules mechanically).

  For PL, both always give the same answer.

  However, we _train the distinction now_ so it is natural when it matters.
]

== PL Syntax

Propositional logic studies _Boolean combinations_ of atomic statements. \
Its syntax defines which strings are "legal" formulas:

#definition[Well-Formed Formula (WFF)][
  Given propositional variables $P, Q, R, dots$ and constants $top, bot$, the set of _well-formed formulas_ is defined inductively:
  + Every propositional variable and constant is a WFF.
  + If $alpha$ and $beta$ are WFFs, then $not alpha$, $(alpha and beta)$, $(alpha or beta)$, $(alpha imply beta)$, $(alpha iff beta)$ are WFFs.
  + Nothing else is a WFF.
]

*Conventions:* \
Operator precedence: $not thick > thick and thick > thick or thick > thick imply thick > thick iff$. \
Outer parentheses omitted. Associativity: $and$, $or$ left-to-right; $imply$ right-to-left.

#example[
  A Boolean guard `if (x > 0 && !done)` in a program corresponds to the propositional formula $P and not Q$, where $P$ stands for `x > 0` and $Q$ for `done`.
  This is a WFF by rule 2.
]

== PL Semantics

#definition[
  An _interpretation_ (valuation) $nu: V to {0, 1}$ assigns a truth value to each propositional variable.
]

The _evaluation_ $Eval(alpha)$ of a formula $alpha$ under $nu$ is defined recursively:
$
               Eval(top) & = 1, quad Eval(bot) = 0, quad Eval(P) = nu(P) \
         Eval(not alpha) & = 1 - Eval(alpha) \
    Eval(alpha and beta) & = min(Eval(alpha), Eval(beta)) \
     Eval(alpha or beta) & = max(Eval(alpha), Eval(beta)) \
  Eval(alpha imply beta) & = max(1 - Eval(alpha), Eval(beta))
$

#definition[
  An interpretation $nu$ _satisfies_ a formula $alpha$, written $nu models alpha$, if $Eval(alpha) = 1$.

  A _model_ of $alpha$ is any interpretation that satisfies it.
]

#Block(color: orange)[
  *Terminology note:* The word "model" appears in many distinct contexts:
  - *PL model* = an interpretation (truth assignment) satisfying a formula.
  - *FOL model* = a structure (domain + interpretation of symbols) satisfying sentences.
  - *Model checking* = algorithmic verification technique (checking if a system model satisfies a temporal property).

  In this course, context determines which meaning applies. \
  For now, "model" = satisfying interpretation.
]

#example[
  Let $nu(P) = 1, nu(Q) = 0$.
  - Then $Eval(P imply Q) = max(1 - 1, 0) = 0$ and $Eval(not P or Q) = max(0, 0) = 0$.
  - Both agree, as expected from the equivalence $(P imply Q) equiv (not P or Q)$.

  Since $Eval(P imply Q) = 0$, we say $nu models.not (P imply Q)$ --- this interpretation is _not_ a model of $P imply Q$.
]

#pagebreak()

#example[
  Let $nu(A) = 1, nu(B) = 0, nu(C) = 1$. Evaluate $A and (B or C)$:
  $
            Eval(B or C) & = max(0, 1) = 1 \
    Eval(A and (B or C)) & = min(1, 1) = 1
  $
  The formula is _satisfied_ by this interpretation: $nu models A and (B or C)$.
  So $nu$ is a _model_ of $A and (B or C)$.
]

== Semantic Classification

Formulas are classified by their truth behavior across _all_ interpretations:

#definition[Semantic Classification][
  Let $alpha$ be a WFF.
  - $alpha$ is *valid* (_tautology_), written $models alpha$, if _every_ interpretation is a model: $nu models alpha$ for all $nu$.
  - $alpha$ is *satisfiable* (_consistent_) if it has _at least one_ model: $nu models alpha$ for some $nu$.
  - $alpha$ is *unsatisfiable* (_contradiction_) if it has _no_ models: $nu models.not alpha$ for all $nu$.
  - $alpha$ is *falsifiable* if some interpretation is _not_ a model: $nu models.not alpha$ for some $nu$.
]

#example[
  - $P or not P$ --- valid (tautology). _Every_ interpretation is a model.
  - $P and Q$ --- satisfiable (has model $nu(P) = nu(Q) = 1$) and falsifiable (non-model $nu(P) = 1, nu(Q) = 0$). This is _contingent_.
  - $P and not P$ --- unsatisfiable. _No_ model exists.
]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    rect((0, 0), (9, 4), stroke: 1pt + blue, fill: blue.lighten(90%), radius: 3pt, name: "all")
    content("all.north", [*All formulas*], anchor: "north", padding: 0.2)

    rect((0.2, 0.2), (6, 3.2), stroke: 1pt + green, fill: green.lighten(85%), radius: 5pt, name: "sat")
    content("sat.north", [*Satisfiable*], anchor: "north", padding: 0.2)

    circle((1.6, 1.4), radius: (1.2, 0.8), stroke: 1pt + purple, fill: purple.lighten(85%), name: "taut")
    content("taut", [Tautologies])

    rect((3, 0.4), (5.8, 2.4), stroke: 1pt + orange, fill: orange.lighten(85%), radius: 3pt, name: "cont")
    content("cont", [Contingent])

    circle((7.5, 1.4), radius: (1.2, 0.8), stroke: 1pt + red, fill: red.lighten(85%), name: "contra")
    content("contra", [Contra-\ dictions])
  })
]

== Entailment vs Implication

#definition[Semantic Entailment][
  A set of formulas $Gamma$ _semantically entails_ $alpha$, written $Gamma models alpha$, if every model of $Gamma$ is also a model of $alpha$.

  Equivalently: every interpretation satisfying all formulas in $Gamma$ also satisfies $alpha$.
]

These two notions --- _implication_ and _entailment_ --- are distinct but deeply related:

*Implication ($imply$)* is a _connective_ --- an operator _inside_ the language of propositional logic.
- $P imply Q$ is a well-formed formula with a truth value under each interpretation.
- It can appear in compound formulas: $(P imply Q) and R$, $not (P imply Q)$, etc.
- Defined by a truth table: $Eval(P imply Q) = max(1 - Eval(P), Eval(Q))$.

*Entailment ($models$)* is a _metalogical_ relation --- a claim _about_ formulas from outside the logic.
- $P models Q$ is _not_ a formula; it is a mathematical statement about all interpretations.
- It cannot be negated or combined using logical connectives.
- Defined by quantifying over models: _"every model of $P$ is also a model of $Q$."_

#Block(color: orange)[
  *Common mistake:* writing $P models Q$ when you mean $P imply Q$, or vice versa.

  One ($imply$) is a formula you can evaluate; the other ($models$) is a claim you prove.
]

#Block(color: yellow)[
  *Why distinguish them?* In propositional logic, they coincide (via the Deduction Theorem).
  But in first-order logic and beyond, the distinction becomes crucial: some truths are not provable, and the syntactic world ($entails$) diverges from the semantic world ($models$).
]

#Block(color: teal)[
  For PL, these two worlds coincide perfectly: $\"entails\" <==> \"models\"$.
  For first-order logic, Gödel showed that in specific theories (like Peano Arithmetic), _true_ sentences can be _unprovable_ --- the syntactic and semantic worlds diverge. We will see this precisely in the Metatheorems section.
]

#pagebreak()

#theorem[Deduction Theorem (Semantic)][
  For any formulas $alpha, beta$:
  $ alpha models beta quad iff quad models alpha imply beta $
]

#proof[($arrow.double.r$)][
  Assume $alpha models beta$.
  We must show $models alpha imply beta$.

  Let $nu$ be any interpretation.
  We show $nu models alpha imply beta$.
  - If $nu models.not alpha$, then $Eval(alpha imply beta) = max(0, Eval(beta)) = 1$, so $nu models alpha imply beta$.
  - If $nu models alpha$, then since $alpha models beta$, we have $nu models beta$, so $Eval(alpha imply beta) = max(0, 1) = 1$.

  In both cases, $nu models alpha imply beta$.
  Since $nu$ was arbitrary, $alpha imply beta$ is valid.
]
#proof[($arrow.double.l$)][
  Assume $models alpha imply beta$.
  We must show $alpha models beta$.

  Let $nu$ be a model of $alpha$, i.e., $nu models alpha$.
  Since $alpha imply beta$ is valid, $nu models alpha imply beta$.
  By the definition of $imply$: $max(1 - Eval(alpha), Eval(beta)) = 1$.
  Since $Eval(alpha) = 1$, we have $max(0, Eval(beta)) = 1$, so $Eval(beta) = 1$, i.e., $nu models beta$.

  Thus every model of $alpha$ is a model of $beta$.
]

The Deduction Theorem connects semantic entailment to formula validity --- it lets us reduce the question _"does $alpha$ entail~$beta$?"_ to _"is $alpha imply beta$ valid?"_
This reduction is what makes automated validity checking possible: entailment becomes a satisfiability check.

#example[
  ${P, P imply Q} models Q$ #h(2em) (modus ponens as entailment)

  *Via Deduction Theorem:* This is equivalent to $P and (P imply Q) imply Q$ being valid.

  Check: any interpretation either falsifies $P and (P imply Q)$ (making the implication vacuously true), or satisfies both $P$ and $P imply Q$, in which case it must satisfy $Q$ (by the truth table for $imply$).
]

#example[
  $not (P and Q) models not P or not Q$ #h(2em) (De Morgan, semantic form)

  *Via Deduction Theorem:* Equivalent to $models not (P and Q) imply (not P or not Q)$, which is a tautology.
]

#pagebreak()

#theorem[Generalized Deduction Theorem][
  For any set of formulas $Gamma$ and formulas $alpha, beta$:
  $ Gamma union {alpha} models beta quad iff quad Gamma models alpha imply beta $
]

#proof[($arrow.double.r$)][
  Assume $Gamma union {alpha} models beta$.
  Let $nu$ be a model of $Gamma$. We show $nu models alpha imply beta$.
  - If $nu models.not alpha$, then $nu models alpha imply beta$ (vacuously).
  - If $nu models alpha$, then $nu$ models all formulas in $Gamma union {alpha}$, so by assumption $nu models beta$, hence $nu models alpha imply beta$. #qedhere
]
#proof[($arrow.double.l$)][
  Assume $Gamma models alpha imply beta$.
  Let $nu$ be a model of $Gamma union {alpha}$.
  Then $nu models Gamma$, so $nu models alpha imply beta$ by assumption.
  Since $nu models alpha$, we have $nu models beta$ by modus ponens.
]

#note[
  This theorem justifies the _hypothetical reasoning_ pattern: to show $Gamma models alpha imply beta$, it suffices to show $Gamma union {alpha} models beta$ --- i.e., _"assume $alpha$ as an additional hypothesis and derive $beta$."_
]

== SAT vs VALID Duality

Satisfiability and validity are _dual_ decision problems:

$
    "SAT:" quad & exists nu. thin nu models alpha quad "(find a model)" \
  "VALID:" quad & forall nu. thin nu models alpha quad "(every interpretation is a model)"
$

#Block(color: blue)[
  $alpha$ is valid $quad iff quad not alpha$ is unsatisfiable.
]

#example[
  $P or not P$ is valid $iff$ $not (P or not P) equiv P and not P$ is unsatisfiable.
]

#Block(color: yellow)[
  Checking SAT by truth tables takes $cal(O)(2^n)$ time. \
  Is there a polynomial algorithm?
  _This is the P vs NP problem_ --- a Millennium Prize question.
]

== Fundamental Equivalence Laws

#Block[
  $alpha equiv beta$ iff $alpha iff beta$ is a tautology.
]

These equivalences form the _toolkit_ for normal form transformations.
Every conversion (NNF, CNF, DNF) is a sequence of applications of these rewriting rules:

#grid(
  columns: 3,
  column-gutter: 2em,
  row-gutter: 0.5em,
  [
    *Double Negation:*
    - $not not A equiv A$

    *De Morgan's Laws:*
    - $not (A and B) equiv not A or not B$
    - $not (A or B) equiv not A and not B$

    *Implication:*
    - $(A imply B) equiv (not A or B)$
  ],
  [
    *Distributivity:*
    - $A and (B or C) equiv (A and B) or (A and C)$
    - $A or (B and C) equiv (A or B) and (A or C)$

    *Contraposition:*
    - $(A imply B) equiv (not B imply not A)$
  ],
  [
    *Identity:*
    - $A and top equiv A$
    - $A or bot equiv A$

    *Complement:*
    - $A and not A equiv bot$
    - $A or not A equiv top$

    *Exportation:*
    - $(A and B) imply C equiv A imply (B imply C)$
  ],
)

== Completeness of Connective Sets

For $n$ Boolean variables, there are $2^(2^n)$ possible Boolean functions.

How many connectives do we _really_ need?

#definition[Functional Completeness][
  A set $S$ of connectives is _functionally complete_ if every Boolean function can be expressed using only connectives from $S$.
]

#example[
  - ${not, and, or}$ --- the standard Boolean basis.
  - ${not, and}$ --- And-Inverter Graphs (AIGs), used in hardware verification.
  - ${not, or}$
  - ${overline(and)}$ --- NAND alone suffices.
  - ${overline(or)}$ --- NOR alone suffices.
]

#example[${and, imply}$ is _not_ complete.][
  Let $alpha$ be any WFF using only $and$ and $imply$, and let $nu$ assign $1$ to every variable.
  By structural induction, $Eval(alpha) = 1$ for all such $alpha$. \
  But $not P$ evaluates to $0$ under this $nu$ --- so $not P$ is not expressible.
]

#Block(color: blue)[
  *Why FM cares:*
  In hardware verification, circuits are built from NAND/NOR gates --- completeness guarantees these gates can implement _any_ Boolean function.
  In SAT solving, CNF uses only ${not, and, or}$ --- so no expressiveness is lost.
]

= Normal Forms

== Why Normal Forms?

We know PL formulas can express any Boolean function.
But SAT solvers don't accept _arbitrary_ formulas --- they need a standardized input format.
Normal forms provide exactly this: every formula is rewritten into a restricted shape that algorithms can uniformly process.

Three normal forms, each with different trade-offs:
- *Negation Normal Form (NNF)* --- negations pushed to atoms; cheap to compute, preserves structure
- *Conjunctive Normal Form (CNF)* --- conjunction of clauses; _the language of SAT solvers_
- *Disjunctive Normal Form (DNF)* --- disjunction of cubes; dual of CNF

Every propositional formula can be converted to an _equivalent_ formula in any of these forms.
The key question is: _at what cost?_

== Literals and Their Complements

#definition[Literal][
  A _literal_ is a propositional variable ($p$ --- _positive_) or its negation ($not p$ --- _negative_).
]

#definition[Complement][
  The _complement_ of a literal $ell$ is denoted $overline(ell)$:
  $
    overline(ell) = cases(
      not p & "if" ell equiv p quad "(positive)",
      p & "if" ell equiv not p quad "(negative)"
    )
  $
  Complementary literals $ell$ and $overline(ell)$ always satisfy $ell and overline(ell) equiv bot$ and $ell or overline(ell) equiv top$.
]

== Clauses and Cubes

#definition[Clause][
  A _clause_ is a disjunction of literals: $ell_1 or ell_2 or dots or ell_k$.
  - An _empty clause_ $square$ contains no literals and is _unsatisfiable_ (false in every interpretation).
  - A _unit clause_ contains exactly one literal.
  - A _Horn clause_ contains at most one positive literal.
]

#definition[Cube][
  A _cube_ is a conjunction of literals: $ell_1 and ell_2 and dots and ell_k$.
]

Clauses and cubes are _dual_ notions:
- A clause is _falsified_ only if _every_ literal in it is false.
- A cube is _satisfied_ only if _every_ literal in it is true.

#Block(color: teal)[
  *Horn clauses* are computationally special: SAT restricted to Horn clauses is solvable in _linear time_ via unit propagation. Prolog's inference engine works exclusively with Horn clauses.
]

== Negation Normal Form

#definition[Negation Normal Form (NNF)][
  A formula is in NNF if:
  + Negation ($not$) is applied only to _atoms_ (propositional variables).
  + The only connectives are $and$, $or$, and $not$ (applied to atoms).
]

*Grammar:*
$
  chevron.l "Atom" chevron.r &::= top | bot | chevron.l "Variable" chevron.r \
  chevron.l "Literal" chevron.r &::= chevron.l "Atom" chevron.r | not chevron.l "Atom" chevron.r \
  chevron.l "Formula" chevron.r &::= chevron.l "Literal" chevron.r | chevron.l "Formula" chevron.r and chevron.l "Formula" chevron.r | chevron.l "Formula" chevron.r or chevron.l "Formula" chevron.r
$

In words: only $and$, $or$, and negation applied directly to variables --- no $imply$, no $iff$, no nested $not$.

#example[
  - $(p and q) or (not p and not q)$ --- in NNF. #h(2em)
  - $not (p and q)$ --- _not_ in NNF (negation applied to a compound formula).
]

== NNF Transformation

Rewriting rules (apply until no rule matches):

#align(center)[
  #table(
    columns: 2,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Description*][*Rewrite rule*],
    [Eliminate implications], [$(A imply B) rewrite (not A or B)$],
    [Eliminate biconditionals], [$(A iff B) rewrite (not A or B) and (A or not B)$],
    [De Morgan (conjunction)], [$not (A and B) rewrite (not A or not B)$],
    [De Morgan (disjunction)], [$not (A or B) rewrite (not A and not B)$],
    [Double negation], [$not not A rewrite A$],
  )
]

#theorem[
  Every formula _not containing_ $iff$ can be converted to an equivalent NNF with a _linear increase_ in size.

  Formulas _containing_ $iff$ may suffer _exponential blowup_ when converted to NNF.
]

Why the blowup?
The biconditional $A iff B$ expands to $(not A or B) and (A or not B)$ --- producing _two copies_ of $A$ and $B$.
A chain of $n$ biconditionals $p_1 iff p_2 iff dots iff p_n$ doubles the formula at each level, producing $2^n$ copies.
The Tseitin transformation (coming soon) avoids this.

== NNF Transformation: Worked Example

Convert $(P imply Q) imply R$ to NNF step by step:

$
               & (P imply Q) imply R \
  rewrite quad & not (P imply Q) or R       & "(eliminate outer" imply")" \
  rewrite quad & not (not P or Q) or R      & "(eliminate inner" imply")" \
  rewrite quad & (not not P and not Q) or R &               "(De Morgan)" \
  rewrite quad & (P and not Q) or R         &         "(Double negation)"
$

Result: $(P and not Q) or R$ --- negations only on atoms.

== Conjunctive Normal Form

#definition[Conjunctive Normal Form (CNF)][
  A formula is in CNF if it is a conjunction of clauses:
  $
    alpha = and.big_i or.big_j ell_(i j)
  $
]

#example[
  $alpha = (not p or q) and (not p or q or r) and (not q)$ --- CNF with 3 clauses.
]

*Why CNF?*
Every modern SAT solver (MiniSat, CaDiCaL, Kissat) operates on CNF.
Satisfaction requires _at least one_ literal per clause --- this "one per clause" structure is what makes unit propagation and resolution work.

== Disjunctive Normal Form

#definition[Disjunctive Normal Form (DNF)][
  A formula is in DNF if it is a disjunction of cubes:
  $
    alpha = or.big_i and.big_j ell_(i j)
  $
]

#example[
  $alpha = (p and q) or (not p and q and r) or (not q)$ --- DNF with 3 cubes.
]

*CNF vs DNF --- dual complexities:*

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Problem*][*On CNF*][*On DNF*],
    [SAT check], [NP-complete], [Polynomial],
    [VALID check], [Polynomial], [co-NP-complete],
  )
]

- SAT on DNF is polynomial: check if any cube has no complementary literals.
- VALID on CNF is polynomial: check if every clause contains complementary literals.

== CNF Transformation

Any formula can be converted to CNF:
+ Apply NNF transformation rules.
+ Distribute $or$ over $and$ (flattening):
  - $A or (B and C) rewrite (A or B) and (A or C)$
  - $(A and B) or C rewrite (A or C) and (B or C)$
+ Normalize: flatten nested $and$ and $or$.

#theorem[
  Every formula can be converted to an _equivalent_ CNF, but the size may grow _exponentially_.
]

The _distributive law_ is the culprit:
$
  underbrace((x_1 and y_1) or (x_2 and y_2) or dots or (x_n and y_n), n "cubes")
  quad rewrite^"CNF" quad
  underbrace(dots, 2^n "clauses")
$

*Question:* Can we avoid this blowup? _Yes --- by relaxing "equivalence" to "equisatisfiability"._

== Equisatisfiability

#definition[
  Two formulas $alpha$ and $beta$ are _equisatisfiable_ if $alpha$ is satisfiable iff $beta$ is satisfiable.
]

#note[
  Equisatisfiability is _weaker_ than logical equivalence.
  For SAT solving, equisatisfiability suffices --- we only care _whether_ a satisfying assignment exists.
  Any model of the equisatisfiable formula can be _restricted_ to the original variables.
]

#example[
  $P and Q$ and $(P and Q) and (n iff P)$ are equisatisfiable but _not_ equivalent --- the second formula has an extra variable $n$ and is defined over a strictly larger language.
]

== Tseitin Transformation

#definition[
  The _Tseitin transformation_ converts any formula to CNF in _polynomial time_ by introducing _fresh_ variables.

  For each non-literal subformula $A$ of a formula $F$:
  + Introduce a fresh propositional variable $n_A$.
  + Add a _definitional clause_ $n_A iff A$ (asserting equivalence).
  + Replace $A$ with $n_A$ in $F$.

  The resulting formula is _equisatisfiable_ with the original:
  - Every model of $F$ extends to a model of the Tseitin encoding.
  - Every model of the encoding restricted to original variables satisfies $F$.
]

#pagebreak()

=== Cost

- $cal(O)(n)$ fresh variables and $cal(O)(n)$ clauses, where $n$ is the formula size.
- Each definitional clause $n iff A$ for a binary connective produces a _constant number_ of clauses.

#example[
  The definition $n iff (A and B)$ is equivalent to:
  $
    (n imply (A and B)) and ((A and B) imply n)
    quad equiv quad
    (not n or A) and (not n or B) and (not A or not B or n)
  $
  That is: 3 clauses.
]

== Tseitin Transformation: Example

#example[
  $F = p_1 iff (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))$

  *Equivalent CNF*: $2^5 = 32$ clauses (exponential).

  *Tseitin transformation*: introduce fresh variables $n_3, n_4, n_5$:
  $
    S = & p_1 iff (p_2 iff n_3) & and \
        & n_3 iff (p_3 iff n_4) & and \
        & n_4 iff (p_4 iff n_5) & and \
        & n_5 iff (p_5 iff p_6)
  $

  Each biconditional definition produces a constant number of clauses (4 clauses for $iff$).

  *Equisatisfiable CNF*: $16$ clauses, 3 fresh variables. _Linear growth._
]

== Clausal Form

#definition[Clausal Form][
  A _clausal form_ of a formula $F$ is a _set_ of clauses $S_F$ which is satisfiable iff $F$ is satisfiable.
  Moreover, $F$ and $S_F$ have the same models when restricted to the language of $F$.
]

The main advantage: any formula can be converted to clausal form in _almost linear_ time.

*Algorithm:*
+ If $F = C_1 and dots and C_n$ where each $C_i$ is already a clause, then $S_F = {C_1, dots, C_n}$.
+ Otherwise, apply Tseitin transformation: name each non-literal subformula with a fresh variable.

#Block(color: yellow)[
  *Key insight:* The clausal form is the bridge between arbitrary formulas and SAT solvers.
  It preserves satisfiability while keeping the representation compact.
]

= Proof Systems

== Why Proof Systems?

Clausal form gives us the _input format_ for SAT solvers.
But before we build solvers (next lecture), we need to understand what it means to _prove_ things mechanically --- that is the purpose of proof systems.

Truth tables require $2^n$ rows for $n$ variables.
For 300 variables (modest by industrial standards), that exceeds the number of atoms in the universe.

Proof systems _derive_ validity step by step using inference rules.
A clever proof can be _exponentially shorter_ than brute-force enumeration.

#definition[
  A *proof system* derives valid formulas (or entailments) by applying _inference rules_ to _axioms_ and _assumptions_.
]

Three main traditions:
- *Hilbert-style:* many axiom schemas, one rule (modus ponens). Compact to define, hard to use.
- *Natural deduction* (Gentzen, 1934): no axioms, intro/elim rules per connective. _Our primary tool._
- *Sequent calculus* (Gentzen, 1934): manipulates structured judgments. Foundation of automated proof search.

== Natural Deduction

#import frederic: assume, fitch, premise, step, subproof

A proof system with _no axioms_ --- only inference rules.
Each connective has _introduction_ rules (*how to build* a compound formula) and _elimination_ rules (*how to use* one).

We present proofs in *Fitch notation*: a numbered list of steps.
Each step contains a formula and a _justification_ (the rule applied + referenced line numbers).

_Subproofs_ (indented blocks) introduce a _temporary assumption_.
Everything derived inside a subproof depends on that assumption.
When the subproof closes, the assumption is _discharged_ --- you may no longer cite its internal lines, but you can reference the subproof _as a whole_.

#Block(color: yellow)[
  *Mental model:* A subproof says _"if I temporarily assume $alpha$, I can derive $beta$."_ \
  When it closes, you conclude $alpha imply beta$ --- without assuming $alpha$ anymore.
]

== Conjunction and Implication Rules

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$and$-introduction* ($and$i): \
    From $alpha$ and $beta$ on separate lines, \
    conclude $alpha and beta$.

    #fitch(
      premise(1, $alpha$),
      premise(2, $beta$),
      step(3, $alpha and beta$, rule: [$and$i 1, 2]),
    )
  ],
  [
    *$and$-elimination* ($and$e): \
    From $alpha and beta$, conclude $alpha$ (or $beta$).

    #fitch(
      premise(1, $alpha and beta$),
      step(2, $alpha$, rule: [$and$e 1]),
      step(3, $beta$, rule: [$and$e 1]),
    )
  ],
)

#pagebreak()

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$imply$-introduction* ($imply$i): \
    Open a subproof assuming $alpha$, derive $beta$. \
    Close subproof, conclude $alpha imply beta$.

    #fitch(
      subproof(
        assume(1, $alpha$, rule: [assumption]),
        step(2, $dots.v$),
        step(3, $beta$, rule: [$dots.v$]),
      ),
      step(4, $alpha imply beta$, rule: [$imply$i 1--3]),
    )
  ],
  [
    *$imply$-elimination* ($imply$e): \
    Modus ponens. \
    From $alpha$ and $alpha imply beta$, conclude $beta$.

    #fitch(
      premise(1, $alpha$),
      premise(2, $alpha imply beta$),
      step(3, $beta$, rule: [$imply$e 1, 2]),
    )
  ],
)

== Disjunction Rules

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$or$-introduction* ($or$i): \
    From $alpha$, conclude $alpha or beta$ (or $beta or alpha$).

    #fitch(
      premise(1, $alpha$),
      step(2, $alpha or beta$, rule: [$or$i 1]),
    )
  ],
  [
    *$or$-elimination* ($or$e): \
    From $alpha or beta$, with subproofs deriving $gamma$ from each disjunct, conclude $gamma$.

    #fitch(
      premise(1, $alpha or beta$),
      subproof(
        assume(2, $alpha$, rule: [assumption]),
        step(3, $gamma$, rule: [$dots.v$]),
      ),
      subproof(
        assume(4, $beta$, rule: [assumption]),
        step(5, $gamma$, rule: [$dots.v$]),
      ),
      step(6, $gamma$, rule: [$or$e 1, 2--3, 4--5]),
    )
  ],
)

== Negation and Absurdity Rules

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$not$-introduction* ($not$i): \
    Assume $alpha$, derive $bot$ (contradiction). \
    Close subproof, conclude $not alpha$.

    #fitch(
      subproof(
        assume(1, $alpha$, rule: [assumption]),
        step(2, $dots.v$),
        step(3, $bot$, rule: [$dots.v$]),
      ),
      step(4, $not alpha$, rule: [$not$i 1--3]),
    )
  ],
  [
    *$not$-elimination* ($not$e): \
    From $alpha$ and $not alpha$, derive $bot$.

    #fitch(
      premise(1, $alpha$),
      premise(2, $not alpha$),
      step(3, $bot$, rule: [$not$e 1, 2]),
    )
  ],
)

#pagebreak()

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$bot$-elimination* (ex falso quodlibet, $bot$e): \
    From $bot$, derive _any_ formula.

    #fitch(
      premise(1, $bot$),
      step(2, $alpha$, rule: [$bot$e 1]),
    )
  ],
  [
    *Reductio ad absurdum* (RAA): \
    Assume $not alpha$, derive $bot$. Conclude $alpha$.

    #fitch(
      subproof(
        assume(1, $not alpha$, rule: [assumption]),
        step(2, $dots.v$),
        step(3, $bot$, rule: [$dots.v$]),
      ),
      step(4, $alpha$, rule: [RAA 1--3]),
    )
  ],
)

#v(-0.5em)
#Block(color: yellow)[
  *Classical vs Intuitionistic:* RAA and LEM ($alpha or not alpha$) are _classical_ rules.
  Dropping them gives _intuitionistic_ logic, where $P or not P$ is not provable.
]

#place[
  #v(0.7em)
  #Block[
    *Two key proof patterns* that cover the majority of ND proofs:
    - To prove $not phi$: assume $phi$, derive $bot$, apply $not$i.
    - To prove $alpha imply beta$: assume $alpha$, derive $beta$, apply $imply$i.
  ]
]

== Fitch Proofs: Basic Examples

#example[
  *Conjunction rearrangement:* $p and q, thin r entails q and r$

  #align(center)[
    #fitch(
      premise(1, $p and q$),
      premise(2, $r$),
      step(3, $q$, rule: [$and$e 1]),
      step(4, $q and r$, rule: [$and$i 3, 2]),
    )
  ]

  Each step cites the rule and the line numbers it depends on.
  Line 3 _eliminates_ the conjunction to extract $q$; line 4 _introduces_ a new conjunction.
]

#pagebreak()

#example[
  *Modus Tollens:* $A imply B, thin not B entails not A$

  #align(center)[
    #fitch(
      premise(1, $A imply B$),
      premise(2, $not B$),
      subproof(
        assume(3, $A$, rule: [assumption]),
        step(4, $B$, rule: [$imply$e 3, 1]),
        step(5, $bot$, rule: [$not$e 4, 2]),
      ),
      step(6, $not A$, rule: [$not$i 3--5]),
    )
  ]

  Lines 3--5 form a _subproof_: we temporarily assume $A$, derive $bot$, then discharge the assumption to conclude $not A$ via $not$i.
  The vertical bar shows the scope of the assumption --- lines 4 and 5 are only accessible _within_ the subproof.
]

== Fitch Proofs: Implication Chains

#example[
  *Hypothetical Syllogism:* $A imply B, thin B imply C entails A imply C$

  #align(center)[
    #fitch(
      premise(1, $A imply B$),
      premise(2, $B imply C$),
      subproof(
        assume(3, $A$, rule: [assumption]),
        step(4, $B$, rule: [$imply$e 3, 1]),
        step(5, $C$, rule: [$imply$e 4, 2]),
      ),
      step(6, $A imply C$, rule: [$imply$i 3--5]),
    )
  ]

  To prove an implication $A imply C$, we _assume_ $A$ (line 3), derive $C$ (line 5), and close with $imply$i.
]

#note[
  More worked Fitch proofs (disjunctive syllogism, De Morgan) appear in the exercises.
  The key patterns: $or$-elimination requires two subproofs (one per disjunct); $not$-introduction assumes $phi$, derives $bot$, concludes $not phi$.
]

== Soundness and Completeness

#definition[Soundness][
  A proof system is _sound_ if every provable formula is valid:
  #align(center)[
    If $Gamma entails alpha$ then $Gamma models alpha$. #h(2em) (Nothing false is provable.)
  ]
]

#definition[Completeness][
  A proof system is _complete_ if every valid formula is provable:
  #align(center)[
    If $Gamma models alpha$ then $Gamma entails alpha$. #h(2em) (Nothing true is unprovable.)
  ]
]

#theorem[
  Propositional natural deduction is both _sound_ and _complete_.
  $
    Gamma entails alpha quad iff quad Gamma models alpha
  $
]

#proof[
  _(Soundness.)_
  By induction on the derivation.
  Each inference rule preserves validity: a small truth-table check per rule.

  _(Completeness.)_
  Build a derivation by induction on $alpha$'s structure, case-splitting on which variables $Gamma$ forces.
  _(Kalmár, 1935.)_
]

#Block(color: yellow)[
  Soundness: verified properties _actually hold_.
  Completeness: every true property _can_ be proven.
]

== Proof Strategies

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Forward reasoning* (bottom-up):
    - Start from premises $Gamma$
    - Apply rules to derive new facts
    - Continue until $alpha$ is derived
    - Risk: combinatorial explosion
  ],
  [
    *Refutation* (top-down):
    - Assume $not alpha$ together with $Gamma$
    - Derive a contradiction ($bot$)
    - Conclude that $alpha$ must hold
    - Advantage: _goal-directed_ search
  ],
)

Refutation is the basis for _automated_ reasoning:
searching for a contradiction in $Gamma union {not alpha}$ is equivalent to a SAT problem.

#note(title: "Other proof systems")[
  _Semantic tableaux_ (truth trees) are another refutation-based method: negate the goal, decompose formulas, and check if every branch closes.
  Open branches yield counterexamples.
  We skip the details --- resolution (below) is more directly relevant to SAT solving.
]

#Block(color: yellow)[
  *Bridge to automated reasoning:* Resolution is the foundation of SAT solvers. Unlike natural deduction (designed for humans), resolution has a single rule — perfect for implementation.
]

== Resolution

_Resolution_ reduces propositional proof theory to a single inference rule, but requires _clausal form_ (CNF).
This makes it the natural foundation for automated theorem proving.

#Block(color: teal)[
  Introduced by J. Alan Robinson (1965).
  Modern CDCL solvers maintain resolution proofs implicitly --- learned clauses _are_ resolution steps.
]

#definition[Resolution Rule][
  Given two clauses containing complementary literals:
  $
    C_1 = (ell_1 or dots or ell_m or p) quad "and" quad C_2 = (ell'_1 or dots or ell'_k or not p)
  $
  derive the _resolvent_:
  $
    C = C_1 times.o_p C_2 = ell_1 or dots or ell_m or ell'_1 or dots or ell'_k
  $
  The variable $p$ is called the _pivot_.
]

#example[
  $(not P or Q)$ and $(P or R)$ resolve on $P$ to produce $(Q or R)$.
]

Resolution is a _refutation_ system: to prove $Gamma models alpha$, convert $Gamma union {not alpha}$ to CNF and derive the _empty clause_ $square$.

== Resolution Refutation: Example

*Prove by resolution:* ${P, thin P imply Q} models Q$.

Add $not Q$ (negation of goal) and convert to clauses:

$
  C_1 & = {P}             &                          "(from " P ")" \
  C_2 & = {not P, Q} quad & "(from " P imply Q equiv not P or Q ")" \
  C_3 & = {not Q}         &                    "(negation of goal)"
$

Derive:

$
  C_4 & = {Q}    & "resolve" C_1 "and" C_2 "on" P \
  C_5 & = square & "resolve" C_4 "and" C_3 "on" Q
$

The empty clause $square$ is derived $=>$ the original entailment holds. #h(1fr)$square$

#pagebreak()

#theorem[Completeness of Resolution][
  Resolution is _refutation-complete_: a set of clauses $S$ is unsatisfiable if and only if the empty clause $square$ can be derived from $S$ by resolution.
]

#Block(color: blue)[
  *Why this matters for SAT solving:*
  Every CDCL solver is _implicitly_ building a resolution proof.
  When a solver reports UNSAT, its learned clauses form a resolution refutation.
  This is how SAT solvers produce _verifiable certificates_ of unsatisfiability --- a crucial property for trustworthy verification.
]

== Proof Systems: Comparison

#align(center)[
  #table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*System*][*Human-friendly*][*Automateable*][*For SAT*][*Certify UNSAT*],
    [Truth tables], [Medium], [Trivial], [No], [No],
    [Natural Deduction], [High], [Low], [No], [No],
    [Semantic Tableaux], [Medium], [Medium], [Partial], [Yes],
    [Resolution], [Low], [High], [Yes], [Yes],
  )
]

Progression from left to right mirrors the course: human methods $=>$ machine methods.

SAT solvers are _resolution engines_ augmented with heuristics (VSIDS, restarts, phase saving).

= First-Order Logic: A Taste

== Why First-Order Logic?

Propositional logic handles Boolean constraints well, and SAT solvers are remarkably efficient.
But program _specifications_ say things like _"for all inputs $x$, if the precondition holds, the postcondition holds"_ --- we need _quantifiers_.

PL cannot express quantification over objects.
Consider _"every even number greater than 2 is a sum of two primes"_ (Goldbach's conjecture) --- PL would need a separate proposition $G_4, G_6, G_8, dots$ for each even number.

FOL adds three key ingredients:
- *Variables* ranging over objects in a domain ($x, y, z, dots$)
- *Quantifiers* ($forall, exists$) for generalization
- *Functions* and *predicates* giving structure to the domain

#example[
  "Every prime greater than 2 is odd":
  $ forall p. thin ("Prime"(p) and p > 2) imply "Odd"(p) $
  One formula replaces infinitely many propositional checks.
]

== FOL at a Glance

A first-order _signature_ $Sigma = angle.l cal(F), cal(R) angle.r$ declares function symbols (including constants) and relation symbols.
_Terms_ are built from variables and functions; _formulas_ combine terms via predicates, connectives, and quantifiers $forall, exists$.

#example[
  Over the arithmetic signature $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$:

  $forall x. thin (x = 0 or exists y. thin S(y) = x)$ --- "every natural number is $0$ or a successor."
]

A _structure_ (model) $frak(A)$ gives meaning to the symbols: a domain $A$, concrete functions, concrete relations.
The _same_ formula can be true in one structure and false in another --- _validity_ means truth in _all_ structures.

#Block(color: orange)[
  *PL vs FOL:*
  In PL, the space of interpretations is finite ($2^n$ truth assignments) --- decidable.
  In FOL, structures can have _infinite_ domains --- validity is _undecidable_ (Church--Turing, 1936).
]

== FOL: Key Concepts Preview

A variable $x$ in $forall x. thin phi$ is _bound_; a variable not in scope of any quantifier is _free_.
A formula with no free variables is a _sentence_ (has a definite truth value in each structure).

#columns(2)[
  *What FOL gives us:*
  - Quantification over infinite domains
  - Predicates expressing properties
  - Functions giving structure to objects
  - Formal proofs with $forall$-intro/elim, $exists$-intro/elim

  #colbreak()

  *Key metatheorems:*
  - Gödel completeness: $entails iff models$
  - Church--Turing: validity undecidable
  - Compactness: finite character of proofs
  - Incompleteness: true $eq.not$ provable (arithmetic)
]

#Block(color: yellow)[
  *Full treatment in Weeks 4--5.* \
  FOL is the _language of specifications_ --- its decidable fragments power SMT solvers. \
  *Next:* SAT solving (Week 3). Then: FOL in full depth (Weeks 4--5).
]

= Connecting to Automated Reasoning

== From Logic to SAT Solving

The thread from logic to automated reasoning:

+ *Formulas* express constraints about system behavior and specifications.
+ *Normal forms* (especially CNF) provide the _input format_ for SAT solvers.
+ *Equisatisfiability* (Tseitin) ensures compact, polynomial-size encodings.
+ *Resolution* is the _theoretical backbone_ of DPLL and CDCL solvers.
+ *FOL and theories* motivate SMT solvers --- SAT + specialized theory reasoning.
+ *Soundness and completeness* guarantee correctness of the entire pipeline.

#theorem[Cook--Levin Theorem (1971)][
  The Boolean satisfiability problem (SAT) is *NP-complete*: every problem in NP can be reduced to SAT in polynomial time.
]

SAT is the _universal search problem_: if you can verify a solution efficiently, you can encode the search as a SAT instance.
Modern CDCL solvers routinely handle formulas with _millions_ of variables.

*Next:* SAT encodings, DPLL, CDCL, then FOL theories and SMT.

== Key Takeaways

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Propositional Logic:*
    - Syntax (WFFs) vs Semantics (truth values)
    - SAT $iff$ VALID duality via negation
    - Equivalence laws $=>$ NNF $=>$ CNF
    - Tseitin: polynomial equisatisfiable CNF
  ],
  [
    *Proof Systems:*
    - Natural deduction: intro/elim symmetry
    - Fitch notation for human-readable proofs
    - Refutation: assume $not alpha$, derive $bot$
    - Resolution: single rule on clausal form
    - Cook--Levin: SAT is NP-complete
  ],
)

#v(0.5em)

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *First-Order Logic (taste):*
    - Quantifiers ($forall$, $exists$) + predicates + functions
    - Structures give meaning to symbols
    - Same formula: true in one model, false in another
    - Full treatment in Weeks 4--5
  ],
  [
    *What's next:*
    - Week 3: SAT encodings, DPLL, CDCL
    - Weeks 4--5: FOL deep dive + metatheorems
    - Week 6: SMT = decidable fragments of FOL
    - Weeks 9--12: Dafny (verification in practice)
  ],
)

#Block(color: blue)[
  *The pipeline we build in this course:* \
  Specification $=>$ logical formula $=>$ normal form $=>$ solver (SAT/SMT) $=>$ verdict.
]

== Exercises: Propositional Logic

+ Show that ${imply, bot}$ is a functionally complete set of connectives. \
  _Hint_: Express $not p$ and $p and q$ using only $imply$ and $bot$.

+ Convert the formula $(P imply Q) imply R$ to:
  - NNF
  - CNF (using the distributive law)
  - Clausal form (using the Tseitin transformation)

+ For a chain of $n$ biconditionals $p_1 iff p_2 iff dots iff p_(n+1)$:
  - How many clauses does the _equivalent_ CNF have?
  - How many clauses does the _Tseitin_ encoding produce? Explain the asymptotic difference.

+ Show that the satisfiability problem for DNF formulas is solvable in polynomial time.

+ $star$ Show that _any_ propositional proof system has a _tautology_ whose shortest proof is exponential in the formula size (assuming NP $eq.not$ co-NP). What does this imply about the possibility of efficient general-purpose provers?

== Exercises: Proof Systems

+ Prove the following using natural deduction (Fitch notation):
  - $A imply B, thin not B thin entails thin not A$ #h(1em) _(modus tollens)_
  - $entails thin (A imply B) or (B imply A)$
  - $P imply not P thin entails thin not P$
  - $not (A and B) thin entails thin not A or not B$ #h(1em) _(De Morgan, requires classical reasoning)_

+ Construct a semantic tableau to test the validity of:
  $P imply (Q imply R) thin models thin (P imply Q) imply (P imply R)$

+ Use resolution refutation to show that ${P or Q, thin not P or R, thin not Q or R} models R$.

+ $star$ Prove that resolution is _not_ polynomially bounded: the _pigeonhole principle_ $"PHP"_n^(n+1)$ (in CNF) requires exponentially long resolution proofs. _(State the formulation and explain why this matters for SAT solving.)_
