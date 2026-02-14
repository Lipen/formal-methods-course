#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Satisfiability Modulo Theories",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

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
#let ASort = Sort("A")
#let ISort = Sort("I")
#let ESort = Sort("E")
#let USort = Sort("U")
#let PersonSort = Sort("Person")
#let ElemSort = Sort("Elem")
#let XSort = Sort("X")
#let YSort = Sort("Y")

= Many-Sorted First-Order Logic

== Why Many-Sorted?

In standard (mono-sorted) FOL, _all_ variables range over a _single_ domain. This is too restrictive for practical reasoning:

- *Programming languages* have _typed_ variables: `int x`, `bool b`, `double[] arr`.
- *Databases* distinguish between strings, integers, dates, etc.
- *Mathematics* itself uses distinct sorts: $NN$, $RR$, matrices, functions, etc.

#Block(color: yellow)[
  *Key insight:* _Many-sorted FOL_ is a natural generalization of FOL where each variable, constant, and function is associated with a _sort_ (type). This is exactly what SMT solvers use internally, and what SMT-LIB expresses.
]

#note[
  We have already seen first-order logic in the previous lecture. Here, we generalize it to the _many-sorted_ setting, which is the standard framework for SMT.
]

== Many-Sorted Signatures

#definition[
  A _many-sorted signature_ $Sigma = chevron.l Sigma^S, Sigma^F chevron.r$ consists of:
  - $Sigma^S$ --- a set of _sorts_ (also called _types_), e.g. $BoolSort$, $IntSort$, $RealSort$, $ArraySort$.
  - $Sigma^F$ --- a set of _function symbols_, e.g. $=$, $+$, $<$, $"read"$, $"write"$.
]

#definition[
  Each _function symbol_ $f in Sigma^F$ has a _rank_ --- an $(n+1)$-tuple of sorts:
  $ rank(f) = chevron.l sigma_1, dots, sigma_n, sigma_(n+1) chevron.r $
  Intuitively, $f$ takes $n$ arguments of sorts $sigma_1, dots, sigma_n$ and returns a value of sort $sigma_(n+1)$.
  - Functions of arity 0 are called _constants_, with $rank(f) = chevron.l sigma chevron.r$.
  - Functions returning $BoolSort$ are called _predicates_.
]

#note[
  Every signature includes a distinguished sort $BoolSort$ with constants $top$ and $bot$, and an _equality predicate_ $eqq_sigma$ with $rank(eqq_sigma) = chevron.l sigma, sigma, BoolSort chevron.r$ for each sort $sigma$.
]

== Signature Examples

#columns(2)[
  *Number Theory:*
  - $Sigma^S = {NatSort, BoolSort}$
  - $Sigma^F = {0, S, <, +, times, eqq_NatSort, dots}$
  - $rank(0) = chevron.l NatSort chevron.r$
  - $rank(S) = chevron.l NatSort, NatSort chevron.r$
  - $rank(<) = chevron.l NatSort, NatSort, BoolSort chevron.r$
  - $rank(+) = chevron.l NatSort, NatSort, NatSort chevron.r$

  #colbreak()

  *Arrays:*
  - $Sigma^S = {ArraySort, ISort, ESort, BoolSort}$
  - $Sigma^F = {"read", "write", eqq_ArraySort, dots}$
  - $rank("read") = chevron.l ArraySort, ISort, ESort chevron.r$
  - $rank("write") = chevron.l ArraySort, ISort, ESort, ArraySort chevron.r$
]

#v(1em)

#example[
  _Propositional logic_ can be viewed as a _one-sorted_ theory:
  - $Sigma^S = {BoolSort}$, $Sigma^F = {not, and, or, p_1, p_2, dots}$
  - $rank(p_i) = chevron.l BoolSort chevron.r$ (propositional variables are Boolean constants)
  - $rank(not) = chevron.l BoolSort, BoolSort chevron.r$, $rank(and) = chevron.l BoolSort, BoolSort, BoolSort chevron.r$
]

== Terms and Formulas

A _well-sorted term_ of sort $sigma$ is built from variables, constants, and function applications that _respect_ the rank:

- A variable $x$ of sort $sigma$ is a term of sort $sigma$.
- A constant $c$ with $rank(c) = chevron.l sigma chevron.r$ is a term of sort $sigma$.
- If $f$ has $rank(f) = chevron.l sigma_1, dots, sigma_n, sigma chevron.r$ and $t_1, dots, t_n$ are terms of sorts $sigma_1, dots, sigma_n$, then $f(t_1, dots, t_n)$ is a term of sort $sigma$.

#example[
  In the Number Theory signature with $x : NatSort$:
  - $S(0)$ is a well-sorted term of sort $NatSort$ #YES
  - $S(x) + 0$ is a well-sorted term of sort $NatSort$ #YES
  - $S(x < 0)$ is _not_ well-sorted: $<$ returns $BoolSort$, but $S$ expects $NatSort$ #NO
]

A _$Sigma$-formula_ is built from _atoms_ (terms of sort $BoolSort$) using the standard logical connectives ($not$, $and$, $or$, $imply$, $iff$) and quantifiers ($forall x : sigma. thin phi$, $exists x : sigma. thin phi$).

== Many-Sorted Interpretations

#definition[
  A _many-sorted interpretation_ $cal(I)$ of a signature $Sigma = chevron.l Sigma^S, Sigma^F chevron.r$ assigns:
  - To each sort $sigma in Sigma^S$, a non-empty _domain_ $sigma^cal(I)$ (e.g. $IntSort^cal(I) = ZZ$, $BoolSort^cal(I) = {True, False}$).
  - To each function symbol $f$ with $rank(f) = chevron.l sigma_1, dots, sigma_n, sigma chevron.r$, a function $f^cal(I) : sigma_1^cal(I) times dots.c times sigma_n^cal(I) to sigma^cal(I)$.
  - To each variable $x$ of sort $sigma$, a value $x^cal(I) in sigma^cal(I)$.
]

#example[
  For the Number Theory signature, one interpretation is:
  - $NatSort^cal(I) = NN$, $0^cal(I) = 0$, $S^cal(I)(n) = n + 1$, $+^cal(I)(m, n) = m + n$
  - $<^cal(I)(m, n) = True$ iff $m < n$ in the usual sense
  This is the _intended_ (standard) interpretation of natural numbers.
]

#Block(color: blue)[
  *Mono-sorted vs. many-sorted:* The only difference is that each variable, constant, and function is now tagged with a sort. Connective semantics ($not$, $and$, $or$, $forall$, $exists$) remain exactly the same. Quantifiers now range over the domain of a _specific sort_: $(forall x : sigma. thin phi)$ means "for all $x$ in $sigma^cal(I)$".
]

= First-Order Theories

== Motivation

Consider the signature $Sigma = chevron.l Sigma^S, Sigma^F chevron.r$ for a fragment of number theory:
- $Sigma^S = {NatSort}$, $Sigma^F = {0, 1, +, <}$
- $rank(0) = rank(1) = chevron.l NatSort chevron.r$
- $rank(+) = chevron.l NatSort, NatSort, NatSort chevron.r$
- $rank(<) = chevron.l NatSort, NatSort, BoolSort chevron.r$

+ Consider the $Sigma$-sentence: $forall x : NatSort. thin not (x < x)$ \
  - Is it _valid_, that is, true under _all_ interpretations?
  - No, e.g., if we interpret $<$ as _equals_ or _divides_.

