#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Satisfiability Modulo Theories",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

#let eqq = $scripts(eq^.)$
#let rank = $op("rank")$

#let Sort(s) = $#raw(s)$
#let BoolSort = Sort("Bool")
#let NatSort = Sort("Nat")
#let SetSort = Sort("Set")
#let IntSort = Sort("Int")
#let RealSort = Sort("Real")
#let ArraySort = Sort("Array")
#let StringSort = Sort("String")

#let Green(x) = {
  show emph: set text(green.darken(20%))
  text(x, green.darken(20%))
}
#let Red(x) = {
  show emph: set text(red.darken(20%))
  text(x, red.darken(20%))
}

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green[#sym.checkmark]
#let NO = Red[#sym.crossmark]

= First-Order Theories

== Motivation

Consider the signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$ for a fragment of number theory:
- $Sigma^S = {NatSort}$, $Sigma^F = {0, 1, +, <}$
- $rank(0) = rank(1) = angle.l NatSort angle.r$
- $rank(+) = angle.l NatSort, NatSort, NatSort angle.r$
- $rank(<) = angle.l NatSort, NatSort, BoolSort angle.r$

+ Consider the $Sigma$-sentence: $forall x : NatSort. thin not (x < x)$ \
  - Is it _valid_, that is, true under _all_ interpretations?
  - No, e.g., if we interpret $<$ as _equals_ or _divides_.

+ Consider the $Sigma$-sentence: $not exists x : NatSort. thin (x < 0)$
  - Is it _valid_?
  - No, e.g., if we interpret $NatSort$ as the set of _all_ integers.

+ Consider the $Sigma$-sentence: $forall x : NatSort. forall y : NatSort. forall z : NatSort. thin (x < y) and (y < z) imply (x < z)$
  - Is it _valid_?
  - No, e.g., if we interpret $<$ as the _successor_ relation.

#fancy-box[
  In practice, we often _do not care_ about satisfiability or validity in _general_, \ but rather with respect to a _limited class_ of interpretations.
]

*A practical reason:*
- When reasoning in a particular application domain, we typically have _specific_ data types/structures in mind (e.g., integers, strings, lists, arrays, finite sets, ...).
- More generally, we are typically _not_ interested in _arbitrary_ interpretations, but rather in _specific_ ones.

_Theories_ formalize this domain-specific reasoning: we talk about satisfiability and validity _with respect to a theory_ or "_modulo a theory_".

*A computational reason:*
- The validity problem for FOL is _undecidable_ in general.
- However, the validity problem for many _restricted_ theories, is _decidable_.

== First-Order Theories

Hereinafter, we assume that we have an infinite set of variables $X$.

#definition[Theory][
  A first-order _theory_ $cal(T)$ is a pair $angle.l Sigma, M angle.r$, where
  - $Sigma = angle.l Sigma^S, Sigma^F angle.r$ is a first-order signature,
  - $M$ is a class of $Sigma$-interpretations over $X$ that is _closed under variable re-assignment_.
]

#definition[
  $M$ is _closed under variable re-assignment_ if every $Sigma$-interpretation that differs from one in $M$ in the way it interprets the variables in $X$ is also in $M$.
]

#v(1em)
#align(center)[
  #fancy-box[
    A theory limits the interpretations of $Sigma$-formulas to those from $M$.
  ]
]

== Theory Examples

#example[
  Theory of Real Arithmetic $cal(T)_"RA" = angle.l Sigma_"RA", M_"RA" angle.r$:
  - $Sigma^S_"RA" = {RealSort}$
  - $Sigma^F_"RA" = {+, -, *, lt.eq} union {q | q "is a decimal numeral"}$
  - All $cal(I) in M_"RA"$ interpret $RealSort$ as the set of _real numbers_ $RR$, each $q$ as the _decimal number_ that it denotes, and the function symbols in the usual way.
]

#example[
  Theory of Ternary Strings $cal(T)_"TS" = angle.l Sigma_"TS", M_"TS" angle.r$:
  - $Sigma^S_"TS" = {StringSort}$
  - $Sigma^F_"TS" = {thin dot thin, <} union {"a", "b", "c"}$
  - All $cal(I) in M_"TS"$ interpret $StringSort$ as the set ${"a", "b", "c"}^*$ of all finite strings over the characters {"a", "b", "c"}, symbol $dot$~as string concatenation (e.g., $"a" dot "b" = "ab"$), and $<$ as lexicographic order.
]

