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
#let neqq = $scripts(cancel(eq^.))$
#let rank = $op("rank")$

#let Sort(s) = $#raw(s)$
#let BoolSort = Sort("Bool")
#let NatSort = Sort("Nat")
#let SetSort = Sort("Set")
#let IntSort = Sort("Int")
#let RealSort = Sort("Real")
#let ArraySort = Sort("Array")
#let StringSort = Sort("String")
#let USort = Sort("U")

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
  A first-order _theory_ $cal(T)$ is a pair#footnote[Here, we use *bold* style for $bold(M)$ to denote that it is _not a single_ model, but a _collection_ of them.] $angle.l Sigma, bold(M) angle.r$, where
  - $Sigma = angle.l Sigma^S, Sigma^F angle.r$ is a first-order signature,
  - $bold(M)$ is a class#footnote[_Class_ is a generalization of a set.] of $Sigma$-interpretations over $X$ that is _closed under variable re-assignment_.
]

#definition[
  $bold(M)$ is _closed under variable re-assignment_ if every $Sigma$-interpretation that differs from one in $bold(M)$ in the way it interprets the variables in $X$ is also in $bold(M)$.
]

#v(1em)
#align(center)[
  #fancy-box[
    A theory limits the interpretations of $Sigma$-formulas to those from $bold(M)$.
  ]
]

== Theory Examples

#example[
  Theory of Real Arithmetic $cal(T)_"RA" = angle.l Sigma_"RA", bold(M)_"RA" angle.r$:
  - $Sigma^S_"RA" = {RealSort}$
  - $Sigma^F_"RA" = {+, -, times, lt.eq} union {q | q "is a decimal numeral"}$
  - All $cal(I) in bold(M)_"RA"$ interpret $RealSort$ as the set of _real numbers_ $RR$, each $q$ as the _decimal number_ that it denotes, and the function symbols in the usual way.
]

#example[
  Theory of Ternary Strings $cal(T)_"TS" = angle.l Sigma_"TS", bold(M)_"TS" angle.r$:
  - $Sigma^S_"TS" = {StringSort}$
  - $Sigma^F_"TS" = {thin dot thin, <} union {"a", "b", "c"}$
  - All $cal(I) in bold(M)_"TS"$ interpret $StringSort$ as the set ${"a", "b", "c"}^*$ of all finite strings over the characters ${"a", "b", "c"}$, symbol $dot$~as string concatenation (e.g., $"a" dot "b" = "ab"$), and $<$ as lexicographic order.
]

== $cal(T)$-interpretations

#definition[Reduct][
  Let $Sigma$ and $Omega$ be two signatures over variables $X$, where $Omega supset.eq Sigma$, that is, #box[$Omega^S supset.eq Sigma^S$] and $Omega^F supset.eq Sigma^F$.

  Let $cal(I)$ be an $Omega$-interpretation over $X$.

  The _reduct_ $cal(I)^Sigma$ of $cal(I)$ to $Sigma$ is a $Sigma$-interpretation obtained from $cal(I)$ by resticting it to the symbols in $Sigma$.
]

#definition[$cal(T)$-interpretation][
  Given a theory $cal(T) = angle.l Sigma, bold(M) angle.r$, a _$cal(T)$-interpretation_ is any #box[$Omega$-interpretation] $cal(I)$ for some signature $Omega supset.eq Sigma$ such that $cal(I)^Sigma in bold(M)$.
]
#note[
  This definition allows us to consider the satisfiability in a theory $cal(T) = angle.l Sigma, bold(M) angle.r$ of formulas that contain sorts or function symbols not in $Sigma$.
  These symbols are usually called _uninterpreted_ (in $cal(T)$).
]

#pagebreak()

#example[
  Consider again the theory of real arithmetic $cal(T)_"RA" = angle.l Sigma_"RA", bold(M)_"RA" angle.r$.

  All $cal(I) in bold(M)_"RA"$ interpret $RealSort$ as $RR$ and function symbols as usual.

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

For every signature $Sigma$, entailment and validity in "pure" FOL can be seen as entailment and validity in the theory $cal(T)_"FOL" = angle.l Sigma, bold(M)_"FOL" angle.r$ where $bold(M)_"FOL"$ is the class of _all possible_ $Sigma$-interpretations.