+ Consider the $Sigma$-sentence: $not exists x : NatSort. thin (x < 0)$
  - Is it _valid_?
  - No, e.g., if we interpret $NatSort$ as the set of _all_ integers.

+ Consider the $Sigma$-sentence: $forall x : NatSort. forall y : NatSort. forall z : NatSort. thin (x < y) and (y < z) imply (x < z)$
  - Is it _valid_?
  - No, e.g., if we interpret $<$ as the _successor_ relation.

#Block(color: yellow)[
  In practice, we often _do not care_ about satisfiability or validity in _general_, but rather with respect to a _limited class_ of interpretations.
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
  A first-order _theory_ $cal(T)$ is a pair#footnote[Here, we use *bold* style for $bold(M)$ to denote that it is _not a single_ model, but a _collection_ of them.] $chevron.l Sigma, bold(M) chevron.r$, where
  - $Sigma = chevron.l Sigma^S, Sigma^F chevron.r$ is a first-order signature,
  - $bold(M)$ is a class#footnote[_Class_ is a generalization of a set.] of $Sigma$-interpretations over $X$ that is _closed under variable re-assignment_.
]

#definition[
  $bold(M)$ is _closed under variable re-assignment_ if every $Sigma$-interpretation that differs from one in $bold(M)$ in the way it interprets the variables in $X$ is also in $bold(M)$.
]

#Block(color: yellow)[
  A theory limits the interpretations of $Sigma$-formulas to those from $bold(M)$.
]

== Theory Examples

#example[
  Theory of Real Arithmetic $cal(T)_"RA" = chevron.l Sigma_"RA", bold(M)_"RA" chevron.r$:
  - $Sigma^S_"RA" = {RealSort}$
  - $Sigma^F_"RA" = {+, -, times, lt.eq} union {q | q "is a decimal numeral"}$
  - All $cal(I) in bold(M)_"RA"$ interpret $RealSort$ as the set of _real numbers_ $RR$, each $q$ as the _decimal number_ that it denotes, and the function symbols in the usual way.
]

#example[
  Theory of Ternary Strings $cal(T)_"TS" = chevron.l Sigma_"TS", bold(M)_"TS" chevron.r$:
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
  Given a theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$, a _$cal(T)$-interpretation_ is any #box[$Omega$-interpretation] $cal(I)$ for some signature $Omega supset.eq Sigma$ such that $cal(I)^Sigma in bold(M)$.
]
#note[
  This definition allows us to consider the satisfiability in a theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$ of formulas that contain sorts or function symbols not in $Sigma$.
  These symbols are usually called _uninterpreted_ (in $cal(T)$).
]

#pagebreak()

#example[
  Consider again the theory of real arithmetic $cal(T)_"RA" = chevron.l Sigma_"RA", bold(M)_"RA" chevron.r$.

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

For every signature $Sigma$, entailment and validity in "pure" FOL can be seen as entailment and validity in the theory $cal(T)_"FOL" = chevron.l Sigma, bold(M)_"FOL" chevron.r$ where $bold(M)_"FOL"$ is the class of _all possible_ $Sigma$-interpretations.

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
  - Given an axiomatic theory $cal(T)'$ defined by $Sigma$ and $cal(A)$, we can define a theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$ where $bold(M)$ is the class of all $Sigma$-interpretations that satisfy all axioms in $cal(A)$.
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
  Any theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$ where all interpretations in $bold(M)$ only differ in how they interpret the variables (e.g., $cal(T)_"RA"$) is _complete_.
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

== Decidability and Fragments

Recall that a set $A$ is _decidable_ if there exists a _terminating_ procedure that, given an input element $a$, returns (after _finite_ time) either "yes" if $a in A$ or "no" if $a notin A$.

#definition[
  A theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$ is _decidable_ if the set of all _$cal(T)$-valid_ $Sigma$-formulas is decidable.
]

#definition[
  A _fragment_ of $cal(T)$ is a _syntactically-restricted subset_ of $cal(T)$-valid $Sigma$-formulas.
]
#example[
  The _quantifier-free_ fragment of $cal(T)$ is the set of all $cal(T)$-valid $Sigma$-formulas _without quantifiers_.
  The _linear_ fragment of $cal(T)_"RA"$ is the set of all $cal(T)$-valid $Sigma_"RA"$-formulas _without multiplication_ ($times$).
]

== Axiomatizability

#definition[
  A theory $cal(T) = chevron.l Sigma, bold(M) chevron.r$ is _recursively axiomatizable_ if $bold(M)$ is the class of all interpretations satisfying a _decidable set_ of first-order axioms $cal(A)$.
]

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

= Introduction to SMT

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
- A few of those _theories_ and their _decision procedures_.
- _Proof systems_ to reason _modulo theories_ automatically.

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

== Theory Solvers

#definition[$cal(T)$-solver][
  A _theory solver_, or _$cal(T)$-solver_, is a specialized decision procedure for the satisfiability of conjunctions of literals in a theory $cal(T)$.
]

#align(center)[
  #import fletcher: diagram, node, edge
  #import fletcher.shapes: *
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

#Block(color: yellow)[
  *Key insight:* A $cal(T)$-solver is the bridge between SAT and theory reasoning. It answers: "Is this set of theory literals consistent in this domain?"
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

#definition[
  The theory of _real arithmetic_ $cal(T)_"RA"$ is a theory of inequalities over the real numbers.
  - $Sigma^S = {RealSort}$
  - $Sigma^F = {+, -, times, <} union {q | q "is a decimal numeral"}$
  - $bold(M)$ is the class of interpretations that interpret $RealSort$ as the set of _real numbers_ $RR$, and the function symbols in the usual way.
]

Satisfiability in the full $cal(T)_"RA"$ is _decidable_ (in worst-case doubly-exponential time).

Restricted fragments of $cal(T)_"RA"$ can be decided more efficiently.

#example[
  Quantifier-free linear real arithmetic (`QF_LRA`) is the theory of _linear_ inequalities over the reals, where $times$ can only be used in the form of _multiplication by constants_ (decimal numerals).
]

The satisfiability of conjunctions of literals in `QF_LRA` is _decidable_ in _polynomial time_.

== Theory of Integer Arithmetic

#definition[
  The theory of _integer arithmetic_ $cal(T)_"IA"$ is a theory of inequalities over the integers.
  - $Sigma^S = {IntSort}$
  - $Sigma^F = {+, -, times, <} union {n | n "is an integer numeral"}$
  - $bold(M)$ is the class of interpretations that interpret $IntSort$ as the set of _integers_ $ZZ$, and the function symbols in the usual way.
]

Satisfiability in $cal(T)_"IA"$ is _not even semi-decidable_!

Satisfiability of quantifier-free $Sigma$-formulas in $cal(T)_"IA"$ is _undecidable_ as well.

_Linear integer arithmetic_ (`LIA`, also known as _Presburger arithmetic_) is decidable, but not efficiently (in~worst-case triply-exponential time).
Its quantifier-free fragment (`QF_LIA`) is NP-complete.

== Theory of Arrays with Extensionality

#definition[
  The theory of _arrays_ $cal(T)_"AX"$ is useful for modelling RAM or array data structures.
  - $Sigma^S = {ASort, ISort, ESort}$ (arrays, indices, elements)
  - $Sigma^F = {"read", "write"}$, where $rank("read") = chevron.l ASort, ISort, ESort chevron.r$ and $rank("write") = chevron.l ASort, ISort, ESort, ASort chevron.r$

  Let $a$ be a variable of sort $ASort$, variable $i$ of sort $ISort$, and variable $v$ of sort $ESort$.
  - $"read"(a, i)$ denotes the value stored in array $a$ at index $i$.
  - $"write"(a, i, v)$ denotes the array that stores value $v$ at index $i$ and is otherwise identical to $a$.
]