== $cal(T)$-interpretations

#definition[Reduct][
  Let $Sigma$ and $Omega$ be two signatures over variables $X$, where $Omega supset.eq Sigma$, that is, #box[$Omega^S supset.eq Sigma^S$] and $Omega^F supset.eq Sigma^F$.

  Let $cal(I)$ be an $Omega$-interpretation over $X$.

  The _reduct_ $cal(I)^Sigma$ of $cal(I)$ to $Sigma$ is a $Sigma$-interpretation obtained from $cal(I)$ by resticting it to the symbols in $Sigma$.
]

#definition[$cal(T)$-interpretation][
  Given a theory $cal(T) = angle.l Sigma, M angle.r$, a _$cal(T)$-interpretation_ is any #box[$Omega$-interpretation] $cal(I)$ for some signature $Omega supset.eq Sigma$ such that $cal(I)^Sigma in M$.
]
#note[
  This definition allows us to consider the satisfiability in a theory $cal(T) = angle.l Sigma, M angle.r$ of formulas that contain sorts or function symbols not in $Sigma$.
  These symbols are usually called _uninterpreted_ (in $cal(T)$).
]

#pagebreak()

#example[
  Consider again the theory of real arithmetic $cal(T)_"RA" = angle.l Sigma_"RA", M_"RA" angle.r$.

  All $cal(I) in M_"RA"$ interpret $RealSort$ as $RR$ and function symbols as usual.

  Which of the following interpretations are $cal(T)_"RA"$-interpretations?
  + $RealSort^(cal(I)_1) = QQ$, symbols in $Sigma^F_"RA"$ interpreted as usual. #NO

  + $RealSort^(cal(I)_2) = RR$, symbols in $Sigma^F_"RA"$ interpreted as usual, and $StringSort^(cal(I)_2) = {0.5, 1.3}$. #YES

  + $RealSort^(cal(I)_3) = RR$, symbols in $Sigma^F_"RA"$ interpreted as usual, and $log^(cal(I)_3)$ is the successor function. #YES
]

== $cal(T)$-satisfiability, $cal(T)$-entailment, $cal(T)$-validity

#definition[$cal(T)$-satisfiability][
  A $Sigma$-formula $alpha$ is _satisfiable in $cal(T)$_, or _$cal(T)$-satisfiable_, if it is satisfied by _some_ $cal(T)$-interpretation $cal(I)$.
]

#definition[$cal(T)$-entailment][
  A set $Gamma$ of formulas _$cal(T)$-entails_ a formula $alpha$, if every $cal(T)$-interpretation that satisfies all formulas in $Gamma$ also satisfies $alpha$.
]

#definition[$cal(T)$-validity][
  A formula $alpha$ is _$cal(T)$-valid_, if it is satisfied by _all_ $cal(T)$-interpretations.
]
#note[
  A formula $alpha$ is _$cal(T)$-valid_ iff $emptyset models alpha$.
]

#example[
  Which of the following $Sigma_"RA"$-formulas is satisfiable or valid in $cal(T)_"RA"$?
  + $(x_0 + x_1 lt.eq 0.5) and (x_0 - x_1 lt.eq 2)$ #h(1fr) #Green[_satisfiable_], #Red[_falsifiable_]
  + $forall x_0. thin (x_0 + x_1 lt.eq 1.7) imply (x_1 lt.eq 1.7 - x_0)$ #h(1fr) #Green[_satisfiable_], #Green[_valid_]
  + $forall x_0. forall x_1. thin (x_0 + x_1 lt.eq 1)$ #h(1fr) #Red[_unsatisfiable_], #Red[_falsifiable_]
]

== FOL vs Theory

For every signature $Sigma$, entailment and validity in "pure" FOL can be seen as entailment and validity in the theory $cal(T)_"FOL" = angle.l Sigma, M_"FOL" angle.r$ where $M_"FOL"$ is the class of _all possible_ $Sigma$-interpretations.

- Pure first-order logic = reasoning over _all_ possible interpretations.
- Reasoning modulo a theory = _restricting_ interpretations with some domain constraints.
- Theories make automated reasoning _feasible_ in many domains.

== Axiomatization

#definition[Axiomatic theory][
  A first-order _axiomatic theory_ $cal(T)$ is defined by a signature $Sigma$ and a set $cal(A)$ of $Sigma$-sentences, or _axioms_.
]

