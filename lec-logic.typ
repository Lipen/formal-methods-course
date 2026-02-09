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

#Block(color: orange, inset: 0.8em)[
  Software bugs have caused deaths, \$billion losses, and mission failures --- even when tests passed.
]

#[
  #set text(0.9em)
  #grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 1em,
    [
      *Ariane 5 (1996)*
      - Overflow in 64-bit → 16-bit conversion
      - \$370 million rocket destroyed 37 seconds after launch
      - Root cause: reused code from Ariane 4 without #box[re-verification]
    ],
    [
      *Intel FDIV Bug (1994)*
      - Pentium floating-point division error
      - Incorrect results in rare cases
      - \$475 million recall; discovered by a mathematician
    ],

    [
      *Therac-25 (1985--87)*
      - Radiation therapy machine
      - Race condition caused massive overdoses
      - At least 3 deaths, several severe injuries
    ],
    [
      *Knight Capital (2012)*
      - Faulty deployment of trading software
      - Lost \$440 million in 45 minutes
      - Bankrupt within days
    ],
  )
]

#Block(color: yellow, inset: 0.8em)[
  *Formal methods* turn correctness into a _mathematical question_ that machines can help answer.
  Instead of checking _some_ executions, we reason about _all_ of them.
]

== The Verification Spectrum

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Method*][*Rigor*][*Coverage*][*Cost*],
    [Testing], [Low], [Partial], [Low],
    [Static analysis], [Medium], [Heuristic], [Low],
    [Model checking], [High], [Exhaustive (bounded)], [Medium],
    [Deductive verification], [Highest], [Complete], [High],
  )
]

This course focuses on the _formal_ end: logic-based reasoning, decision procedures, and deductive verification.

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

== Syntax and Semantics

Propositional logic (PL) underpins everything that follows: SAT solving, SMT, Hoare logic.
The definitions here fix notation and terminology for the course.

=== Syntax

#definition[Well-Formed Formula (WFF)][
  Given propositional variables $P, Q, R, dots$ and constants $top, bot$, the set of _well-formed formulas_ is defined inductively:
  + Every propositional variable and constant is a WFF.
  + If $alpha$ and $beta$ are WFFs, then $not alpha$, $(alpha and beta)$, $(alpha or beta)$, $(alpha imply beta)$, $(alpha iff beta)$ are WFFs.
  + Nothing else is a WFF.
]

*Conventions:* \
Operator precedence: $not thick > thick and thick > thick or thick > thick imply thick > thick iff$. \
Outer parentheses omitted. Associativity: $and$, $or$ left-to-right; $imply$ right-to-left.

=== Semantics

#definition[Interpretation][
  An _interpretation_ (valuation) $nu: V to {0, 1}$ assigns a truth value to each propositional variable.
]

The _evaluation_ $Eval(alpha)$ of a formula $alpha$ under $nu$ is defined recursively:
$
  Eval(top) &= 1, quad Eval(bot) = 0, quad Eval(P) = nu(P) \
  Eval(not alpha) &= 1 - Eval(alpha) \
  Eval(alpha and beta) &= min(Eval(alpha), Eval(beta)) \
  Eval(alpha or beta) &= max(Eval(alpha), Eval(beta)) \
  Eval(alpha imply beta) &= max(1 - Eval(alpha), Eval(beta))
$

#example[
  Let $nu(P) = 1, nu(Q) = 0$.
  Then $Eval(P imply Q) = max(1 - 1, 0) = 0$ and $Eval(not P or Q) = max(0, 0) = 0$. Both agree, as expected from the equivalence $(P imply Q) equiv (not P or Q)$.
]

== Semantic Classification

Formulas are classified by their truth behavior across _all_ interpretations:

#definition[Semantic Classification][
  Let $alpha$ be a WFF.
  - $alpha$ is *valid* (_tautology_), written $models alpha$, if $Eval(alpha) = 1$ for _all_ interpretations $nu$.
  - $alpha$ is *satisfiable* if $Eval(alpha) = 1$ for _some_ interpretation $nu$.
  - $alpha$ is *unsatisfiable* (_contradiction_) if $Eval(alpha) = 0$ for _all_ interpretations $nu$.
  - $alpha$ is *falsifiable* if $Eval(alpha) = 0$ for _some_ interpretation $nu$.
]

#example[
  - $P or not P$ --- valid (tautology). True under every interpretation.
  - $P and Q$ --- satisfiable ($nu(P) = nu(Q) = 1$) and falsifiable ($nu(P) = 1, nu(Q) = 0$). This is _contingent_.
  - $P and not P$ --- unsatisfiable. No assignment makes it true.
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
  A set of formulas $Gamma$ _semantically entails_ $alpha$, written $Gamma models alpha$, if every interpretation satisfying all formulas in $Gamma$ also satisfies $alpha$.
]

#grid(
  columns: (3fr, 4fr),
  column-gutter: 1em,
  [
    *Implication* ($imply$) is a _connective_ --- it lives _inside_ the language.
    $P imply Q$ is a WFF with a truth value under each interpretation.
  ],
  [
    *Entailment* ($models$) is a _metalogical_ relation --- it talks _about_ formulas from outside.
    $P models Q$ is not a formula; it is a mathematical claim about all interpretations.
  ],
)