#example[
  $"read"("write"(a, i, v), i) eqq_ESort v$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
]
#example[
  $forall i. thin ("read"(a, i) eqq_ESort "read"(a', i)) imply (a eqq_ASort a')$
  - Is this formula _intuitively_ valid/satisfiable/unsatisfiable in $cal(T)_"A"$?
]

#pagebreak()

#definition[
  The theory of arrays $cal(T)_"AX" = chevron.l Sigma, bold(M) chevron.r$ is finitely axiomatizable.

  $bold(M)$ is the class of interpretations that satisfy the following axioms:
  + $forall a. forall i. forall v. thin ("read"("write"(a, i, v), i) eqq_ESort v)$
  + $forall a. forall i. forall j. forall v. thin not (i eqq_ISort j) imply ("read"("write"(a, i, v), j) eqq_ESort "read"(a, j))$
  + $forall a. forall b. thin (forall i. thin ("read"(a, i) eqq_ESort "read"(b, i))) imply (a eqq_ASort b)$
]

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

== Roadmap

In the following sections, we will study _theory solvers_ for several important theories:

+ *Difference Logic* (DL) --- a very restricted fragment of integer arithmetic; solved via _graph-based_ cycle detection.
+ *Equality with Uninterpreted Functions* ($cal(T)_"EUF"$) --- the "empty" theory; solved via _congruence closure_.
+ *Arrays* ($cal(T)_"AX"$) --- models memory/arrays; extends the EUF proof system.
+ *Linear Real Arithmetic* ($cal(T)_"RA"$) --- linear inequalities over $RR$; solved via the _Simplex_ algorithm.

We will then see how to _combine_ theory solvers (Nelson-Oppen method), build a complete _SMT solver_ (CDCL($cal(T)$) architecture), and use the _SMT-LIB_ standard language with the Z3 solver.

= Difference Logic

== Difference Logic

#definition[
  _Difference logic_ (DL) is a fragment of linear integer arithmetic consisting of conjunctions of literals of the very restricted form:
  $ x - y join c $
  where $x$ and $y$ are integer variables, $c$ is a numeral, and $join in {eq, lt, lt.eq, gt, gt.eq}$.
]

A solver for difference logic consists of three steps:
+ Literals normalization.
+ Conversion to a graph.
+ Cycle detection.

== Decision Procedure for DL

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

= Equality

== Theory of Equality with Uninterpreted Functions

#definition[
  The theory of equality with uninterpreted functions $cal(T)_"EUF"$ is defined by the signature $Sigma^F = {eqq, f, g, h, dots}$ (_interpreted_ equality and _uninterpreted_ functions) and the following axioms:
  + $forall x. thin x eqq x$ #h(1fr) (reflexivity) #h(6cm)
  + $forall x. forall y. thin (x eqq y) imply (y eqq x)$ #h(1fr) (symmetry) #h(6cm)
  + $forall x. forall y. forall z. thin (x eqq y) and (y eqq z) imply (x eqq z)$ #h(1fr) (transitivity) #h(6cm)
  + $forall bold(x). forall bold(y). thin (bold(x) = bold(y)) imply (f(bold(x)) eqq f(bold(y)))$ #h(1fr) (function congruence) #h(6cm)
]

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

  We can convert it to an equisatisfiable set of flat literals by introducing fresh variables $v_i$:
  $
    {med v_1 eqq v_2 > v_3, quad v_1 eqq True, quad v_2 eqq x + y, quad v_3 eqq 0, quad y eqq f(v_4), quad v_4 eqq g(z) med}
  $
]

Hereinafter, we will assume that all literals are _flat_.

== Notation and Assumptions

- We abbreviate $not (s eqq t)$ with $s neqq t$.

- For tuples $bold(u) = chevron.l u_1, dots, u_n chevron.r$ and $bold(v) = chevron.l v_1, dots, v_n chevron.r$, we abbreviate $(u_1 eqq v_1) and dots and (u_n eqq v_n)$ with $bold(u) = bold(v)$.
- $Gamma$ is used to refer to the "current" proof state in rule premises.
- $Gamma, s eqq t$ is an abbreviation for $Gamma union {s eqq t}$.
- If applying a rule $R$ does not change $Gamma$, then $R$ _is not applicable_ to $Gamma$, that is, $Gamma$ is _irreducible_ w.r.t. $R$.

== Satisfiability Proof System for `QF_UF`

Let `QF_UF` be the quantifier-free fragment of FOL over some signature $Sigma$.

Below is a simple _satisfiability proof system_ $R_"UF"$ for `QF_UF`:
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
        label: smallcaps[*Symm*],
        $Gamma := Gamma, y eqq x$,
        $x neqq y in Gamma$,
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

#example[
  Determine the satisfiability of the following set of literals:
  $a eqq f(f(a))$, $a eqq f(f(f(a)))$, $g(a, f(a)) neqq g(f(a), a)$.
  Flatten the literals and construct the following proof:
  #align(center)[
    #import curryst: prooftree, rule
    #prooftree(
      title-inset: 5pt,
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

= Arrays

== Theory of Arrays

#definition[
  The theory of _arrays_ $cal(T)_"AX"$ is defined by the signature $Sigma^S = {ASort, ISort, ESort}$ (arrays, indices, elements), $Sigma^F = {"read", "write"}$ and the following axioms:
  + $forall a. forall i. forall v. thin ("read"("write"(a, i, v), i) eqq_ESort v)$
  + $forall a. forall i. forall j. forall v. thin not (i eqq_ISort j) imply ("read"("write"(a, i, v), j) eqq_ESort "read"(a, j))$
  + $forall a. forall b. thin (forall i. thin ("read"(a, i) eqq_ESort "read"(b, i))) imply (a eqq_ASort b)$
]

== Example

```c
void ReadBlock(int data[], int x, int len) {
  int i = 0;
  int next = data[0];
  for (; i < next && i < len; i = i + 1) {
    if (data[i] == x)
      break;
    else
      Process(data[i]);
  }
  assert(i < len);
}
```

One pass through this code can be translated into the following $cal(T)_"A"$ formula:
$
  ("i" eqq 0) and ("next" eqq "read"("data", 0)) and ("i" < "next") and \ and ("i" < "len") and ("read"("data", "i") eqq x) and not ("i" < "len")
$

== Satisfiability Proof System for `QF_AX`

The satisfiability proof system $R_"AX"$ for $cal(T)_"AX"$ _extends_ the proof system $R_"UF"$ for $cal(T)_"UF"$ with the following rules:

#align(center)[
  #import curryst: prooftree, rule
  #prooftree(
    title-inset: 5pt,
    vertical-spacing: 2pt,
    rule(
      label: smallcaps[*RIntro1*],
      $Gamma := Gamma, v eqq "read"(b, i)$,
      $b eqq "write"(a, i, v) in Gamma$,
    ),
  )
  #prooftree(
    title-inset: 5pt,
    vertical-spacing: 2pt,
    rule(
      label: smallcaps[*RIntro2*],
      $Gamma := Gamma, i eqq j #h(3em) Gamma := Gamma, i neqq j, u eqq "read"(a, j), u eqq "read"(b, j)$,
      $b eqq "write"(a, i, v) in Gamma$,
      $u eqq "read"(x, j) in Gamma$,
      $x in {a, b}$,
    ),
  )
  #prooftree(
    title-inset: 5pt,
    vertical-spacing: 2pt,
    rule(
      label: smallcaps[*Ext*],
      $Gamma := Gamma, u neqq v, u eqq "read"(a, k), v eqq "read"(b, k)$,
      $a neqq b in Gamma$,
      [$a$ and $b$ are arrays],
    ),
  )
]