- Pure first-order logic = reasoning over _all_ possible interpretations.
- Reasoning modulo a theory = _restricting_ interpretations with some domain constraints.
- Theories make automated reasoning _feasible_ in many domains.

== Axiomatization

#definition[Axiomatic theory][
  A first-order _axiomatic theory_ $cal(T)$ is defined by a signature $Sigma$ and a set~$cal(A)$ of $Sigma$-sentences, or _axioms_.
]

#definition[$cal(T)$-validity in axiomatic theory][
  An $Omega$-formula $alpha$ is _valid_ in an axiomatic theory $cal(T)$ if it is entailed by the axioms of $cal(T)$, that is, every $Omega$-interpretation $cal(I)$ that satisfies $cal(A)$ also satisfies $alpha$.
]

#note[
  Axiomatic theories are a _special case_ of the general definition (via $bold(M)$) of theories.
  - Given an axiomatic theory $cal(T)'$ defined by $Sigma$ and $cal(A)$, we can define a theory $cal(T) = angle.l Sigma, bold(M) angle.r$ where $bold(M)$ is the class of all $Sigma$-interpretations that satisfy all axioms in $cal(A)$.
  - It is not hard to show that a formula $alpha$ is valid in $cal(T)$ _iff_ it is valid in $cal(T)'$.
]

#note[
  Not all theories are first-order axiomatizable.
]

== Non-Axiomatizable Theories

#note[
  Not all theories are first-order axiomatizable.
]

#example[
  Consider the theory $cal(T)_NatSort$ of the natural numbers, with signature $Sigma$ with $Sigma^S = {NatSort}$, $Sigma^F = {0,S,+,<}$, and $M = {cal(I)}$ where $NatSort^cal(I) = NN$ and $Sigma^F$ is interpreted as usual.

  _Any set of axioms_ (for example, _Peano axioms_) for this theory is satisfied by _non-standard models_, e.g., interpretations $cal(I)'$ where $NatSort^cal(I)'$ includes other chains of elements besides the natural numbers.

  However, these models _falsify_ formulas that are _valid_ in $cal(T)_NatSort$.

  For example, "every number is either zero or a successor": $forall x. thin (x eqq 0) or exists y. thin (x eqq S(y))$.
  - #True in the _standard_ model, i.e. $NatSort^cal(I) = NN = {0, 1 := S(0), 2 := S(1), dots}$.
  - #False in _non-standard_ models, e.g., $NatSort^cal(I)' = {0, 1, 2, dots} union {omega, omega+1, dots}$
    - Intuitively, $omega$ is "an infinite element".
    - The successor function still applies: $S(omega) = omega + 1$, $S(omega + 1) = omega + 2$, etc.
    - Even the addition and multiplication still works: $omega + 3 = S(S(S(omega)))$, $omega times 2 = omega + omega$.
    - But $omega$ is larger than all standard numbers: $omega > 0, omega > 1, dots$
]

== Peano Arithmetic

#definition[
  _Peano arithmetic_ $cal(T)_"PA"$, or _first-order arithmetic_, is the axiomatic theory of natural numbers with signature $Sigma^F_"PA" = {0, S, +, times, =}$ and _Peano axioms_:
  + $forall x. thin (S(x) neq 0)$ #h(1fr) (zero) #h(6cm)
  + $forall x. forall y. thin (S(x) eq S(y)) imply (x eq y)$ #h(1fr) (successor) #h(6cm)
  + $F[0] and (forall x. thin F[x] imply F[x+1]) imply forall x. thin F[x]$ #h(1fr) (induction) #h(6cm)
  + $forall x. thin (x + 0 eq x)$ #h(1fr) (plus zero) #h(6cm)
  + $forall x. forall y. thin (x + S(y) eq S(x + y))$ #h(1fr) (plus successor) #h(6cm)
  + $forall x. thin (x times 0 eq 0)$ #h(1fr) (times zero) #h(6cm)
  + $forall x. forall y. thin (x times S(y) eq (x times y) + x)$ #h(1fr) (times successor) #h(6cm)

  Axiom (induction) is the _induction axiom schema_.
  It stands for an _infinite_ set of axioms, one for each $Sigma_"PA"$-formula $F$ with one free variable.
  The notation $F[alpha]$ means that $F$ contains $alpha$ as a sub-formula.

  The _intended interpretation_ (_standard models_) of $cal(T)_"PA"$ have the domain $NN$ and the usual interpretations of the function symbols as $0_NN$, $S_NN$, $+_NN$, and $times_NN$.
]