In particular, an $Omega$-formula $alpha$ is _valid_ in an axiomatic theory $cal(T)$ if it is entailed by the axioms of $cal(T)$, that is, every $Omega$-interpretation $cal(I)$ that satisfies all axioms of $cal(T)$ also satisfies $alpha$.

// TODO: mention that axiomatic theories are a special case of those defined on the previous slides. Also mention that the notion of "axiomatic theories" is LESS general (as shown below by the examples of "non-axiomatizable" theories).
Given an axiomatic theory $cal(T)$ defined by $Sigma$ and $cal(A)$, we can define a theory $cal(T)' = angle.l Sigma, M angle.r$ where $M$ is the class of all $Sigma$-interpretations that satisfy all axioms in $cal(A)$.

It is not hard to show that a formula $alpha$ is valid in $cal(T)$ _iff_ it is valid in $cal(T)'$.

#pagebreak()
#note[
  Not all theories are first-order axiomatizable.

  #example[
    Consider the theory $cal(T)_NatSort$ of the natural numbers, with signature $Sigma$ with $Sigma^S = {NatSort}$, $Sigma^F = {0,S,+,<}$, and $M = {cal(I)}$ where $NatSort^cal(I) = NN$ and $Sigma^F$ is interpreted as usual.

    _Any set of axioms_ for this theory is satisfied by _non-standard models_, e.g., interpretations $cal(I)$ where $NatSort^cal(I)$ includes other chains of elements besides the natural numbers, e.g., $NN^cal(I) = {0,1,2,...} union {omega, omega+1, ...}$.

    These models _falsify_ formulas that are _valid_ in $cal(T)_NatSort$, e.g., $not exists x. thin (x < 0)$ or $forall x. thin ((x eqq 0) or exists y. thin (x eqq S(y)))$.
  ]
]

== Completeness of Theories

#definition[
  A $Sigma$-theory $cal(T)$ is _complete_ if for every $Sigma$-sentence $alpha$, either $alpha$ or $not alpha$ is valid in $cal(T)$.
]
#note[
  In a complete $Sigma$-theory, every $Sigma$-sentence is either valid or unsatisfiable.
]

#example[
  Any theory $cal(T) = angle.l Sigma, M angle.r$ where all interpretations in $M$ only differ in how they interpret the variables (e.g., $cal(T)_"RA"$) is _complete_.
]

#pagebreak()
#example[
  The axiomatic (mono-sorted) theory of _monoids_ with $Sigma^F = {dot, epsilon}$ and axioms
  $
    forall x. forall y. forall z. thin (x dot y) dot z eqq x dot (y dot z)
    quad quad
    forall x. thin (x dot epsilon eqq x)
    quad quad
    forall x. thin (epsilon dot x eqq x)
  $
  is _incomplete_.

  For example, the sentence $forall x. forall y. thin (x dot y eqq y dot x)$ is #True in some monoids (e.g. the integers with addition) but #False in others (e.g. the strings with concatenation).
]

#pagebreak()
#example[
  The axiomatic (mono-sorted) theory of _dense linear orders without endpoints_ with $Sigma^F = {prec}$ and axioms
  #grid(
    columns: 2,
    align: (right, left),
    stroke: none,
    inset: 5pt,
    $forall x. forall y. (x prec y) imply exists z. thin ((x prec z) and (z prec y))$, [(dense)],
    $forall x. forall y. thin ((x prec y) or (y prec x) or (x eqq y))$, [(linear)],
    $forall x. thin not (x prec x) quad forall x. forall y. forall z. thin ((x prec y) and (y prec z) imply (x prec z))$,
    [(orders)],

    $forall x. exists y. thin (y prec x) quad forall x. exists y. thin (x prec y)$, [(without endpoints)],
  )
  is _complete_.
]

== Decidability

Recall that a set $A$ is _decidable_ if there exists a _terminating_ procedure that, given an input element $a$, returns (after _finite_ time) either "yes" if $a in A$ or "no" if $a notin A$.

#definition[
  A theory $cal(T) = angle.l Sigma, M angle.r$ is _decidable_ if the set of all _$cal(T)$-valid_ $Sigma$-formulas is decidable.
]

#definition[
  A _fragment_ of $cal(T)$ is a _syntactically-restricted subset_ of $cal(T)$-valid $Sigma$-formulas.
]
#example[
  The _quantifier-free_ fragment of $cal(T)$ is the set of all $cal(T)$-valid $Sigma$-formulas without any quantifiers.
]
#example[
  The _linear_ fragment of $cal(T)_"RA"$ is the set of all $cal(T)$-valid $Sigma_"RA"$-formulas without multiplication ($*$).
]