#Block(color: green)[
  *Deduction Theorem (semantic):* #h(1em)
  $alpha imply beta$ is valid $quad iff quad alpha models beta$
]

#example[
  ${P, P imply Q} models Q$ #h(2em) (modus ponens as entailment)

  Equivalently: $P and (P imply Q) imply Q$ is a tautology.
]

#note[
  The _Semantic Deduction Theorem_ generalizes this:
  $ Gamma union {alpha} models beta quad iff quad Gamma models alpha imply beta $
]

== SAT vs VALID Duality

Satisfiability and validity are _dual_ decision problems:

$
    "SAT:" quad & exists nu. thin Eval(alpha) = 1 quad "(find a witness)" \
  "VALID:" quad & forall nu. thin Eval(alpha) = 1 quad "(verify universality)"
$

#Block(color: blue)[
  $alpha$ is valid $quad iff quad not alpha$ is unsatisfiable.
]

#example[
  $P or not P$ is valid $iff$ $not (P or not P) equiv P and not P$ is unsatisfiable.
]

#Block(color: yellow)[
  Checking SAT by truth tables takes $cal(O)(2^n)$ time.
  Is there a polynomial algorithm?
  _This is the P vs NP problem_ --- a Millennium Prize question.
]

== Fundamental Equivalence Laws

$alpha equiv beta$ iff $alpha iff beta$ is a tautology.
The following equivalences serve as _rewriting rules_ for normal form transformations:

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

= Normal Forms

== Why Normal Forms?

SAT solvers expect input in a specific _canonical_ syntax.
Normal forms provide this standardization: every formula is rewritten into a restricted shape that algorithms can uniformly process.

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

#example[
  $(p and q) or (not p and not q)$ --- in NNF. #h(2em)
  $not (p and q)$ --- _not_ in NNF (negation applied to a compound formula).
]

== NNF Transformation: Worked Example

Convert $(P imply Q) imply R$ to NNF step by step:

$
  & (P imply Q) imply R \
  rewrite quad & not (P imply Q) or R                        & "(eliminate outer" imply")"\
  rewrite quad & not (not P or Q) or R                        & "(eliminate inner" imply")"\
  rewrite quad & (not not P and not Q) or R                   & "(De Morgan)"\
  rewrite quad & (P and not Q) or R                           & "(Double negation)"
$

Result: $(P and not Q) or R$ --- negations only on atoms.

== NNF Transformation

Rewriting rules:

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
    [TAUT check], [Polynomial], [co-NP-complete],
  )
]

SAT on DNF is polynomial: check if any cube has no complementary literals.
TAUT on CNF is polynomial: check if every clause contains complementary literals.

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

#definition[Equisatisfiability][
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

The _Tseitin transformation_ converts any formula to CNF in _polynomial time_ by introducing _fresh_ variables.

=== Method

For each non-literal subformula $A$ of a formula $F$:
+ Introduce a fresh propositional variable $n_A$.
+ Add a _definitional clause_ $n_A iff A$ (asserting equivalence).
+ Replace $A$ with $n_A$ in $F$.

The resulting formula is _equisatisfiable_ with the original:
- Every model of $F$ extends to a model of the Tseitin encoding.
- Every model of the encoding restricted to original variables satisfies $F$.

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

Truth tables require $2^n$ rows for $n$ variables.
For 300 variables (modest by industrial standards), that exceeds the number of atoms in the universe.

Proof systems _derive_ validity step by step using inference rules.
A clever proof can be _exponentially shorter_ than brute-force enumeration.

#definition[
  A *proof system* derives valid formulas (or entailments) by applying _inference rules_ to _axioms_ and _assumptions_.
]

Three main traditions:
- *Hilbert-style:* many axiom schemas, one rule (modus ponens). Compact to define, hard to use.
- *Natural deduction* (Gentzen, 1934): no axioms, symmetric intro/elim rules per connective.
- *Sequent calculus* (Gentzen, 1934): manipulates _sequents_ $Gamma entails Delta$. Foundation of proof search.

== Natural Deduction

A proof system with _no axioms_ --- only inference rules.
Each connective has _introduction_ rules (how to prove it) and _elimination_ rules (how to use it).

// #Block(color: teal)[
//   Introduced by Gerhard Gentzen (1934).
//   The intro/elim symmetry mirrors the Curry--Howard correspondence between proofs and programs.
// ]

#let rules-grid(..args) = {
  set align(center)
  grid(
    columns: args.pos().len(),
    column-gutter: 1em,
    ..args.pos().map(arg => Block(color: green, prooftree(arg)))
  )
  v(-0.5em)
}

#rules-grid(
  rule(
    name: [$and$-intro],
    $Gamma entails alpha and beta$,
    $Gamma entails alpha$,
    $Gamma entails beta$,
  ),
  rule(
    name: [$and$-elim],
    $Gamma entails alpha$,
    $Gamma entails alpha and beta$,
  ),
  rule(
    name: [$and$-elim],
    $Gamma entails beta$,
    $Gamma entails alpha and beta$,
  ),
)