== Presburger Arithmetic

#note[
  Satisfiability and validity in $cal(T)_"PA"$ is undecidable.
  Therefore, we need a more restricted theory of arithmetic that does not include multiplication.
]

#definition[
  _Presburger arithmetic_ $cal(T)_NN$ is the axiomatic theory of natural numbers with signature $Sigma^F_NN = {0, S, +, =}$ and the _subset_ of _Peano axioms_:
  + $forall x. thin (S(x) neq 0)$ #h(1fr) (zero) #h(6cm)
  + $forall x. forall y. thin (S(x) eq S(y)) imply (x eq y)$ #h(1fr) (successor) #h(6cm)
  + $F[0] and (forall x. thin F[x] imply F[x+1]) imply forall x. thin F[x]$ #h(1fr) (induction) #h(6cm)
  + $forall x. thin (x + 0 eq x)$ #h(1fr) (plus zero) #h(6cm)
  + $forall x. forall y. thin (x + S(y) eq S(x + y))$ #h(1fr) (plus successor) #h(6cm)
]

#note[
  Presburger arithmetic is decidable.
]

== Completeness of Theories

#definition[
  A $Sigma$-theory $cal(T)$ is _complete_ if for every $Sigma$-sentence $alpha$, either $alpha$ or $not alpha$ is valid in $cal(T)$.
]
#note[
  In a complete $Sigma$-theory, every $Sigma$-sentence is either valid or unsatisfiable.
]

#example[
  Any theory $cal(T) = angle.l Sigma, bold(M) angle.r$ where all interpretations in $bold(M)$ only differ in how they interpret the variables (e.g., $cal(T)_"RA"$) is _complete_.
]

#example[
  The axiomatic (mono-sorted) theory of _monoids_ with $Sigma^F = {thin dot thin, epsilon}$ and axioms
  $
    forall x. forall y. forall z. thin (x dot y) dot z eqq x dot (y dot z)
    quad quad
    forall x. thin (x dot epsilon eqq x)
    quad quad
    forall x. thin (epsilon dot x eqq x)
  $
  is _incomplete_.
  For example, the sentence $forall x. forall y. thin (x dot y eqq y dot x)$ is #True in some monoids (e.g. the addition of integers _is_ commutative) but #False in others (e.g. the concatenation of strings _is not_ commutative).
]

#pagebreak()
#example[
  The axiomatic (mono-sorted) theory of _dense linear orders without endpoints_ with $Sigma^F = {prec}$ and the following axioms is _complete_.
  #grid(
    columns: 2,
    align: (right, left),
    column-gutter: 1em,
    row-gutter: 1em,
    $forall x. forall y. (x prec y) imply exists z. thin ((x prec z) and (z prec y))$, [(dense)],
    $forall x. forall y. thin ((x prec y) or (y prec x) or (x eqq y))$, [(linear)],
    $forall x. thin not (x prec x) quad forall x. forall y. forall z. thin ((x prec y) and (y prec z) imply (x prec z))$,
    [(orders)],

    $forall x. exists y. thin (y prec x) quad forall x. exists y. thin (x prec y)$, [(without endpoints)],
  )
]

== Decidability

Recall that a set $A$ is _decidable_ if there exists a _terminating_ procedure that, given an input element $a$, returns (after _finite_ time) either "yes" if $a in A$ or "no" if $a notin A$.

#definition[
  A theory $cal(T) = angle.l Sigma, bold(M) angle.r$ is _decidable_ if the set of all _$cal(T)$-valid_ $Sigma$-formulas is decidable.
]

#definition[
  A _fragment_ of $cal(T)$ is a _syntactically-restricted subset_ of $cal(T)$-valid $Sigma$-formulas.
]
#example[
  The _quantifier-free_ fragment of $cal(T)$ is the set of all $cal(T)$-valid $Sigma$-formulas _without quantifiers_.
]
#example[
  The _linear_ fragment of $cal(T)_"RA"$ is the set of all $cal(T)$-valid $Sigma_"RA"$-formulas _without multiplication_ ($times$).
]

== Axiomatizability

