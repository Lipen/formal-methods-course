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

_Can we trust software?_

#Block(color: orange, inset: 0.8em)[
  Software failures are _not_ hypothetical --- they have caused deaths, financial losses, and mission failures.
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
]

== The Verification Spectrum

Not all verification is created equal.
Methods differ in _rigor_, _cost_, and _coverage_:

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

This course focuses on the _formal_ end of the spectrum --- logic-based reasoning, decision procedures, and deductive verification.

== Course Roadmap

// The course follows a single coherent thread:

#align(center)[
  #Block(color: blue)[
    _"How do we make machines reason about correctness?"_
  ]
]

#v(1em)

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

== Syntax and Semantics: Quick Recap

You know propositional logic from discrete math. Let us fix notation and terminology.

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

The _evaluation_ $Eval(alpha)$ of a formula $alpha$ under $nu$ is defined recursively by the truth-functional connectives.

== Key Semantic Concepts

#definition[Semantic Classification][
  Let $alpha$ be a WFF.
  - $alpha$ is *valid* (_tautology_), written $models alpha$, if $Eval(alpha) = 1$ for _all_ interpretations $nu$.
  - $alpha$ is *satisfiable* if $Eval(alpha) = 1$ for _some_ interpretation $nu$.
  - $alpha$ is *unsatisfiable* (_contradiction_) if $Eval(alpha) = 0$ for _all_ interpretations $nu$.
  - $alpha$ is *falsifiable* if $Eval(alpha) = 0$ for _some_ interpretation $nu$.
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

This distinction is _fundamental_ for formal methods:

#definition[Semantic Entailment][
  A set of formulas $Gamma$ _semantically entails_ $alpha$, written $Gamma models alpha$, if every interpretation satisfying all formulas in $Gamma$ also satisfies $alpha$.
]

The *implication* operator ($imply$) is a connective _inside_ the language. \
*Entailment* ($models$) is a _metalogical_ relation _about_ the language.

#Block(color: green)[
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

These dual problems underpin the entire course:

$
    "SAT:" quad & exists nu. thin Eval(alpha) = 1 \
  "VALID:" quad & forall nu. thin Eval(alpha) = 1
$

#Block(color: blue)[
  $alpha$ is valid $quad iff quad not alpha$ is unsatisfiable.
]

Checking SAT by truth tables takes $cal(O)(2^n)$ time.
Is there a better way? _This is the million-dollar question_ (P vs NP).

#example[
  $P or not P$ is valid $iff$ $not (P or not P) equiv P and not P$ is unsatisfiable.
]

== Fundamental Equivalence Laws

A quick reference --- you know these from Boolean algebra:

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

These laws are the _rewriting rules_ for converting formulas to normal forms.

== Completeness of Connective Sets

Not all connectives are needed.

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

Algorithms need _standardized_ input.
Converting an arbitrary formula to a _normal form_ allows uniform processing.

#definition[Normal Form][
  A _normal form_ is a restricted syntactic representation of formulas.
  - Enables efficient reasoning, simplification, and decision procedures.
  - Essential in SAT solving, model checking, and logic synthesis.
]

We will study:
- *Negation Normal Form (NNF)* --- negations pushed to atoms
- *Conjunctive Normal Form (CNF)* --- conjunction of clauses, _the language of SAT solvers_
- *Disjunctive Normal Form (DNF)* --- disjunction of cubes

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

== NNF Transformation

Convert any formula to NNF by exhaustive application of these rewriting rules:

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

*Why CNF?* CNF is the standard input format for SAT solvers.
Every modern SAT solver (MiniSAT, CaDiCaL, Kissat) operates on formulas in CNF.

An interpretation $nu$ satisfies a CNF formula iff it satisfies _every_ clause, which means satisfying _at least one_ literal per clause.

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

SAT on DNF is easy: check if any cube is satisfiable (no complementary literals in a cube).
TAUT on CNF is easy: check if every clause is a tautology (contains complementary literals).

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
  Two formulas $alpha$ and $beta$ are _equisatisfiable_ if $alpha$ is satisfiable _if and only if_ $beta$ is satisfiable.
]