#rules-grid(
  rule(
    name: [$imply$-intro],
    $Gamma entails alpha imply beta$,
    $Gamma, alpha entails beta$,
  ),
  rule(
    name: [$imply$-elim],
    $Gamma entails beta$,
    $Gamma entails alpha$,
    $Gamma entails alpha imply beta$,
  ),
)

#rules-grid(
  rule(
    name: [$or$-intro],
    $Gamma entails alpha or beta$,
    $Gamma entails alpha$,
  ),
  rule(
    name: [$or$-elim],
    $Gamma entails gamma$,
    $Gamma entails alpha or beta$,
    $Gamma, alpha entails gamma$,
    $Gamma, beta entails gamma$,
  ),
)

== Negation and Absurdity

#rules-grid(
  rule(
    name: [$not$-intro],
    $Gamma entails not alpha$,
    $Gamma, alpha entails bot$,
  ),
  rule(
    name: [$not$-elim],
    $Gamma entails bot$,
    $Gamma entails alpha$,
    $Gamma entails not alpha$,
  ),
  rule(
    name: [RAA],
    $Gamma entails beta$,
    $Gamma entails alpha$,
    $Gamma entails not alpha$,
  ),
)

#rules-grid(
  rule(
    name: [LEM],
    $Gamma entails alpha or not alpha$,
    [~],
  ),
  rule(
    name: [assumption],
    $Gamma, alpha entails alpha$,
    [~],
  ),
)

#v(1em)

#note[
  *Classical vs Intuitionistic:* The rules above define _classical_ natural deduction.
  Dropping LEM (and restricting RAA) gives _intuitionistic_ logic, where $P or not P$ is not provable --- relevant in constructive mathematics and type theory (Curry--Howard correspondence).
]

== Fitch Notation

_Fitch notation_ arranges ND proofs as a numbered list of lines, with indentation for _subproofs_ (temporary assumptions and their scope).

#example[
  $p and q, r entails q and r$

  #import frederic: assume, fitch, premise, step, subproof

  #align(center)[
    #grid(
      columns: 2,
      align: left,
      column-gutter: 2em,
      [
        *Proof tree:*
        #prooftree(
          title-inset: 0.5em,
          rule(
            name: [$and$i],
            $q and r$,
            rule(
              name: [$and$e],
              $q$,
              rule($p and q$),
            ),
            rule($r$),
          ),
        )],
      [
        *Fitch notation:*
        #fitch(
          premise(1, $p and q$),
          premise(2, $r$),
          step(3, $q$, rule: [$and$e 1]),
          step(4, $q and r$, rule: [$and$i 3, 2]),
        )],
    )
  ]
]

#example[
  *Modus Tollens* --- $A imply B, not B entails not A$:

  #import frederic: assume, fitch, premise, step, subproof

  #align(center)[
    #fitch(
      premise(1, $A imply B$),
      premise(2, $not B$),
      subproof(
        assume(3, $A$, rule: [assumption]),
        step(4, $B$, rule: [$imply$e 1, 3]),
        step(5, $bot$, rule: [$not$e 4, 2]),
      ),
      step(6, $not A$, rule: [$not$i 3--5]),
    )
  ]

  Note the _subproof_ at lines 3--5: temporarily assume $A$, derive $bot$, then discharge the assumption to conclude $not A$.
  The vertical bar shows the scope of the assumption.
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

== Semantic Tableaux

_Semantic tableaux_ (truth trees) operationalize the refutation principle.

To test whether $phi$ is valid: _negate_ it and try to build a satisfying assignment for $not phi$.
Decompose compound formulas into simpler ones, branching at disjunctions.
If _every_ branch reaches a contradiction, $phi$ is valid.

#definition[Closed Branch][
  A branch is _closed_ if it contains both $phi$ and $not phi$ for some formula $phi$ (marked $times$).
  A tableau is _closed_ if _every_ branch is closed.
]

#definition[Open Branch][
  A branch is _open_ if it is fully expanded but not closed --- it provides a _satisfying assignment_ (counterexample).
]

== Tableaux Decomposition Rules

Formulas are classified as $alpha$-type (conjunctive) or $beta$-type (disjunctive):

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 3em,
    [
      *$alpha$-rules* (no branching):
      #table(
        columns: 3,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
        table.header[$alpha$][$alpha_1$][$alpha_2$],
        [$A and B$], [$A$], [$B$],
        [$not (A or B)$], [$not A$], [$not B$],
        [$not (A imply B)$], [$A$], [$not B$],
        [$not not A$], [$A$], [],
      )
    ],
    [
      *$beta$-rules* (branching):
      #table(
        columns: 3,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
        table.header[$beta$][$beta_1$][$beta_2$],
        [$A or B$], [$A$], [$B$],
        [$not (A and B)$], [$not A$], [$not B$],
        [$A imply B$], [$not A$], [$B$],
      )
    ],
  )
]