#definition[
  A theory $cal(T) = angle.l Sigma, bold(M) angle.r$ is _recursively axiomatizable_ if $bold(M)$ is the class of all interpretations satisfying a _decidable set_ of first-order axioms $cal(A)$.
]

// TODO: replace #theorem with #lemma
#theorem[Lemma][
  Every recursively axiomatizable theory $cal(T)$ admits a procedure $E_cal(T)$ that _enumerates_ all $cal(T)$-valid formulas.
]

#theorem[
  For every _complete_ and _recursively axiomatizable_ theory $cal(T)$, validity in $cal(T)$ is decidable.
]
#proof[
  Given a formula $alpha$, use $E_cal(T)$ to enumerate all valid formulas.
  Since $cal(T)$ is complete, either $alpha$ or $not alpha$ will eventually (after _finite_ time) be produced by $E_cal(T)$.
]

== Common Theories in SMT

Satisfiability Modulo Theories (SMT) traditionally focuses on theories with _decidable quantifier-free fragments_.

SMT is concerned with (un)satisfiability, but recall that a formula $alpha$ is _$cal(T)$-valid_ iff $not alpha$ is _$cal(T)$-unsatisfiable_.

Checking the (un)satisfiability of quantifier-free formulas in main background theories _efficiently_ has a large number of applications in:
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

== From Quantifier-Free Formulas to Conjunctions of Literals

#theorem[
  The satisfiability of _quantifier-free_ formulas in a theory $cal(T)$ is _decidable_ iff the satisfiability in $cal(T)$ of _conjunctions of literals_ is decidable.

  Here, _literal_ is an atom or its negation.
  For example: $(a eqq b)$, $not (a + 1 < b)$, $(f(b) eqq g(f(a)))$.
]

#proof[
  A quantifier-free formula can be transformed into disjunctive normal form (DNF), and its satisfiability reduces to checking satisfiability of conjunctions of literals.
  Conversely, a conjunction of literals is a special case of a quantifier-free formula.
  Thus, the two satisfiability problems are equivalent.
]

== Theory of Uninterpreted Functions

#definition[
  Given a signature $Sigma$, the most general theory consists of the class of _all_ #box[$Sigma$-interpretations].
  In fact, this is a _family_ of theories parameterized by the signature $Sigma$.

  It is known as the theory of _equality with uninterpreted functions_ $cal(T)_"EUF"$, or the _empty theory_, since it contains no _sentences_.
]

#example[
  $(a eqq b) and (f(a) eqq b) and not (g(a) eqq g(f(a)))$
  Is this formula satisfiable in $cal(T)_"EUF"$?
]

Both validity and satisfiability are undecidable in $cal(T)_"EUF"$.
- Validity in $cal(T)_"EUF"$ is _semi-decidable_ --- this is just a validity in FOL.
- Since a formula $alpha$ is $cal(T)$-satisfiable iff $not alpha$ is not $cal(T)$-valid, $cal(T)_"EUF"$-satisfiability is _co-recognizable_.

However, the satisfiability of _conjunctions of $cal(T)_"EUF"$-literals_ is _decidable_, in polynomial time, using the _congruence closure_ algorithm.

== Theory of Real Arithmetic

The theory of real arithmetic $cal(T)_"RA"$ is a theory of inequalities over the real numbers.

- $Sigma^S = {RealSort}$
- $Sigma^F = {+, -, times, <} union {q | q "is a decimal numeral"}$
- $bold(M)$ is the class of interpretations that interpret $RealSort$ as the set of _real numbers_ $RR$, and the function symbols in the usual way.

Satisfiability in the full $cal(T)_"RA"$ is _decidable_ (in worst-case doubly-exponential time).

Restricted fragments of $cal(T)_"RA"$ can be decided more efficiently.

#example[
  Quantifier-free linear real arithmetic (`QF_LRA`) is the theory of _linear_ inequalities over the reals, where $times$ can only be used in the form of _multiplication by constants_ (decimal numerals).
]

The satisfiability of conjunctions of literals in `QF_LRA` is _decidable_ in _polynomial time_.

== Theory of Integer Arithmetic

The theory of integer arithmetic $cal(T)_"IA"$ is a theory of inequalities over the integers.