== Axiomatizability

#definition[
  A theory $cal(T) = angle.l Sigma, M angle.r$ is _recursively axiomatizable_ if $M$ is the class of all interpretations satisfying a _decidable set_ of first-order axioms $cal(A)$.
]

// TODO: replace #theorem with #lemma
#theorem[Lemma][
  Every recursively axiomatizable theory $cal(T)$ admits a procedure $E_cal(T)$ that _enumerates_ all $cal(T)$-valid formulas.
]

#theorem[
  For every _complete_ and _recursively axiomatizable_ theory $cal(T)$, $cal(T)$-validity is decidable.
]
#proof[
  Given a formula $alpha$, use $E_cal(T)$ to enumerate all valid formulas.
  Since $cal(T)$ is complete, either $alpha$ or $not alpha$ will eventually (after _finite_ time) be produced by $E_cal(T)$.
]

= Introduction to SMT

== Common Theories in SMT

SMT traditionally focuses on theories with _decidable_ quantifier-free _fragments_.

Recall: a formula $alpha$ is _$cal(T)$-valid_ iff $not alpha$ is _$cal(T)$-unsatisfiable_.

Checking the (un)satisfiability of quantifier-free formulas in main background theories efficiently has a large number of applications in:
#columns(2)[
  - hardware and software verification
  - model checking
  - symbolic execution
  - compiler validation
  - type checking
  #colbreak()
  - planning and scheduling
  - software synthesis
  - cyber-security
  - verifiable machine learning
  - analysis of biological systems
]

Further, we are going to study:
- A few of those theories and their decision procedures.
- Proof systems to reason modulo theories automatically.

== From QF to Cubes

The satisfiability of quantifier-free formulas in a theory $cal(T)$ is decidable iff the satisfiability in $cal(T)$ of _conjunctions of literals (cubes)_ is decidable.

We are going to study a general extension of DPLL to SMT that uses decision procedures for _conjunctions of literals_.
Thus, we will mostly focus on _conjunctions of literals_.

== Theory of Uninterpreted Functions

Given a signature $Sigma$, the most general theory consists of the class of _all_ $Sigma$-interpretations.

In fact, this is a _family_ of theories parameterized by the signature $Sigma$.

It is known as the theory of _equality with uninterpreted functions_ $cal(T)_"EUF"$, or the _empty theory_, since it is axiomatized by the empty set of axioms.

Validity, and so satisfiability, in $cal(T)_"EUF"$ is only _semi-decidable_ (this is just a validity in FOL).

However, the satisfiability of _conjunctions $cal(T)_"EUF"$-literals_ is _decidable_, in polynomial time, using the _congruence closure_ algorithm.

#example[
  $(a eqq b) and (f(a) eqq b) and not (g(a) eqq g(f(a)))$
  Is this formula satisfiable in $cal(T)_"EUF"$?
]

== Theory of Real Arithmetic

The theory of real arithmetic $cal(T)_"RA"$ is a theory of inequalities over the real numbers.

- $Sigma^S = {RealSort}$
- $Sigma^F = {+, -, *, <} union {q | q "is a decimal numeral"}$
- $M$ is the class of interpretations that interpret $RealSort$ as the set of _real numbers_ $RR$, and the function symbols in the usual way.

Satisfiability in the full $cal(T)_"RA"$ is _decidable_ (in worst-case doubly-exponential time).

Restricted fragments of $cal(T)_"RA"$ can be decided more efficiently.

#example[
  Quantifier-free linear real arithmetic (`QF_LRA`) is the theory of _linear_ inequalities over the reals, where $*$ can only be used in the form of _multiplication by constants (decimal numerals)_.
]

The satisfiability of conjunctions of literals in `QF_LRA` is _decidable_ in _polynomial time_.

== Theory of Integer Arithmetic

The theory of integer arithmetic $cal(T)_"IA"$ is a theory of inequalities over the integers.

- $Sigma^S = {IntSort}$
- $Sigma^F = {+, -, *, <} union {n | n "is an integer numeral"}$
- $M$ is the class of interpretations that interpret $IntSort$ as the set of _integers_ $ZZ$, and the function symbols in the usual way.

Satisfiability in $cal(T)_"IA"$ is _not even semi-decidable_!