$alpha$-rules _extend_ the current branch (conjunction --- both must hold). \
$beta$-rules _split_ into two branches (disjunction --- at least one must hold).

== Tableaux: Worked Example

*Prove:* $models (P imply Q) imply (not Q imply not P)$ (contraposition).

Negate and try to satisfy.
If all branches close --- valid.

#align(center)[
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    let nd(pos, label, ..args) = content(pos, label, ..args.named())
    let closed(pos) = content(pos, text(red, $times$))

    nd((4, 0), [$1. thin not ((P imply Q) imply (not Q imply not P))$], anchor: "west")
    nd((4, -1), [$2. thin P imply Q$], anchor: "west")
    nd((4, -2), [$3. thin not (not Q imply not P)$], anchor: "west")
    nd((4, -3), [$4. thin not Q$], anchor: "west")
    nd((4, -4), [$5. thin not not P$], anchor: "west")
    nd((4, -5), [$6. thin P$], anchor: "west")

    line((5.5, -5.5), (3.5, -6.5), stroke: 0.6pt)
    line((5.5, -5.5), (7.5, -6.5), stroke: 0.6pt)

    nd((3.5, -7), [$7. thin not P$], anchor: "center")
    nd((7.5, -7), [$7. thin Q$], anchor: "center")

    closed((3.5, -7.8))
    content((3.5, -8.4), text(0.65em, red)[$P, not P$])
    closed((7.5, -7.8))
    content((7.5, -8.4), text(0.65em, red)[$Q, not Q$])
  })
]

Both branches close $arrow.double$ the formula is valid. $square$

== Tableaux: Counterexample Discovery

*Test:* Is $P imply (Q imply P)$ a tautology? (Spoiler: _yes._)
*Test:* Is $P imply Q$ a tautology? (Spoiler: _no._)

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    Negate $P imply Q$:
    + $not (P imply Q)$ #h(5em) _negate_
    + $P$ #h(9.6em) _$alpha$-rule on 1_
    + $not Q$ #h(7.6em) _$alpha$-rule on 1_

    No complementary pair --- branch is *open*. \
    *Counterexample:* $nu(P) = 1, nu(Q) = 0$.
  ],
  [
    #Block(color: green)[
      *Key property of tableaux:*
      - Closed tableau $arrow.double$ formula is valid.
      - Open branch $arrow.double$ read off a counterexample from the literals on the branch.
    ]
  ],
)

#theorem[
  Propositional semantic tableaux are _sound_ and _complete_:
  a closed tableau can be constructed for $alpha$ if and only if $alpha$ is valid.
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
    C = ell_1 or dots or ell_m or ell'_1 or dots or ell'_k
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

The empty clause $square$ is derived $arrow.double$ the original entailment holds. $square$

#theorem[Completeness of Resolution][
  Resolution is _refutation-complete_: a set of clauses $S$ is unsatisfiable if and only if the empty clause $square$ can be derived from $S$ by resolution.
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

Progression from left to right mirrors the course: human methods $arrow.r$ machine methods.
SAT solvers are _resolution engines_ augmented with heuristics (VSIDS, restarts, phase saving).

= First-Order Logic

== Why First-Order Logic?

Propositional logic cannot express quantification over objects.
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

FOL matters for this course because _specifications_ are naturally first-order:
"for _all_ inputs, if the precondition holds, the postcondition holds" is a $forall$-statement.
SMT solvers decide fragments of FOL.
Dafny verification conditions are FOL formulas.

== FOL Syntax: Signatures

#definition[Signature][
  A _first-order signature_ $Sigma = angle.l cal(F), cal(R) angle.r$ consists of:
  - A set of _function symbols_ $cal(F)$, each with an arity $n gt.eq 0$.
  - A set of _relation symbols_ (predicates) $cal(R)$, each with an arity $n gt.eq 1$.

  Functions of arity 0 are _constants_. We assume a countably infinite set of _variables_ $cal(V) = {x, y, z, x_1, x_2, dots}$.
]

#example[
  *Arithmetic:* $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$ \
  where $0$ is a constant, $S$ is unary, $+, times$ are binary functions; $<, =$ are binary relations.

  *Graph theory:* $Sigma = angle.l emptyset, {"Edge", "Path"} angle.r$ \
  where $"Edge"$ and $"Path"$ are binary predicates (no function symbols).
]

== FOL Syntax: Terms and Formulas

#definition[Term][
  _Terms_ over signature $Sigma$ are defined inductively:
  - Every variable $x in cal(V)$ is a term.
  - If $f in cal(F)$ has arity $n$ and $t_1, dots, t_n$ are terms, then $f(t_1, dots, t_n)$ is a term.
]

#definition[Formula][
  _Formulas_ over $Sigma$ are defined inductively:
  - If $R in cal(R)$ has arity $n$ and $t_1, dots, t_n$ are terms, then $R(t_1, dots, t_n)$ is an _atomic formula_ (atom).
  - If $phi, psi$ are formulas: $not phi$, $(phi and psi)$, $(phi or psi)$, $(phi imply psi)$, $(phi iff psi)$ are formulas.
  - If $phi$ is a formula and $x in cal(V)$: $forall x. thin phi$ and $exists x. thin phi$ are formulas.
]