- #smallcaps[*RIntro1*]: After writing $v$ at index $i$, the reading at the same index $i$ gives us back the value $v$.
- #smallcaps[*RIntro2*]: After writing $v$ in $a$ at index $i$, the reading from $a$ or $b$ at index $j$ _splits_ in two cases: (1)~$i$~equals~$j$, (2)~$a$~and~$b$ have the same value $u$ at position $j$.
- #smallcaps[*Ext*]: If two arrays $a$ and $b$ are distinct, they must differ at some index $k$.

== Example Derivation in $R_"AX"$

#example[
  Determine the satisfiability of ${ "write"(a_1, i, "read"(a_1, i)) eqq "write"(a_2, i, "read"(a_2, i)), a_1 neqq a_2 }$.

  First, flatten the literals:
  $
    & { "write"(a_1, i, "read"(a_1, i)) eqq "write"(a_2, i, "read"(a_2, i)) } to \
    & to {a'_1 eqq a'_2, a'_1 eqq "write"(a_1, i, "read"(a_2, i)), a'_2 eqq "write"(a_2, i, "read"(a_1, i)), a_1 neqq a_2} to \
    & to {a'_1 eqq a'_2, a'_1 eqq "write"(a_1, i, v_2), v_2 eqq "read"(a_2, i), a'_2 eqq "write"(a_2, i, v_1), v_1 eqq "read"(a_1, i), a_1 neqq a_2}
  $
]

#pagebreak()