#note[
  Equisatisfiability is _weaker_ than logical equivalence.
  Equivalent formulas are always equisatisfiable, but not vice versa.

  For SAT solving, equisatisfiability is all we need --- we only care _whether_ a satisfying assignment exists, and any model of the equisatisfiable formula can be restricted to a model of the original.
]

== Tseitin Transformation

The _Tseitin transformation_ converts any formula to CNF in _polynomial time_ by introducing _fresh_ (auxiliary) variables.

=== Method

For each non-literal subformula $A$ of a formula $F$:
+ Introduce a fresh propositional variable $n_A$.
+ Add a _definitional clause_ $n_A iff A$ (asserting equivalence).
+ Replace $A$ with $n_A$ in $F$.

The resulting formula is _equisatisfiable_ with the original:
- Every model of $F$ can be _extended_ (by defining the fresh variables) to a model of the Tseitin encoding.
- Every model of the Tseitin encoding _restricted_ to the original variables is a model of $F$.

#pagebreak()

=== Cost

- The Tseitin transformation introduces $cal(O)(n)$ fresh variables and $cal(O)(n)$ clauses, where $n$ is the formula size.
- The definitional clause $n iff A$ for a binary connective produces a _constant number_ of clauses.

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

Truth tables determine validity, but require $2^n$ rows for $n$ variables --- exponential.

_Can we do better?_ Proof systems provide _structured_ reasoning that can be much shorter.

#Block(color: blue)[
  A *proof system* derives valid formulas (or entailments) by applying _inference rules_ to _axioms_ and _assumptions_, step by step.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Truth tables (semantic method):*
    - Enumerate all interpretations
    - Always works, always exponential
    - No structure to exploit
  ],
  [
    *Proof systems (syntactic method):*
    - Apply rules to derive conclusions
    - Can be dramatically shorter
    - Foundation of automated reasoning
  ],
)

== Natural Deduction

_Natural deduction_ is a proof system with _no axioms_ --- only inference rules.

Each logical connective has _introduction_ and _elimination_ rules:

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

_Fitch notation_ is a linear format for writing natural deduction proofs:

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

#Block(color: yellow)[
  *For formal methods:* Soundness guarantees that verified properties _actually hold_.
  Completeness guarantees that _every_ true property _can_ be proven --- at least in principle.
]

= Connecting to SAT

== From Logic to SAT Solving

Everything in this lecture feeds into the SAT problem:

+ *Formulas* express constraints about a system's behavior.
+ *Normal forms* (especially CNF) provide the _input format_ for automated solvers.
+ *Equisatisfiability* (Tseitin) ensures compact encodings.
+ *Proof systems* explain _why_ a formula is unsatisfiable (resolution proofs).

#Block(color: green)[
  *SAT Problem:* Given a CNF formula $phi$, does there exist an interpretation $nu$ such that $nu models phi$?

  SAT is *NP-complete* (Cook--Levin, 1971) --- the canonical hard problem.
  Yet modern solvers handle formulas with _millions_ of variables.
]

*Next lecture:* We will study SAT encodings, the DPLL algorithm, and conflict-driven clause learning (CDCL) --- the engine behind all modern SAT solvers.

== Exercises

+ Show that ${imply, bot}$ is a functionally complete set of connectives.

+ Convert the formula $(P imply Q) imply R$ to:
  - NNF
  - CNF (using distributive law)
  - Clausal form (using Tseitin transformation)

+ Prove the following using natural deduction (Fitch notation):
  - $a imply b, thin not b thin entails thin not a$ (modus tollens)
  - $entails thin (a imply b) or (b imply a)$
  - $p imply not p thin entails thin not p$

+ For a formula with $n$ biconditionals in a chain $p_1 iff p_2 iff dots iff p_(n+1)$:
  - How many clauses does the equivalent CNF have?
  - How many clauses does the Tseitin encoding produce?

+ Show that the satisfiability problem for DNF formulas is solvable in polynomial time.