- $Sigma^S = {IntSort}$
- $Sigma^F = {+, -, times, <} union {n | n "is an integer numeral"}$
- $bold(M)$ is the class of interpretations that interpret $IntSort$ as the set of _integers_ $ZZ$, and the function symbols in the usual way.

Satisfiability in $cal(T)_"IA"$ is _not even semi-decidable_!

Satisfiability of quantifier-free $Sigma$-formulas in $cal(T)_"IA"$ is _undecidable_ as well.

_Linear integer arithmetic_ (`LIA`, also known as _Presburger arithmetic_) is decidable, but not efficiently (in~worst-case triply-exponential time).
Its quantifier-free fragment (`QF_LIA`) is NP-complete.

== Theory of Arrays with Extensionality

The theory of arrays $cal(T)_"AX"$ is useful for modelling RAM or array data structures.

- $Sigma^S = {Sort("A"), Sort("I"), Sort("E")}$ (arrays, indices, elements)
- $Sigma^F = {"read", "write"}$, where $rank("read") = angle.l Sort("A"), Sort("I"), Sort("E") angle.r$ and $rank("write") = angle.l Sort("A"), Sort("I"), Sort("E"), Sort("A") angle.r$

Let $a$ be a variable of sort $Sort("A")$, variable $i$ of sort $Sort("I")$, and variable $v$ of sort $Sort("E")$.
- $"read"(a, i)$ denotes the value stored in array $a$ at index $i$.
- $"write"(a, i, v)$ denotes the array that stores value $v$ at index $i$ and is otherwise identical to $a$.

#example[
  $"read"("write"(a, i, v), i) eqq_Sort("E") v$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
]
#example[
  $forall i. thin ("read"(a, i) eqq_Sort("E") "read"(a', i)) imply (a eqq_Sort("A") a')$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
]
#example[
  $forall a. thin (forall i. thin ("read"(a, i) eqq_Sort("E") "read"(a', i))) imply (a eqq_Sort("A") a')$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
]

#pagebreak()
The theory of arrays $cal(T)_"AX" = angle.l Sigma, bold(M) angle.r$ is finitely axiomatizable.

$bold(M)$ is the class of interpretations that satisfy the following axioms:
+ $forall a. forall i. forall v. thin ("read"("write"(a, i, v), i) eqq_Sort("E") v)$
+ $forall a. forall i. forall j. forall v. thin not (i eqq_Sort("I") j) imply ("read"("write"(a, i, v), j) eqq_Sort("E") "read"(a, j))$
+ $forall a. forall b. thin (forall i. thin ("read"(a, i) eqq_Sort("E") "read"(b, i))) imply (a eqq_Sort("A") b)$

#note[
  The last axiom is called _extensionality_ axiom.
  It states that two arrays are equal if they have the same values at all indices.
  It can be omitted to obtain a theory of arrays _without extensionality_ $cal(T)_"A"$.
]

Validity and satisfiability in $cal(T)_"AX"$ is _undecidable_.

There are several _decidable_ _fragments_ of $cal(T)_"A"$.

== Survey of Decidability and Complexity

#table(
  columns: 6,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[Theory][Description][Full][QF][Full complexity][QFC complexity],
  [PL], [Propositional Logic], [---], [yes], [NP-complete], [$Theta(n)$],
  [$cal(T)_"EUF"$], [Equality], [no], [yes], [undecidable], [$cal(O)(n log n)$],
  [$cal(T)_"PA"$], [Peano Arithmetic], [no], [no], [undecidable], [undecidable],
  [$cal(T)_NN$], [Presburger Arithmetic], [yes], [yes], [$Omega(2^2^n)$, $cal(O)(2^2^2^(k n))$], [NP-complete],
  [$cal(T)_ZZ$], [Linear Integers (LIA)], [yes], [yes], [$Omega(2^2^n)$, $cal(O)(2^2^2^(k n))$], [NP-complete],
  [$cal(T)_RR$], [Reals], [yes], [yes], [$cal(O)(2^2^(k n))$], [$cal(O)(2^2^(k n))$],
  [$cal(T)_QQ$], [Linear Rationals], [yes], [yes], [$Omega(2^n)$, $cal(O)(2^2^(k n))$], [PTIME],
  [$cal(T)_"RDS"$], [Recursive Data Structures], [no], [yes], [undecidable], [$cal(O)(n log n)$],
  [$cal(T)_"ARDS"$], [Acyclic RDS], [yes], [yes], [not elementary recursive], [$Theta(n)$],
  [$cal(T)_"A"$], [Arrays], [no], [yes], [undecidable], [NP-complete],
  [$cal(T)_"AX"$], [Arrays with Extensionality], [no], [yes], [undecidable], [NP-complete],
)