+ $a'_1 eqq a'_2, a'_1 eqq "write"(a_1, i, v_2), v_2 eqq "read"(a_2, i), a'_2 eqq "write"(a_2, i, v_1), v_1 eqq "read"(a_1, i), a_1 neqq a_2$
+ (by #smallcaps[Refl]) $a_1 eqq a_1$
+ (by #smallcaps[Refl]) $a_2 eqq a_2$
+ (by #smallcaps[Ext]) $u_1 neqq u_2, u_1 eqq "read"(a_1, n), u_2 eqq "read"(a_2 , n)$
+ (by #smallcaps[RIntro2]) split
#grid(
  columns: 2,
  column-gutter: 2em,
  stroke: (top: 0.4pt),
  inset: (top: 5pt),
  [
    6. $i eqq n$
    + (by #smallcaps[Cong]) $v_1 eqq u_1$
    + (by #smallcaps[Symm]) $u_1 eqq v_1$
    + (by #smallcaps[Cong]) $v_2 eqq u_2$
    + (by #smallcaps[RIntro1]) $v_2 eqq "read"(a'_1, i)$
    + (by #smallcaps[RIntro1]) $v_1 eqq "read"(a'_2, i)$
    + (by #smallcaps[Refl]) $i eqq i$
    + (by #smallcaps[Cong]) $v_1 eqq v_2$
    + (by #smallcaps[Trans]) $u_1 eqq u_2$
    + (by #smallcaps[Contr]) $"UNSAT"$
  ],
  [
    6. $i neqq n, u_1 eqq "read"(a'_1, n)$
    + (by #smallcaps[RIntro2]) split
    #grid(
      columns: 2,
      column-gutter: 2em,
      stroke: (top: 0.4pt),
      inset: (top: 5pt),
      [
        8. $i eqq n$
        + (by #smallcaps[Contr]) $"UNSAT"$
      ],
      [
        8. $i neqq n, u_2 eqq "read"(a'_2, n)$
        + (by #smallcaps[Refl]) $n eqq n$
        + (by #smallcaps[Cong]) $u_1 eqq u_2$
        + (by #smallcaps[Contr]) $"UNSAT"$
      ],
    )
  ],
)

= Arithmetic

== Theory of Real Arithmetic

#definition[
  The theory of _real arithmetic_ $cal(T)_"RA"$ is defined by the signature #box[$Sigma^S_"RA" = {RealSort}$], #box[$Sigma^F_"RA" = {+, -, times, lt.eq} union {q | q "is a decimal numeral"}$] and the class of interpretations $bold(M)_"RA"$ that interpret $RealSort$ as the set of _real numbers_ $RR$, and the function symbols in the usual way.
]

_Quantifier-free linear real arithmetic_ (`QF_LRA`) is the theory of _linear inequalities_ over the reals, where $times$ can only be used in the form of _multiplication by constants (decimal numerals)_.

== Linear Programming

#definition[
  A _linear program_ (LP) consists of:
  + An $m times n$ matrix $bold(A)$, the _contraint matrix_.
  + An $m$-dimensional vector $bold(b)$.
  + An $n$-dimensional vector $bold(c)$, the _objective function_.

  Let $bold(x)$ be a vector of $n$ variables.

  *Goal:* Find a solution $bold(x)$ that _maximizes_ $bold(c)^T bold(x)$ subject to the linear constraints $bold(A) bold(x) lt.eq bold(b)$ (and #footnote[The constraint $bold(x) gt.eq bold(0)$ is introduced when LP is expressed in _standard form_, explained later in these slides.] $bold(x) gt.eq bold(0)$).
]

#note[
  All *bold*-styled symbols denote _vectors_ or _matrices_, e.g., $bold(x)$, $bold(A)$, $bold(0)$.
]

== Example and Terminology

#example[
  Maximize $2 x_2 - x_1$ subject to:
  $
    x_1 + x_2 &lt.eq 3 \
    2 x_1 - x_2 &lt.eq -5 \
  $

  #set math.vec(delim: "[")
  #set math.mat(delim: "[")

  Here, $bold(x) = vec(x_1, x_2)$, $bold(A) = mat(1, 1; 2, -1)$, $bold(b) = vec(3, -5)$, $bold(c) = vec(-1, 2)$.

  Find $bold(x)$ that maximizes $bold(c)^T bold(x)$ subject to $bold(A) bold(x) lt.eq bold(b)$.
]

#definition[
  An assignment of $bold(x)$ is a _feasible solution_ if it satisfies $bold(A) bold(x) lt.eq bold(b)$.
  // Otherwise, it is an _infeasible solution_.
]

- Is $bold(x) = chevron.l 0, 0 chevron.r$ a feasible solution? #NO
- Is $bold(x) = chevron.l -2, 1 chevron.r$ a feasible solution? #YES

#definition[
  For a given assignment $bold(x)$, the value $bold(c)^T bold(x)$ is the _objective value_, or _cost_, of $bold(x)$.
]

- What is the objective value of $bold(x) = chevron.l -2, 1 chevron.r$? // 4

#definition[
  An _optimal solution_ is a feasible solution with a _maximal_ objective value among all feasible solutions.
]

#definition[
  If a linear program has no feasible solutions, it is _infeasible_.
]

#definition[
  The linear program is _unbounded_ if the objective value of the optimal solution is $infinity$.
]

== Geometric Interpretation

#place(bottom + right, dy: -1em)[
  #image("assets/Dodecahedron.png", width: 3cm)
]

#definition[
  A _polytope_ is a generalization of 3-dimensional polyhedra to higher dimensions.
]

#definition[
  A polytope $P$ is _convex_ if every point on the line segment connecting any two points in $P$ is also within $P$.

  Formally, for all $a, b in RR^n intersect P$, and for all $lambda in [0; 1]$, it holds that $lambda a + (1-lambda) b in P$.
]

#note[
  For an $m times n$ constraint matrix $bold(A)$, the set of points $P = {bold(x) | bold(A) bold(x) lt.eq bold(b)}$ forms a _convex polytope_ in $n$-dimensional space.
]

*LP goal:* find a point $bold(x)$ _inside the polytope_ that maximizes $bold(c)^T bold(x)$ for a given $bold(c)$.

#note[
  LP is _infeasible_ iff the polytope is _empty_.
]

#note[
  LP is _unbounded_ iff the polytope is _open_ in the direction of the objective function.
]

#note[
  The _optimal solution_ for a bounded LP lies on a _vertex_ of the polytope.
]

== Satisfiability as Linear Programming

Our goal is to use LP to check the satisfiability of _sets of linear $cal(T)_"RA"$-literals_.

*Step 1:* Convert equalities to inequalities.

- A linear $cal(T)_"RA"$-equality can be written to have the form $bold(a)^T bold(x) = bold(b)$.
- We rewrite this further as $bold(a)^T bold(x) gt.eq bold(b)$ and $bold(a)^T bold(x) lt.eq bold(b)$.
- And finally to $-bold(a)^T bold(x) lt.eq -bold(b)$ and $bold(a)^T bold(x) lt.eq bold(b)$.

*Step 2:* Handle inequalities.

- A $cal(T)_"RA"$-literal of the form $bold(a)^T bold(x) lt.eq bold(b)$ is already in the desired form.
- A $cal(T)_"RA"$-literal of the form $not (bold(a)^T bold(x) lt.eq bold(b))$ is transformed as follows:
  $
    not (bold(a)^T bold(x) lt.eq bold(b)) to (bold(a)^T bold(x) > bold(b)) to (-bold(a)^T bold(x) < -bold(b)) to (-bold(a)^T bold(x) + y lt.eq -bold(b)), (y > 0)
  $
  where $y$ is a fresh variable used for all negated inequalities.
  #example[
    $not (2 x_1 - x_2 lt.eq 3)$ rewrites to $-2 x_1 + x_2 + y lt.eq -3, thick y > 0$
  ]
- If there are no negated inequalities, add the inequality $y lt.eq 1$, where $y$ is a fresh variable.
- In either case, we end up with a set of the form $bold(a)^T bold(x) lt.eq bold(b) union {y > 0}$

*Step 3:* Check the satisfiability of $bold(a)^T bold(x) lt.eq bold(b) union {y > 0}$.

Encode it as LP: maximize $y$ subject to $bold(a)^T bold(x) lt.eq bold(b)$.

The final system is _satisfiable_ iff the _optimal value_ for $y$ is _positive_.

== LP Solving Methods and Standard Form

- _Simplex_ (Dantzig, 1947) --- exponential time $cal(O)(2^n)$, but very efficient in practice
- _Ellipsoid_ (Khachiyan, 1979) --- polynomial time $cal(O)(n^6)$
- _Projective_ (Karmarkar, 1984) --- polynomial time $cal(O)(n^3.5)$

Any LP can be transformed to _standard form_:
$
  "maximize" & sum_(j=1)^n c_j x_j \
  "such that" & sum_(j=1)^m a_(i j) x_j lt.eq b_i "for" i = 1, dots, m \
  & x_j gt.eq 0 "for" j = 1, dots, n
$

#example[
  Next, we are going to use the following running example LP:
  $
    "maximize" & 5 x_1 + 4 x_2 + 3 x_3 \
    "such that" & cases(
      2 x_1 + 3 x_2 + x_3 lt.eq 5,
      4 x_1 + x_2 + 2 x_3 lt.eq 11,
      3 x_1 + 4 x_2 + 2 x_3 lt.eq 8,
      x_1\, x_2\, x_3 gt.eq 0,
    )
  $
]

== Slack Variables

- Observe the first inequality:
  $2 x_1 + 3 x_2 + x_3 lt.eq 5$
- Define a _new variable_ to represent the _slack_:
  $
    x_4 = 5 - 2 x_1 - 3 x_2 - x_3, quad x_4 gt.eq 0
  $
- Do this for each constraint, so that everything becomes _equalities_.
- Define a new variable to represent the _objective value_:
  $z = 5 x_1 + 4 x_2 + 3 x_3$

#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    // debug: true,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    node-outset: 3pt,
    blob((0, 0))[
      $
        max & 5 x_1 + 4 x_2 + 3 x_3 \
        "s.t." & cases(
          2 x_1 + 3 x_2 + x_3 lt.eq 5,
          4 x_1 + x_2 + 2 x_3 lt.eq 11,
          3 x_1 + 4 x_2 + 2 x_3 lt.eq 8,
          x_1\, x_2\, x_3 gt.eq 0,
        )
      $
    ],
    edge("-|>"),
    blob((1, 0))[
      $
        max & z \
        "s.t." & cases(
          x_4 = 5 - 2 x_1 - 3 x_2 - x_3,
          x_5 = 11 - 4 x_1 - x_2 - 2 x_3,
          x_6 = 8 - 3 x_1 - 4 x_2 - 2 x_3,
          z = 5 x_1 + 4 x_2 + 3 x_3,
          x_1\, x_2\, x_3\, x_4\, x_5\, x_6 gt.eq 0,
        )
      $
    ],
  )
]

#note[
  Optimal solution remains optimal for the new problem.
]

== The Simplex Strategy

- Start with a feasible solution.
  - For our example, assign 0 to all variables. \
    $x_1 maps 0, x_2 maps 0, x_3 maps 0$
  - Assign the introduced variables their computed values. \
    $x_4 maps 5, x_5 maps 11, x_6 maps 8, z maps 0$
- Iteratively improve the objective value.
  - Go from $bold(x)$ to $bold(x)'$ only if $z(bold(x)) lt.eq z(bold(x)')$.

#place(right)[
  $
    cases(
      x_4 = 5 - 2 x_1 - 3 x_2 - x_3,
      x_5 = 11 - 4 x_1 - x_2 - 2 x_3,
      x_6 = 8 - 3 x_1 - 4 x_2 - 2 x_3,
      z = 5 x_1 + 4 x_2 + 3 x_3,
    )
  $
]

What can we improve here?

One option is to make $x_1$ larger, leaving $x_2$ and $x_3$ unchanged:
- $x_1 = 1 quad to quad x_4 = 3, x_5 = 7, x_6 = 1, z = 5$ #YES
- $x_1 = 2 quad to quad x_4 = 1, x_5 = 3, x_6 = 2, z = 10$ #YES
- $x_1 = 3 quad to quad x_4 = -1, dots$ #NO _no longer feasible!_

#pagebreak()

We can't increase $x_1$ _too much_.
Let's increase it as much as possible, _without compromising feasibility_.

#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    // debug: true,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    node-outset: 3pt,
    blob((0, 0))[
      $
        x_1 maps 0, x_2 maps 0, x_3 maps 0 \
        cases(
          x_4 = 5 - 2 x_1 - 3 x_2 - x_3,
          x_5 = 11 - 4 x_1 - x_2 - 2 x_3,
          x_6 = 8 - 3 x_1 - 4 x_2 - 2 x_3,
          z = 5 x_1 + 4 x_2 + 3 x_3,
        )
      $
    ],
    edge("-|>"),
    blob((1, 0))[
      $
        cases(
          x_1 lt.eq 5/2,
          x_1 lt.eq 11/4,
          x_1 lt.eq 8/3,
        )
      $
    ],
  )
]