#example[
  $forall x. thin (x = 0 or exists y. thin S(y) = x)$ --- "every natural number is $0$ or a successor."
]

== Free and Bound Variables

The _scope_ of $forall x$ (or $exists x$) is the immediately following subformula.

#definition[Free Variables][
  The set $op("FV")(phi)$ of _free variables_ of $phi$ is defined inductively:
  - $op("FV")(R(t_1, dots, t_n)) = op("Vars")(t_1) union dots union op("Vars")(t_n)$
  - $op("FV")(not phi) = op("FV")(phi)$; #h(1em) $op("FV")(phi circle.small psi) = op("FV")(phi) union op("FV")(psi)$ for $circle.small in {and, or, imply, iff}$
  - $op("FV")(forall x. thin phi) = op("FV")(exists x. thin phi) = op("FV")(phi) setminus {x}$
]

A formula with no free variables is a _sentence_ (closed formula).

#example[
  In $forall x. thin P(x, y)$: $x$ is _bound_ (in scope of $forall x$), $y$ is _free_. Not a sentence.
]

#note[
  Only _sentences_ have a definite truth value in a structure.
  Formulas with free variables are like "open predicates" --- they become true/false once you fix values for the free variables.
]

== Substitution

#definition[Substitution][
  $phi[t \/ x]$ denotes the formula obtained by replacing every _free_ occurrence of $x$ with term $t$.

  A substitution $[t \/ x]$ is _capture-free_ in $phi$ if no free variable in $t$ becomes bound.
]

#example[
  $forall y. thin (x < y) thin [S(0) \/ x] = forall y. thin (S(0) < y)$ --- correct substitution.

  $exists y. thin (x < y) thin [y + 1 \/ x] = exists y. thin (y + 1 < y)$ --- *variable capture!* \
  The free $y$ in the substituted term becomes bound.
  Fix: rename bound variable first: $exists z. thin (y + 1 < z)$.
]

#Block(color: orange)[
  *Variable capture:* Always check for name clashes before substituting.
  Rename bound variables if necessary.
]

== FOL Semantics: Structures

#definition[Structure (Model)][
  A _structure_ $frak(A)$ for signature $Sigma = angle.l cal(F), cal(R) angle.r$ consists of:
  - A non-empty _domain_ (universe) $A$ --- the set of objects we reason about.
  - For each $n$-ary function symbol $f in cal(F)$: a function $f^frak(A) : A^n arrow A$.
  - For each $n$-ary relation symbol $R in cal(R)$: a relation $R^frak(A) subset.eq A^n$.

  A _variable assignment_ $sigma : cal(V) arrow A$ maps each variable to a domain element.
]

#example[
  For the arithmetic signature $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$:
  - $frak(N) = (NN, 0, S, +, times, <, =)$ --- the _standard_ (intended) model.
  - $frak(Z) = (ZZ, 0, S, +, times, <, =)$ --- a different, equally valid structure.
  - The sentence $forall x. thin exists y. thin x = S(y) or x = 0$ is true in $frak(N)$ (every natural number is 0 or a successor) but _false_ in $frak(Z)$ (take $x = -1$: it is not $0$ and not a successor of any integer under the standard successor).

  This illustrates a key point: the same sentence can be true in one structure and false in another.
  _Validity_ means truth in _all_ structures.
]

== Evaluating FOL Formulas

Given a structure $frak(A)$ and a variable assignment $sigma$, truth is defined inductively.
The key ingredient compared to PL: quantifiers range over domain elements.

#definition[Satisfaction Relation][
  The relation $frak(A), sigma models phi$ is defined inductively:
  - $frak(A), sigma models R(t_1, dots, t_n)$ iff $(t_1^(frak(A),sigma), dots, t_n^(frak(A),sigma)) in R^frak(A)$
  - Boolean connectives: as in PL.
  - $frak(A), sigma models forall x. thin phi$ iff $frak(A), sigma[x arrow.bar a] models phi$ for _every_ $a in A$.
  - $frak(A), sigma models exists x. thin phi$ iff $frak(A), sigma[x arrow.bar a] models phi$ for _some_ $a in A$.

  Here $sigma[x arrow.bar a]$ maps $x$ to $a$ and agrees with $sigma$ on all other variables.
]

For _sentences_ (no free variables), the truth value depends only on the structure: we write $frak(A) models phi$.

#example[
  Let $frak(A) = ({1, 2, 3}, <^frak(A) = {(1,2),(1,3),(2,3)})$ be a structure for signature ${<}$.

  Evaluate $forall x. thin exists y. thin x < y$ in $frak(A)$:
  - $x = 1$: need $y$ with $1 < y$.  Take $y = 2$. #YES
  - $x = 2$: need $y$ with $2 < y$.  Take $y = 3$. #YES
  - $x = 3$: need $y$ with $3 < y$.  No such $y$ in ${1, 2, 3}$. #NO

  Result: $frak(A) models.not forall x. thin exists y. thin x < y$. The formula is _falsified_ by the element $3$.

  But $forall x. thin exists y. thin x < y$ _is_ satisfied in $frak(N) = (NN, <)$ --- for every $n$, take $y = n + 1$.
]