#pagebreak()
Legend for the table:
- *"Full"* denotes the decidability of a complete theory _with_ quantifiers.
- *"QF"* denotes the decidability of a _quantifier-free_ theory.
- *"Full complexity"* denotes the complexity of the satisfiability in a complete theory _with quantifiers_.
- *"QFC complexity"* denotes the complexity of the satisfiability in a _quantifier-free conjunctive_ fragment.
- For complexities, $n$ is the size of the input formula, $k$ is some positive integer.
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

    blob((0, 0), [Set of literals], name: <input>, shape: rect, tint: teal, height: 2em),
    edge("-|>"),
    blob((1, 0), [$cal(T)$-solver], name: <solver>, shape: hexagon, tint: purple, height: 2em),
    blob((2, -0.5), [Consistent \ (SAT)], name: <sat>, shape: rect, tint: green, height: 3em),
    blob((2, 0.5), [Inconsistent \ (UNSAT)], name: <unsat>, shape: rect, tint: red, height: 3em),
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
- $(x - y = 5) arrow.double.long (x - y lt.eq 5) and (y - x lt.eq -5)$
- $(z - y gt.eq 2) arrow.double.long (y - z lt.eq -2)$
- $(z - x > 2) arrow.double.long (x - z lt.eq -3)$
- $(w - x = 2) arrow.double.long (w - x lt.eq 2) and (x - w lt.eq -2)$
- $(z - w < 0) arrow.double.long (z - w lt.eq -1)$

#place(bottom + right, dy: -1cm)[
  #import fletcher: diagram, node, edge
  #import fletcher.shapes: *
  #diagram(
    edge-stroke: 1pt,
    node-outset: 2pt,
    spacing: 4em,
    node((0, 0), [$x$], name: <x>, shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%)),
    node((1, -1), [$y$], name: <y>, shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%)),
    node((1, 1), [$w$], name: <w>, shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%)),
    node((2, 0), [$z$], name: <z>, shape: circle, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%)),
    edge(<x>, <y>, "-}>", [$5$], label-side: center, bend: 30deg),
    edge(<y>, <x>, "-}>", [$-5$], label-side: center, bend: 30deg),
    edge(<x>, <w>, "-}>", [$-2$], label-side: center, bend: 30deg),
    edge(<w>, <x>, "-}>", [$2$], label-side: center, bend: 30deg),
    edge(<x>, <z>, "-}>", [$-3$], label-side: center),
    edge(<y>, <z>, "-}>", [$-2$], label-side: center, bend: 30deg),
    edge(<z>, <w>, "-}>", [$-1$], label-side: center, bend: 30deg),
  )
]

*UNSAT* because of the negative cycle: $x to^(-3) z to^(-1) w to^(2) x$.

= Satisfiability Proof Systems

== Flattening

#definition[
  A literal is _flat_ if it is of the form:
  - $x eqq y$
  - $not (x eqq y)$
  - $x eqq f(bold(z))$
  where $x$ and $y$ are variables, $f$ is a function symbol, and $bold(z)$ is a tuple of 0 or more variables.
]

#note[
  Any set of literals can be converted to an equisatisfiable set of _flat_ literals by introducing _new_ variables and equating non-equational atoms to #True.
]

#example[
  Consider the set of literals: ${ x + y > 0, y eqq f(g(z)) }$.

  We can convert it to an equisatisfiable set of flat literals by introducing fresh variables $v_1$, $v_2$, $v_3$ and $v_4$:
  $
    {med v_1 eqq v_2 > v_3, quad v_1 eqq True, quad v_2 eqq x + y, quad v_3 eqq 0, quad y eqq f(v_4), quad v_4 eqq g(z) med}
  $
]

Hereinafter, we will assume that all literals are _flat_.

== Notation and Assumptions

- We abbreviate $not (s eqq t)$ with $s neqq t$.