Select the _tightest bound_, $x_1 lt.eq 5/2$.
- New assignment: $x_1 maps 5/2, x_2 maps x_3 maps x_4 maps 0, x_5 maps 1, x_6 maps 1/2, z maps 25/2$.

Now _pivot_: since $x_1$ became positive and $x_4$ became 0, swap them by isolating $x_1$ from the equation for $x_4$, then eliminating $x_1$ from all other equations:

#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    node-outset: 3pt,
    blob((0, 0))[
      $
        cases(
          x_4 = 5 - 2 x_1 - 3 x_2 - x_3,
          x_5 = 11 - 4 x_1 - x_2 - 2 x_3,
          x_6 = 8 - 3 x_1 - 4 x_2 - 2 x_3,
          z = 5 x_1 + 4 x_2 + 3 x_3,
        )
      $
    ],
    edge("-|>"),
    blob((1, 0))[
      $
        cases(
          x_1 = 5/2 - 3/2 x_2 - 1/2 x_3 - 1/2 x_4,
          x_5 = 1 + 5 x_2 + #hide[$+ 0 x_3$] + 2 x_4,
          x_6 = 1/2 + 1/2 x_2 - 1/2 x_3 + 3/2 x_4,
          z = 25/2 - 7/2 x_2 + 1/2 x_3 - 5/2 x_4,
        )
      $
    ],
  )
]

#pagebreak()

#place(right)[
  $
    & x_1 maps 5 / 2, x_2 maps 0, x_3 maps 0, x_4 maps 0 \
    & cases(
      x_1 = 5/2 - 3/2 x_2 - 1/2 x_3 - 1/2 x_4,
      x_5 = 1 + 5 x_2 + #hide[$+ 0 x_3$] + 2 x_4,
      x_6 = 1/2 + 1/2 x_2 - 1/2 x_3 + 3/2 x_4,
      z = 25/2 - 7/2 x_2 + 1/2 x_3 - 5/2 x_4,
    )
  $
]

How can we improve $z$ further?
- *Option 1*: decrease $x_2$ or $x_4$, but we can't since $x_2, x_4 gt.eq 0$.
- *Option 2*: increase $x_3$. _By how much?_

$x_3$'s bounds: $x_3 lt.eq 5$, $x_3 lt.eq infinity$, $x_3 lt.eq 1$.

We increase $x_3$ to its tightest bound 1.
- New assignment: $x_1 maps 2, x_2 maps 0, x_3 maps 1, x_4 maps 0, x_5 maps 0, x_6 maps 0$.
- This gives $z = 13$, which is again an improvement.

As before, we switch $x_6$ and $x_3$, and _eliminate_ $x_3$ from the right-hand-side:

#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    node-outset: 3pt,
    blob((0, 0))[
      $
        cases(
          x_1 = 5/2 - 3/2 x_2 - 1/2 x_3 - 1/2 x_4,
          x_5 = 1 + 5 x_2 + #hide[$+ 0 x_3$] + 2 x_4,
          x_6 = 1/2 + 1/2 x_2 - 1/2 x_3 + 3/2 x_4,
          z = 25/2 - 7/2 x_2 + 1/2 x_3 - 5/2 x_4,
        )
      $
    ],
    edge("-|>"),
    blob((1, 0))[
      $
        cases(
          x_1 = 2 - 2 x_2 - 2 x_4 + x_6,
          x_5 = 1 + 5 x_2 + 2 x_4,
          x_3 = 1 + x_2 + 3 x_4 - 2 x_6,
          z = 13 - 3 x_2 - x_4 - x_6,
        )
      $
    ],
  )
]

#pagebreak()

#place(right)[
  $
    & x_1 maps 2, x_2 maps 0, x_3 maps 1, \
    & x_4 maps 0, x_6 maps 0 \
    & cases(
      x_1 = 2 - 2 x_2 - 2 x_4 + x_6,
      x_5 = 1 + 5 x_2 + 2 x_4,
      x_3 = 1 + x_2 + 3 x_4 - 2 x_6,
      z = 13 - 3 x_2 - x_4 - x_6,
    )
  $
]

Can we improve $z$ again?
- No, because $x_2, x_4, x_6 gt.eq 0$, and \ all _appear with negative signs_ in the objective function.

So, we are done, and the optimal value of $z$ is 13.

#Block(color: yellow)[
  *Optimal solution:* $x_1 maps 2, x_2 maps 0, x_3 maps 1$, with $z = 13$.
]

== The Simplex Algorithm

+ Introduce _slack variables_ $x_(n+1), dots, x_(n+m)$ for each constraint.
+ Start with initial _feasible_ solution (commonly, $x_j maps 0$ for all original variables).
+ While some coefficients in the objective function are _positive_:
  - Pick a variable $x_j$ with positive coefficient (_entering variable_).
  - Compute the tightest bound: $min_i (b_i / a_(i j))$ for $a_(i j) > 0$ (_leaving variable_).
  - _Pivot_: swap entering/leaving variables in the equation system.
+ When all coefficients are non-positive, the current solution is _optimal_. Stop.
+ Go to 4.


= CDCL($cal(T)$)

== CDCL($cal(T)$) Architecture

#Block(color: yellow)[
  $
    "CDCL"(cal(T)) = "CDCL"(X) + #[$cal(T)$-solver]
  $
]

CDCL($X$):
- Very _similar to a SAT solver_, enumerates Boolean models.
- Not allowed: pure literal rule (and other SAT specific heuristics).
- Required: incremental addition of clauses.
- Desirable: partial model detection.

$cal(T)$-solver:
- Checks the $cal(T)$-satisfiability of conjunctions of literals.
- Computes _theory propagations_.
- Produces _explanations_ of $cal(T)$-unsatisfiability/propagation.
- Must be _incremental_ and _backtrackable_.

== Typical SMT Solver Architecture

#[
  #import fletcher: diagram, node, edge
  #import fletcher.shapes: *
  #diagram(
    // debug: true,
    edge-stroke: 1pt,
    node-corner-radius: 3pt,
    node-outset: 3pt,
    blob((0cm, 0cm), [*SAT Solver* \ DPLL], name: <sat>, tint: green),
    blob((5cm, 0cm), [*Core*], name: <core>, tint: orange, shape: circle),
    blob((8.5cm, 1cm), [*UF*], name: <uf>, tint: blue),
    blob((8.5cm, 0cm), [*Arithmetic*], name: <arith>, tint: blue),
    blob((8.5cm, -1cm), [*Arrays*], name: <array>, tint: blue),
    blob((8.5cm, -2cm), [*Bit-Vectors*], name: <bv>, tint: blue),
    edge(<sat>, <core>, "-|>", stroke: green.darken(20%), shift: 5pt)[
      assertions
    ],
    edge(<core>, <sat>, "-|>", stroke: orange.darken(20%), shift: 5pt, label-side: left)[
      explanations, \
      conflicts, lemmas, \
      propagations
    ],
    edge(<core>, <uf.west>, "<{-}>", bend: 20deg),
    edge(<core>, <arith.west>, "<{-}>", bend: 5deg),
    edge(<core>, <array.west>, "<{-}>", bend: -10deg),
    edge(<core>, <bv.west>, "<{-}>", bend: -25deg),
    node((2.5cm, 2.5cm), name: <sat-text>, shape: rect, stroke: green.darken(20%))[
      #set align(left)
      *SAT Solver*:
      - Only sees _Boolean skeleton_ of a problem.
      - Builds _partial model_ by assigning truth values to literals
      - Sends these literals to the core as _assertions_
    ],
    node((2.5cm, -3.5cm), name: <core-text>, shape: rect, stroke: orange.darken(20%))[
      #set align(left)
      *Core*:
      - Sends each assertion to the appropriate theory
      - Sends deduced literals to other theories/SAT solver
      - Handles _theory combination_
    ],
    node((12.5cm, -0.5cm), name: <th2-text>, shape: rect, stroke: blue.darken(20%))[
      #set align(left)
      *Theory Solvers*:
      - Check $cal(T)$-satisfiability \ of sets of theory literals
      - Incremental
      - Backtrackable
      - Conflict generation
      - Theory propagation
    ],
  )
]