Satisfiability of quantifier-free $Sigma$-formulas in $cal(T)_"IA"$ is _undecidable_ as well.

_Linear integer arithmetic_ (`LIA`, also known as _Presburger arithmetic_) is decidable, but not efficiently (in~worst-case triply-exponential time).

== Theory of Arrays with Extensionality

The theory of arrays $cal(T)_"A"$ is useful for modelling RAM or array data structures.

- $Sigma^S = {Sort("A"), Sort("I"), Sort("E")}$ (arrays, indices, elements)
- $Sigma^F = {"read", "write"}$, where $rank("read") = angle.l Sort("A"), Sort("I"), Sort("E") angle.r$ and $rank("write") = angle.l Sort("A"), Sort("I"), Sort("E"), Sort("A") angle.r$

Let $a$ be a variable of sort $Sort("A")$, variable $i$ of sort $Sort("I")$, and variable $v$ of sort $Sort("E")$.
- $"read"(a, i)$ denotes the value stored in array $a$ at index $i$.
- $"write"(a, i, v)$ denotes the array that stores value $v$ at index $i$ and is otherwise identical to $a$.

#example[
  $"read"("write"(a, i, v), i) eqq_Sort("E") v$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
  // Valid
]

#example[
  $forall i. thin ("read"(a, i) eqq_Sort("E") "read"(a', i)) imply (a eqq_Sort("A") a')$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
  // Valid
]

#pagebreak()
The theory of arrays $cal(T)_"A" = angle.l Sigma, M angle.r$ is finitely axiomatizable.

$M$ is the class of interpretations that satisfy the following axioms:
+ $forall a. forall i. forall v. thin ("read"("write"(a, i, v), i) eqq_Sort("E") v)$
+ $forall a. forall i. forall j. forall v. thin not (i eqq_Sort("I") j) imply ("read"("write"(a, i, v), j) eqq_Sort("E") "read"(a, j))$
+ $forall a. forall b. thin (forall i. thin ("read"(a, i) eqq_Sort("E") "read"(b, i))) imply (a eqq_Sort("A") b)$

#note[
  The last axiom is called _extensionality_ axiom.
  It states that two arrays are equal if they have the same values at all indices.
  It can be omitted to obtain a theory of arrays _without extensionality_.
]

Satisfiability in $cal(T)_"A"$ is _undecidable_.

There are several _decidable_ _fragments_ of $cal(T)_"A"$.

= Extra slides

== Decidability and Complexity

#table(
  columns: 6,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[Theory][Description][Full][QF][Full complexity][QFC complexity],
  [PL], [Propositional logic], [yes], [yes], [NP-complete], [$Theta(n)$],
  [$cal(T)_"E"$], [equality], [no], [yes], [undecidable], [$cal(O)(n log n)$],
  [$cal(T)_"PA"$], [Peano Arithmetic], [no], [no], [undecidable], [undecidable],
  [$cal(T)_NN$], [Presburger Arithmetic], [yes], [yes], [$Omega(2^2^n)$, $cal(O)(2^2^2^(k n))$], [NP-complete],
  [$cal(T)_ZZ$], [linear integers], [yes], [yes], [$Omega(2^2^n)$, $cal(O)(2^2^2^(k n))$], [NP-complete],
  [$cal(T)_RR$], [reals (with $dot$)], [yes], [yes], [$cal(O)(2^2^(k n))$], [$cal(O)(2^2^(k n))$],
  [$cal(T)_QQ$], [rationals (without $dot$)], [yes], [yes], [$Omega(2^n)$, $cal(O)(2^2^(k n))$], [PTIME],
  [$cal(T)_"RDS"$], [recursive data structures], [no], [yes], [undecidable], [$cal(O)(n log n)$],
  [$cal(T)^+_"RDS"$], [acyclic recursive data structures], [yes], [yes], [not elementary recursive], [$Theta(n)$],
  [$cal(T)_"A"$], [arrays], [no], [yes], [undecidable], [NP-complete],
  [$cal(T)^=_"A"$], [arrays with extensionality], [no], [yes], [undecidable], [NP-complete],
)

#pagebreak()
- *"Full"* denotes the decidability of a complete theory _with_ quantifiers.
- *"QF"* denotes the decidability of a _quantifier-free_ theory.
- *"Full complexity"* denotes the complexity of the satisfiability in a complete theory _with_ quantifiers.
- *"QFC complexity"* denotes the complexity of the satisfiability in a quantifier-free _conjunctive_ fragment of a theory.
- "_Not elementary recursive_" means the runtime cannot be bounded by a fixed-height stack of exponentials.