- For tuples $bold(u) = angle.l u_1, dots, u_n angle.r$ and $bold(v) = angle.l v_1, dots, v_n angle.r$, we abbreviate $(u_1 eqq v_1) and dots and (u_n eqq v_n)$ with $bold(u) = bold(v)$.
- $Gamma$ is used to refer to the "current" proof state in rule premises.
- $Gamma, s eqq t$ is an abbreviation for $Gamma union {s eqq t}$.
- If applying a rule $R$ does not change $Gamma$, then $R$ _is not applicable_ to $Gamma$, that is, $Gamma$ is _irreducible_ w.r.t. $R$.

== Theory of Equality with Uninterpreted Functions

#definition[
  The theory of equality with uninterpreted functions $cal(T)_"EUF"$ is defined by the signature $Sigma^F = {eqq, f, g, h, dots}$ (_interpreted_ equality and _uninterpreted_ functions) and the following axioms:
  - $forall x. thin x eqq x$ #h(1fr) (reflexivity) #h(5cm)
  - $forall x. forall y. thin (x eqq y) imply (y eqq x)$ #h(1fr) (symmetry) #h(5cm)
  - $forall x. forall y. forall z. thin (x eqq y) and (y eqq z) imply (x eqq z)$ #h(1fr) (transitivity) #h(5cm)
  - $forall bold(x). forall bold(y). thin (and.big_(i = 1)^n x_i eqq y_i) imply (f(bold(x)) eqq f(bold(y)))$ #h(1fr) (function congruence) #h(5cm)
]

== Satisfiability Proof System for `QF_UF`

Let `QF_UF` be the quantifier-free fragment of FOL over some signature $Sigma$.

Below is a simple satisfiability proof system $R_"UF"$ for `QF_UF`:
#align(center)[
  #import curryst: prooftree, rule
  #grid(
    columns: 2,
    align: left,
    column-gutter: 1cm,
    inset: 5pt,
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Refl*],
        $Gamma := Gamma, x eqq x$,
        [$x$ occurs in $Gamma$],
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Symm*],
        $Gamma := Gamma, y eqq x$,
        $x neqq y in Gamma$,
      ),
    ),

    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Trans*],
        $Gamma := Gamma, x eqq z$,
        $x neqq y in Gamma$,
        $y eqq z in Gamma$,
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Cong*],
        $Gamma := Gamma, x eqq y$,
        $x eqq f(bold(u)) in Gamma$,
        $y eqq f(bold(v)) in Gamma$,
        $bold(u) = bold(v) in Gamma$,
      ),
    ),

    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Contr*],
        [UNSAT],
        $x eqq y in Gamma$,
        $x neqq y in Gamma$,
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*SAT*],
        [SAT],
        [No other rules apply],
      ),
    ),
  )
]

Is $R_"UF"$ _sound_?

Is $R_"UF"$ _terminating_?

== Example Derivation in $R_"UF"$

#align(center)[
  #import curryst: prooftree, rule
  #set text(size: 0.8em)
  #show: box.with(inset: 1em, radius: 1em, stroke: 0.4pt)
  #grid(
    columns: 3,
    align: left,
    column-gutter: 1em,
    row-gutter: 1em,
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Refl*],
        $Gamma := Gamma, x eqq x$,
        [$x$ occurs in $Gamma$],
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Contr*],
        [UNSAT],
        $x eqq y in Gamma$,
        $x neqq y in Gamma$,
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Trans*],
        $Gamma := Gamma, x eqq z$,
        $x neqq y in Gamma$,
        $y eqq z in Gamma$,
      ),
    ),

    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Symm*],
        $Gamma := Gamma, y eqq x$,
        $x neqq y in Gamma$,
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*Cong*],
        $Gamma := Gamma, x eqq y$,
        $x eqq f(bold(u)) in Gamma$,
        $y eqq f(bold(v)) in Gamma$,
        $bold(u) = bold(v) in Gamma$,
      ),
    ),
    prooftree(
      title-inset: 5pt,
      vertical-spacing: 2pt,
      rule(
        label: smallcaps[*SAT*],
        [SAT],
        [No other rules apply],
      ),
    ),
  )
]