== Theory Propagation

The $cal(T)$-solver does more than just check consistency --- it actively _propagates_ information back to the SAT solver:

- *Conflict detection:* If the current set of theory literals is $cal(T)$-unsatisfiable, report a _conflict clause_ (a subset of literals explaining the inconsistency).
- *Theory propagation:* If a literal $ell$ is $cal(T)$-entailed by the current assertions, _propagate_ $ell$ to the SAT solver (avoiding unnecessary case splits).
- *Lemma learning:* The $cal(T)$-solver may derive useful _theory lemmas_ (clauses that are $cal(T)$-valid) and add them to the clause database.

#example[
  If the $cal(T)_"RA"$-solver sees $x lt.eq 3$ and $x gt.eq 5$, it immediately reports a conflict without waiting for the SAT solver to discover the contradiction.
]

#Block(color: blue)[
  *Why incremental and backtrackable?* The SAT solver frequently backtracks, so the $cal(T)$-solver must efficiently _undo_ assertions. Typical implementations use a _stack-based_ approach: push assertions on decisions, pop on backtrack.
]

== CDCL($cal(T)$) Example

Consider the formula $phi = (x eqq y or y eqq z) and (f(x) neqq f(y) or y eqq z) and (x eqq y or f(y) neqq f(z))$ in $cal(T)_"EUF"$.

*Step 1:* Boolean abstraction. Replace each theory atom with a Boolean variable:
- $p_1 := (x eqq y)$, $p_2 := (y eqq z)$, $p_3 := (f(x) eqq f(y))$, $p_4 := (f(y) eqq f(z))$
- Boolean skeleton: $(p_1 or p_2) and (not p_3 or p_2) and (p_1 or not p_4)$

*Step 2:* CDCL decides $p_1 = "true"$, $p_2 = "false"$.
- SAT solver propagates: $not p_3$ (from clause 2) and $not p_4$ (from clause 3, since $p_2 = "false"$).

*Step 3:* $cal(T)$-solver checks: ${x eqq y, not (y eqq z), not (f(x) eqq f(y)), not (f(y) eqq f(z))}$.
- From $x eqq y$, by congruence: $f(x) eqq f(y)$. But we have $not (f(x) eqq f(y))$ --- *conflict!*
- Conflict clause: $not (x eqq y) or f(x) eqq f(y)$, i.e. $not p_1 or p_3$.

*Step 4:* CDCL learns the clause $not p_1 or p_3$, backtracks, and eventually finds SAT with $p_2 = "true"$.

= Combining Theories

== Motivation: Mixed Formulas

In practice, formulas often involve _multiple_ theories simultaneously.

#example[
  $ f(x) - f(y) gt.eq 1 and (x eqq y) $
  This mixes $cal(T)_"EUF"$ (uninterpreted $f$, equality $eqq$) and $cal(T)_"RA"$ (arithmetic $-$, $gt.eq$, $1$).
]

#example[
  $ "read"("write"(a, i, v), j) + 1 lt.eq x and i eqq j $
  This mixes $cal(T)_"AX"$ (arrays) and $cal(T)_"RA"$ (arithmetic).
]

A single-theory solver cannot handle such formulas. We need a _combination method_ that orchestrates multiple theory solvers.

== The Nelson-Oppen Method

The _Nelson-Oppen_ (N-O) method combines decision procedures for _signature-disjoint_, _stably infinite_ theories.

#definition[
  Two theories $cal(T)_1$ and $cal(T)_2$ are _signature-disjoint_ if $Sigma^F_1 inter Sigma^F_2 = {eqq}$ --- the only shared symbol is equality.
]

#definition[
  A theory $cal(T)$ is _stably infinite_ if every $cal(T)$-satisfiable quantifier-free formula is satisfiable in a model with an _infinite_ domain.
]

#note[
  Most commonly used SMT theories ($cal(T)_"EUF"$, $cal(T)_"RA"$, $cal(T)_"IA"$, $cal(T)_"AX"$) are stably infinite and pairwise signature-disjoint (when restricted to their respective sorts).
]

== Nelson-Oppen: Purification

*Step 1: Purification.* Separate a mixed formula into _pure_ conjuncts, one per theory.

_Method:_ For any term $t$ from theory $cal(T)_i$ that appears as an argument in a literal of theory $cal(T)_j$ (with $i neq j$), introduce a _fresh shared variable_ $v$, add $v eqq t$ to $cal(T)_i$'s literals, and replace $t$ by $v$ in $cal(T)_j$'s literals.

#example[
  Purify $f(x) - f(y) gt.eq 1 and x eqq y$:

  Introduce $v_1 eqq f(x)$ and $v_2 eqq f(y)$:
  - $cal(T)_"EUF"$: ${ v_1 eqq f(x), thin v_2 eqq f(y), thin x eqq y }$
  - $cal(T)_"RA"$: ${ v_1 - v_2 gt.eq 1 }$
  - _Shared variables_: $v_1, v_2$ (appear in both "pure" sets)
]

== Nelson-Oppen: Equality Propagation

*Step 2: Equality propagation.* The two solvers exchange _equalities and disequalities_ between shared variables until a _fixed point_ or a _conflict_ is reached.

+ Check each pure set with its own $cal(T)$-solver.
+ If either solver reports UNSAT $=>$ the combined formula is UNSAT.
+ If the $cal(T)_i$-solver deduces a new equality $v eqq w$ between shared variables, _propagate_ it to the other solver.
+ Repeat until no new equalities are deduced (_fixed point_).
+ If both solvers report SAT at the fixed point $=>$ the combined formula is SAT.

#Block(color: yellow)[
  *Key insight:* For _convex_ theories (including $cal(T)_"EUF"$ and $cal(T)_"RA"$), the method only needs to propagate _equalities_ --- no disjunctions. This makes the procedure _deterministic_ and efficient.
]

#definition[
  A theory $cal(T)$ is _convex_ if whenever $cal(T) models (ell_1 and dots and ell_n) imply (x_1 eqq y_1 or dots or x_k eqq y_k)$, then $cal(T) models (ell_1 and dots and ell_n) imply (x_i eqq y_i)$ for some $i$.
]

== Nelson-Oppen: Worked Example

*Formula:* $f(x) - f(y) gt.eq 1 and x eqq y$

After purification with shared variables $v_1, v_2$:
- $cal(T)_"EUF"$: ${ v_1 eqq f(x), thin v_2 eqq f(y), thin x eqq y }$
- $cal(T)_"RA"$: ${ v_1 - v_2 gt.eq 1 }$