== Validity and Satisfiability in FOL

The semantic classification extends from PL:

#definition[
  Let $phi$ be an FOL sentence.
  - $phi$ is _valid_ ($models phi$) if $frak(A) models phi$ for _every_ structure $frak(A)$.
  - $phi$ is _satisfiable_ if $frak(A) models phi$ for _some_ structure $frak(A)$.
  - $phi$ is _unsatisfiable_ if no structure satisfies it.
]

#Block(color: orange)[
  *Critical difference from PL:* In PL, the space of interpretations is _finite_ ($2^n$ truth assignments). In FOL, structures can have _infinite_ domains of _any_ cardinality --- decision procedures are fundamentally harder.
]

#example[
  - $forall x. thin (P(x) or not P(x))$ --- valid (instance of LEM, holds in every structure).
  - $forall x. thin P(x) and exists x. thin not P(x)$ --- unsatisfiable.
  - $exists x. thin P(x)$ --- satisfiable (in any non-empty structure with $P$ non-empty) but not valid.
]

== Quantifier Equivalences

Many useful equivalences govern quantifiers:

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 0.5em,
  [
    *De Morgan duality for quantifiers:*
    - $not forall x. thin phi equiv exists x. thin not phi$
    - $not exists x. thin phi equiv forall x. thin not phi$

    *Distribution:*
    - $forall x. thin (phi and psi) equiv (forall x. thin phi) and (forall x. thin psi)$
    - $exists x. thin (phi or psi) equiv (exists x. thin phi) or (exists x. thin psi)$
  ],
  [
    *Vacuous quantification* (if $x$ not free in $psi$):
    - $forall x. thin psi equiv psi$, #h(1em) $exists x. thin psi equiv psi$

    *Commutativity of like quantifiers:*
    - $forall x. thin forall y. thin phi equiv forall y. thin forall x. thin phi$
    - $exists x. thin exists y. thin phi equiv exists y. thin exists x. thin phi$

    *Prenex pulling* (if $x$ not free in $psi$):
    - $psi and forall x. thin phi equiv forall x. thin (psi and phi)$
    - $psi or exists x. thin phi equiv exists x. thin (psi or phi)$
  ],
)

#Block(color: orange)[
  $exists x. thin forall y$ is generally _stronger_ than $forall y. thin exists x$ --- the former asserts a _single_ $x$ for _all_ $y$.
]

#example[
  Let $R(x, y) equiv$ "$x$ is the parent of $y$". Then:
  - $exists x. thin forall y. thin R(x, y)$ = "someone is the parent of _everyone_" --- false.
  - $forall y. thin exists x. thin R(x, y)$ = "everyone _has_ a parent" --- true.

  In general: $exists forall models forall exists$, but $forall exists models.not exists forall$.
]

== Prenex Normal Form

#definition[Prenex Normal Form (PNF)][
  A formula is in _prenex normal form_ if it has the shape:
  $ Q_1 x_1. thin Q_2 x_2. thin dots thin Q_n x_n. thin psi $
  where each $Q_i in {forall, exists}$ and $psi$ is _quantifier-free_ (the _matrix_).
]

#theorem[
  Every FOL formula can be converted to an equivalent formula in PNF (after renaming bound variables to avoid capture if necessary).
]

#example[
  $forall x. thin P(x) imply exists y. thin Q(x, y)$ \
  $equiv forall x. thin (not P(x) or exists y. thin Q(x, y))$ #h(1em) _(eliminate $imply$)_ \
  $equiv forall x. thin exists y. thin (not P(x) or Q(x, y))$ #h(1em) _(pull $exists y$ out)_
]

PNF separates the _quantifier prefix_ (alternation structure) from the _propositional skeleton_ (matrix).
The alternation depth ($forall exists forall dots$) determines complexity.

== FOL Proof Rules: Quantifiers

Natural deduction extends to FOL with four quantifier rules:

#rules-grid(
  rule(
    name: [$forall$-intro],
    $Gamma entails forall x. thin phi(x)$,
    $Gamma entails phi(y)$,
  ),
  rule(
    name: [$forall$-elim],
    $Gamma entails phi(t)$,
    $Gamma entails forall x. thin phi(x)$,
  ),
)

#rules-grid(
  rule(
    name: [$exists$-intro],
    $Gamma entails exists x. thin phi(x)$,
    $Gamma entails phi(t)$,
  ),
  rule(
    name: [$exists$-elim],
    $Gamma entails psi$,
    $Gamma entails exists x. thin phi(x)$,
    $Gamma, phi(y) entails psi$,
  ),
)

*Side conditions:*
- $forall$-intro: $y$ must be _arbitrary_ --- not free in any undischarged assumption in $Gamma$.
- $forall$-elim: $t$ can be any term (universal _instantiation_).
- $exists$-intro: give a _witness_ term $t$.
- $exists$-elim: $y$ must be _fresh_ --- not free in $psi$ or any undischarged assumption besides $phi(y)$.