#example[
  Determine the satisfiability of the following set of literals:
  $a eqq f(f(a))$, $a eqq f(f(f(a)))$, $g(a, f(a)) neqq g(f(a), a)$.
  Flatten the literals and construct the following proof:
  #align(center)[
    #import curryst: prooftree, rule
    #prooftree(
      rule(
        name: [#smallcaps[Contr] applied to $a_3 eqq a_4, a_3 neqq a_4$],
        [UNSAT],
        rule(
          name: [#smallcaps[Cong] applied to $a_3 eqq g(a, a_1), a_4 eqq g(a_1, a), a eqq a_1, a_1 eqq a$],
          $a_3 eqq a_4$,
          rule(
            name: [#smallcaps[Symm]],
            $a eqq a_1$,
            rule(
              name: [#smallcaps[Cong] applied to $a_1 eqq f(a), a eqq f(a_2), a eqq a_2$],
              $a_1 eqq a$,
              rule(
                name: [#smallcaps[Cong] applied to $a eqq f(a_1), a_2 eqq f(a_1), a_1 eqq a_1$],
                $a eqq a_2$,
                rule(
                  name: [#smallcaps[Refl]],
                  $a_1 eqq a_1$,
                  $a eqq f(a_1), a_1 eqq f(a), a eqq f(a_2), a_2 eqq f(a_1), a_3 neqq a_4, a_3 eqq g(a, a_1), a_4 eqq g(a_1, a)$,
                ),
              ),
            ),
          ),
        ),
      ),
    )
  ]
]

== Soundness of $R_"UF"$

#theorem[Refutation soundness][
  A literal set $Gamma_0$ is unsatisfiable if $R_"UF"$ derives UNSAT from it.
]
#proof[
  All rules except #smallcaps[SAT] are satisfiability-preserving.

  If a derivation from $Gamma_0$ ends with UNSAT, then $Gamma_0$ must be unsatisfiable.
]

#theorem[Solution soundness][
  A literal set $Gamma_0$ is satisfiable if $R_"UF"$ derives SAT from it.
]
#proof[
  Let $Gamma$ be a proof state to which #smallcaps[SAT] applies.
  From $Gamma$, we can construct an interpretation $cal(I)$ that satisfies $Gamma_0$.
  Let $s tilde t$ iff $(s eqq t) in Gamma$.
  One can show that $tilde$ is an equivalence relation.

  Let the domain of $cal(I)$ be the equivalence classes $E_1, dots, E_k$ of $tilde$.
  - For every variable or a constant $t$, let $t^cal(I) = E_i$ if $t in E_i$ for some $i$.
    Otherwise, let $t^cal(I) = E_1$.
  - For every unary function symbol $f$, and equivalence class $E_i$, let $f^cal(I)$ be such that $f^cal(I)(E_i) = E_j$ if #box[$f(t) in E_j$] for some $t in E_i$.
    Otherwise, let $f^cal(I)(E_i) = E_1$.
    Define $f^cal(I)$ for non-unary $f$ similarly.

  We can show that $cal(I) models Gamma$.
  This means that $cal(I)$ models $Gamma_0$ as well since $Gamma_0 subset.eq Gamma$.
]

== Termination in $R_"UF"$

#theorem[
  Every derivation strategy for $R_"UF"$ terminates.
]
#proof[
  $R_"UF"$ adds to the current state $Gamma$ only equalities between variables of $Gamma_0$.

  So, at some point it will run out of new equalities to add.
]

== Completeness of $R_"UF"$

#theorem[Refutation completeness][
  Every derivation strategy applied to an unsatisfiable state $Gamma_0$ ends with UNSAT.
]
#proof[
  Let $Gamma_0$ be an unsatisfiable state.
  Suppose there was a derivation from $Gamma_0$ that did not end with UNSAT.
  Then, by the termination theorem, it would have to end with SAT.
  But then $R_"UF"$ would be not be solution sound.
]

#theorem[Solution completeness][
  Every derivation strategy applied to a satisfiable state $Gamma_0$ ends with SAT.
]
#proof[
  Let $Gamma_0$ be a satisfiable state.
  Suppose there was a derivation from $Gamma_0$ that did not end with SAT.
  Then, by the termination theorem, it would have to end with UNSAT.
  But then $R_"UF"$ would be not be refutation sound.
]

== TODO

- theory of arrays $cal(T)_"A"$
- satisfiability proof system for $cal(T)_"A"$
- soundness, termination, completeness
- LRA, Linear programming, Simplex algorithm
- Strings solver