*Round 1:*
- $cal(T)_"EUF"$-solver: From $x eqq y$ and congruence, deduces $f(x) eqq f(y)$, hence $v_1 eqq v_2$.
- _Propagate_ $v_1 eqq v_2$ to $cal(T)_"RA"$.

*Round 2:*
- $cal(T)_"RA"$-solver: Now has ${ v_1 - v_2 gt.eq 1, thin v_1 eqq v_2 }$.
  - $v_1 eqq v_2$ implies $v_1 - v_2 = 0$, contradicting $v_1 - v_2 gt.eq 1$.
  - *UNSAT!*

*Conclusion:* The original mixed formula is unsatisfiable.

= SMT-LIB and Z3

== SMT-LIB: The Standard Language

_SMT-LIB_ (v2) is a standardized _input language_ for SMT solvers. It defines:

- A set of _logics_ (e.g. `QF_UF`, `QF_LIA`, `QF_LRA`, `QF_AUFLIA`, `QF_BV`, `ALL`) specifying which theories and quantifiers are allowed.
- A _command language_ for interacting with solvers.
- Standard _theory declarations_ shared across all solvers.

Core commands:
#align(center)[
  #table(
    columns: 2,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[Command][Description],
    [`(set-logic QF_LIA)`], [Declare the logic],
    [`(declare-sort S 0)`], [Declare an uninterpreted sort with arity 0],
    [`(declare-fun f (Int Int) Bool)`], [Declare a function symbol with rank],
    [`(define-fun g ((x Int)) Int ...)`], [Define a function (macro)],
    [`(assert (< x 5))`], [Assert a formula],
    [`(check-sat)`], [Check satisfiability],
    [`(get-model)`], [Retrieve a satisfying assignment (if SAT)],
    [`(push 1)` / `(pop 1)`], [Save/restore assertion stack],
    [`(exit)`], [Terminate the session],
  )
]

== SMT-LIB: QF_UF Example

Encoding the EUF problem: $a eqq b and f(a) eqq b and not (g(a) eqq g(f(a)))$.

```lisp
(set-logic QF_UF)
(declare-sort U 0)

(declare-fun a () U)
(declare-fun b () U)
(declare-fun f (U) U)
(declare-fun g (U) U)

(assert (= a b))
(assert (= (f a) b))
(assert (not (= (g a) (g (f a)))))

(check-sat)   ; Expected: unsat
(exit)
```

#note[
  In SMT-LIB, `=` is the built-in equality. There is no need to declare it. Variables are _declared_ as zero-arity functions: `(declare-fun a () U)` means "$a$ is a _constant_ of sort $U$".
]

== SMT-LIB: QF_LIA Example

Is there an integer solution to $x + 2 y gt.eq 5$, $x - y lt.eq 1$, $x gt.eq 0$, $y gt.eq 0$?

```lisp
(set-logic QF_LIA)

(declare-fun x () Int)
(declare-fun y () Int)

(assert (>= (+ x (* 2 y)) 5))
(assert (<= (- x y) 1))
(assert (>= x 0))
(assert (>= y 0))

(check-sat)   ; Expected: sat
(get-model)   ; e.g., x = 1, y = 2
(exit)
```

#Block(color: blue)[
  *Logic naming convention:* `QF_` = quantifier-free. `L` = linear, `N` = non-linear. `I` = integers, `R` = reals. `A` = arrays. `UF` = uninterpreted functions. `BV` = bit-vectors. So `QF_AUFLIA` = quantifier-free arrays + UF + linear integer arithmetic.
]

== Z3: An SMT Solver

*Z3* (Microsoft Research) is one of the most widely used SMT solvers.

- Supports _all major theories_: EUF, LIA, LRA, arrays, bit-vectors, strings, datatypes, ...
- Accepts _SMT-LIB_ input and also has _Python_, _C/C++_, and _Java_ APIs.
- Used in: Dafny, Boogie, KLEE, Rosette, angr, many other FM tools.

#example[
  Run the QF_LIA example with Z3 from the command line:
  ```bash
  z3 example.smt2
  ```
  Output:
  ```
  sat
  (model
    (define-fun x () Int 1)
    (define-fun y () Int 2))
  ```
]

== Z3 Python API: z3py

The _z3py_ library provides a Pythonic interface to Z3:

```python
from z3 import *

x, y = Ints('x y')
s = Solver()
s.add(x + 2*y >= 5)
s.add(x - y <= 1)
s.add(x >= 0, y >= 0)

if s.check() == sat:
    m = s.model()
    print(f"x = {m[x]}, y = {m[y]}")
```

Common z3py types and constructors:
- `Bool('b')`, `Int('x')`, `Real('r')` --- declare sorted variables
- `Function('f', IntSort(), IntSort())` --- uninterpreted function $f : IntSort -> IntSort$
- `Array('a', IntSort(), IntSort())` --- array variable
- `Solver()`, `.add(...)`, `.check()`, `.model()` --- solver interaction
- `And(...)`, `Or(...)`, `Not(...)`, `Implies(a, b)` --- logical connectives

== Z3 Practical Examples

*Array swap verification:*
```python
from z3 import *
a = Array('a', IntSort(), IntSort())
i, j = Ints('i j')
# swap a[i] and a[j]
b = Store(Store(a, i, Select(a, j)), j, Select(a, i))
# verify that b[i] == a[j] and b[j] == a[i]
s = Solver()
s.add(Not(And(Select(b, i) == Select(a, j),
              Select(b, j) == Select(a, i))))
print(s.check())  # unsat => swap is correct
```

*Simple scheduling:*
```python
from z3 import *
A, B, C = Ints('A B C')  # start times
s = Solver()
s.add(A >= 0, B >= 0, C >= 0)   # non-negative start
s.add(A + 3 <= B)               # A finishes before B starts
s.add(B + 2 <= C)               # B finishes before C starts
s.add(C + 1 <= 8)               # C finishes by deadline 8
if s.check() == sat:
    print(s.model())  # e.g., A=0, B=3, C=5
```

= Exercises

== Exercise: Theory Satisfiability

Determine whether the following sets of literals are $cal(T)$-satisfiable or $cal(T)$-unsatisfiable. If satisfiable, provide a $cal(T)$-interpretation. If unsatisfiable, show why.

+ In $cal(T)_"EUF"$: ${ a eqq b, thick b eqq c, thick f(a) neqq f(c) }$
+ In $cal(T)_"RA"$: ${ x + y lt.eq 3, thick 2 x - y gt.eq 5, thick x lt.eq 1 }$
+ In DL: ${ x - y lt.eq 2, thick y - z lt.eq 3, thick z - x lt.eq -6 }$

== Exercise: Nelson-Oppen and SMT-LIB

+ Purify the following formula into $cal(T)_"EUF"$ and $cal(T)_"RA"$ components:
  $ f(x + 1) eqq f(y) and x - y gt.eq 0 and x lt.eq y $
  Run the Nelson-Oppen equality propagation. Is the formula satisfiable?

+ Encode the following problem in SMT-LIB (`QF_LIA`): "Find integers $x, y, z$ such that $x + y + z = 15$, $x gt.eq 1$, $y gt.eq 1$, $z gt.eq 1$, and $x lt.eq y lt.eq z$."

+ Write a z3py script to verify that for all integers $x$: if $x > 0$, then $x + x > x$. _(Hint: show the negation is UNSAT.)_