== FOL Soundness and Completeness

#theorem[Gödel's Completeness Theorem (1930)][
  FOL with standard proof rules is both _sound_ and _complete_:
  $ Gamma entails phi quad iff quad Gamma models phi $
]

#proof[
  _(Soundness.)_
  Each rule preserves truth: if premises hold in $frak(A)$, so does the conclusion.

  _(Completeness, sketch.)_
  If $Gamma entails.not phi$, then $Gamma union {not phi}$ is consistent.
  Extend to a maximally consistent set $Gamma^*$ (Lindenbaum's lemma).
  Add Henkin witnesses for existential formulas.
  Build a canonical model from equivalence classes of closed terms.
  This model satisfies $Gamma union {not phi}$, so $Gamma models.not phi$.
  Contrapositive gives the result. $square$
]

#Block(color: yellow)[
  _Not_ the "incompleteness theorem" --- here "complete" means the proof system derives everything semantically true in _all_ structures.
]

== FOL Validity is Undecidable

Despite completeness, there is _no algorithm_ that always terminates and correctly decides FOL validity.

#theorem[Church--Turing Theorem (1936)][
  The validity problem for FOL is _undecidable_:
  no Turing machine can decide, given an arbitrary FOL sentence $phi$, whether $models phi$.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Decidable (PL):*
    - Finite search space ($2^n$ interpretations)
    - Truth tables always terminate
    - SAT is NP-complete, VALID is co-NP-complete
  ],
  [
    *Undecidable (FOL):*
    - Infinite/unbounded structures
    - Proof search may not terminate
    - Valid = semi-decidable (r.e.)
    - Satisfiable = semi-decidable (co-r.e.)
  ],
)

#Block(color: green)[
  FOL validity is *semi-decidable*: if $phi$ is valid, proof search _will_ find a proof (by completeness).
  If $phi$ is not valid, search may run forever.
]

SMT solvers restrict to _decidable fragments_ of FOL --- theories where satisfiability _can_ be decided.

= Metatheorems and \ the Limits of Logic

== The Compactness Theorem

#theorem[Compactness Theorem][
  A (possibly infinite) set of FOL sentences $Gamma$ is satisfiable if and only if every _finite_ subset of $Gamma$ is satisfiable.
]

#proof[
  (Sketch.)
  ($arrow.double$) Trivial: any model of $Gamma$ satisfies every finite subset.

  ($arrow.double.l$) If $Gamma$ is unsatisfiable, then by completeness there is a proof of $bot$ from $Gamma$.
  Every proof uses only _finitely many_ premises, so some finite $Gamma_0 subset.eq Gamma$ is already unsatisfiable.
]

#example[
  *Non-standard models of arithmetic:*
  Let $Gamma = op("Th")(NN) union {c > 0, c > 1, c > 2, dots}$ where $c$ is a fresh constant.
  Every finite subset is satisfiable (interpret $c$ as a large enough number).
  By compactness, $Gamma$ is satisfiable --- in a model with an "infinite" element $c$ larger than all standard naturals. This is a _non-standard model_ of arithmetic.
]

== The Löwenheim--Skolem Theorem

#theorem[Löwenheim--Skolem Theorem][
  If an FOL sentence (or countable set of sentences) has an _infinite_ model, then it has a model of _every_ infinite cardinality.
]

#Block(color: teal)[
  *Skolem's paradox (1922):* ZFC proves uncountable sets exist, yet by Löwenheim--Skolem, ZFC has a _countable_ model.
  Resolution: "uncountable" is _relative_ to the model's membership relation.
]

Expressive limitations of FOL (compactness + Löwenheim--Skolem):
- Cannot define "exactly the natural numbers" (up to isomorphism).
- Cannot express "the domain is finite" or "the domain is countable."
- Cannot distinguish between structures of different infinite cardinalities.

These limitations motivate _stronger_ logics (second-order, infinitary) and _decidable_ fragments (monadic FOL, EPR, SMT theories).

== Gödel's Incompleteness Theorems

_Completeness_ (above): "if $phi$ is true in _all_ structures, it is provable."
_Incompleteness_ (below): "if we fix _one_ structure ($NN$), some true sentences are unprovable."
These concern different questions.

#theorem[First Incompleteness Theorem][
  Any _consistent_ formal system $cal(T)$ capable of expressing elementary arithmetic contains sentences that are _true_ (in the standard model $NN$) but _unprovable_ in $cal(T)$.
]

#theorem[Second Incompleteness Theorem][
  If $cal(T)$ is consistent and sufficiently powerful, then $cal(T)$ _cannot prove its own consistency_:
  $ cal(T) tack.r.not op("Con")(cal(T)) $
]

#note(title: "Sufficiently powerful")[
  $cal(T)$ must be capable of representing all computable functions --- essentially, $cal(T)$ must contain Robinson arithmetic ($Q$) or stronger.
]

#Block(color: orange)[
  Gödel's _completeness_ theorem: FOL proof systems are complete w.r.t. semantic consequence.
  His _incompleteness_ theorems: specific _theories_ (like arithmetic) have true-but-unprovable sentences.
  Different notions of "completeness"!
]