= Theory Solvers

== Theory Solvers

#definition[$cal(T)$-solver][
  A _theory solver_, or _$cal(T)$-solver_, is a specialized decision procedure for the satisfiability of conjunctions of literals in a theory $cal(T)$.
]

#[
  #import fletcher: diagram, node, edge
  #import fletcher.shapes: *
  #set align(center)
  #diagram(
    // debug: true,
    edge-stroke: 1pt,
    node-corner-radius: 3pt,

    blob((0, 0), [Set of literals], shape: rect, tint: teal, height: 2em, name: <input>),
    edge("-|>"),
    blob((1, 0), [$cal(T)$-solver], shape: hexagon, tint: purple, height: 2em, name: <solver>),
    blob((2, -0.5), [Consistent \ (SAT)], shape: rect, tint: green, height: 3em, name: <sat>),
    blob((2, 0.5), [Inconsistent \ (UNSAT)], shape: rect, tint: red, height: 3em, name: <unsat>),
    edge(<solver>, <sat>, "-|>"),
    edge(<solver>, <unsat>, "-|>"),
  )
]

== Difference Logic

#definition[
  _Difference logic_ is a fragment of linear integer arithmetic consisting of conjunctions of literals of the very restricted form:
  $ x - y join c $
  where $x$ and $y$ are integer variables, $c$ is a numeral, and $join in {eq, lt, lt.eq, gt, gt.eq}$.
]

A solver for difference logic consists of three steps:
+ Literals normalization.
+ Conversion to a graph.
+ Cycle detection.

#pagebreak()

*Step 1:* Rewrite each literal using $lt.eq$ by applying the following rules:
+ $(x - y = c) to (x - y lt.eq c) and (x - y gt.eq c)$
+ $(x - y gt.eq c) to (y - x lt.eq -c)$
+ $(x - y > c) to (y - x < -c)$
+ $(x - y < c) to (x - y lt.eq c - 1)$

*Step 2:* Construct a weighted directed graph $G$ with a vertex for each variable and an edge $x arrow^c y$ for each literal $(x - y lt.eq c)$.

*Step 3:* Check for _negative cycles_ in $G$.
- Use, for example, the Bellman-Ford algorithm.
- If $G$ contains a negative cycle, the set of literals is _inconsistent_ (UNSAT).
- Otherwise, the set of literals is _consistent_ (SAT).

== Difference Logic Example

Consider the following set of difference logic literals:
$
  (x - y = 5) and (z - y gt.eq 2) and (z - x > 2) and (w - x = 2) and (z - w < 0)
$

Normalize the literals:
- $(x - y = 5) &to (x - y lt.eq 5) and (y - x lt.eq -5)$
- $(z - y gt.eq 2) &to (y - z lt.eq -2)$
- $(z - x > 2) &to (x - z lt.eq -3)$
- $(w - x = 2) &to (w - x lt.eq 2) and (x - w lt.eq -2)$
- $(z - w < 0) &to (z - w lt.eq -1)$

#place(bottom + right, dy: -1cm)[
  #import fletcher: diagram, node, edge
  #import fletcher.shapes: *
  #diagram(
    edge-stroke: 1pt,
    node-outset: 2pt,
    spacing: 4em,
    node((0, 0), [$x$], shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%), name: <x>),
    node((1, -1), [$y$], shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%), name: <y>),
    node((1, 1), [$w$], shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%), name: <w>),
    node((2, 0), [$z$], shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%), name: <z>),
    edge(<x>, <y>, "-}>", [$5$], label-side: center, bend: 30deg),
    edge(<y>, <x>, "-}>", [$-5$], label-side: center, bend: 30deg),
    edge(<x>, <w>, "-}>", [$-2$], label-side: center, bend: 30deg),
    edge(<w>, <x>, "-}>", [$2$], label-side: center, bend: 30deg),
    edge(<x>, <z>, "-}>", [$-3$], label-side: center),
    edge(<y>, <z>, "-}>", [$-2$], label-side: center, bend: 30deg),
    edge(<z>, <w>, "-}>", [$-1$], label-side: center, bend: 30deg),
  )
]

*UNSAT* because of the negative cycle: $x arrow.squiggly.long^(-3) z arrow.squiggly.long^(-1) w arrow.squiggly.long^(2)$.