== Incompleteness: The Key Idea

The proof relies on _self-reference_, made mathematically precise via Gödel numbering.

Every formula, proof, and syntactic operation is encoded as a natural number.
There is an arithmetic formula $"Prov"(n)$ saying "$n$ is the Gödel number of a provable sentence."
Construct a sentence $G$:

$ G quad equiv quad "\"I am not provable in " cal(T) "\"" $

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *If $G$ is provable in $cal(T)$:*
    - $cal(T)$ proves $G$
    - $G$ says "$G$ is not provable"
    - So $cal(T)$ proves something false
    - Contradicts _consistency_ of $cal(T)$
  ],
  [
    *If $G$ is not provable:*
    - $G$'s assertion is _true_
    - So $G$ is true but unprovable
    - $cal(T)$ is _incomplete_
  ],
)

#Block(color: blue)[
  Incompleteness means _no_ verification system can prove _all_ true program properties.
  In practice, automated tools are remarkably effective for _specific_ programs.
]

== The Landscape of Logics

Classical PL and FOL are two points in a rich space of formal systems.
Different verification tasks need different logics:

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
    spacing: (4em, 1.5em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 2pt,

    vertex((0, 0), [Propositional\ Logic], green, name: <pl>),
    vertex((2, 0), [First-Order\ Logic], blue, name: <fol>),
    vertex((4, 0), [Higher-Order\ Logic], purple, name: <hol>),

    vertex((0, 2), [Modal\ Logic], orange, name: <modal>),
    vertex((2, 2), [Temporal\ Logic], orange, name: <temporal>),
    vertex((4, 2), [Separation\ Logic], red, name: <sep>),

    edge(<pl>, <fol>, "-}>", label: [\+ quantifiers]),
    edge(<fol>, <hol>, "-}>", label: [\+ higher types]),
    edge(<pl>, <modal>, "-}>", label: [\+ $square, diamond$]),
    edge(<modal>, <temporal>, "-}>", label: [\+ time]),
    edge(<fol>, <sep>, "-}>", label: [\+ heap], label-angle: auto),
  )
]

#grid(
  columns: 3,
  column-gutter: 1em,
  [
    *Modal Logic:*
    $square phi$ ("necessarily") and $diamond phi$ ("possibly").
    Kripke semantics: worlds + accessibility.
  ],
  [
    *Temporal Logic:*
    LTL ($square$, $diamond$, $cal(U)$), CTL, CTL\*.
    Model checking: $square diamond "response"$.
  ],
  [
    *Separation Logic:*
    Spatial connectives ($ast$, $ast.op$) for heap memory.
    Powers Meta Infer, VeriFast.
  ],
)

== Decidability Landscape

Computational complexity of logical decision problems:

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Logic / Fragment*][*SAT*][*Validity*][*Complexity*],
    [Propositional], [Decidable], [Decidable], [NP-c / co-NP-c],
    [Modal (K, S4, S5)], [Decidable], [Decidable], [PSPACE-complete],
    [FOL (general)], [Undecidable], [Undecidable], [Semi-decidable],
    [FOL monadic], [Decidable], [Decidable], [NEXPTIME-complete],
    [Presburger ($NN, +$)], [Decidable], [Decidable], [2-EXPTIME],
    [Arithmetic ($NN, +, times$)], [Undecidable], [Undecidable], [Not even semi-dec.],
  )
]

#Block(color: yellow)[
  *The sweet spot:* SMT logics (QF_LIA, QF_LRA, QF_BV, QF_AX, ...) --- expressive enough for verification conditions, with terminating decision procedures.
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

#Block(color: green)[
  *The SAT Problem:* Given a CNF formula $phi$, does there exist $nu$ such that $nu models phi$?

  SAT is *NP-complete* (Cook--Levin, 1971) --- yet modern solvers handle _millions_ of variables.
]

*Next:* SAT encodings, DPLL, CDCL, then FOL theories and SMT.

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

== Exercises: First-Order Logic

+ Formalize the following in FOL:
  - "Every prime number greater than 2 is odd."
  - "There is no largest natural number."
  - "If $f$ is injective and $A subset.eq B$, then $f(A) subset.eq f(B)$."

+ Determine free and bound variables, and whether each formula is a sentence:
  - $forall x. thin (P(x) imply exists y. thin Q(x, y))$
  - $exists x. thin (x = y + 1)$
  - $forall x. thin forall y. thin (R(x, y) imply R(y, x))$

+ Convert to prenex normal form:
  $(forall x. thin P(x)) imply (exists y. thin Q(y))$

+ Explain informally: why does $exists x. thin forall y. thin R(x, y) thin models thin forall y. thin exists x. thin R(x, y)$ hold, but $forall y. thin exists x. thin R(x, y) thin models.not thin exists x. thin forall y. thin R(x, y)$?
  Give a concrete counterexample for the latter.

+ $star$ Using compactness, show that "the domain is finite" cannot be expressed by any _single_ FOL sentence (or even by any _set_ of FOL sentences).
