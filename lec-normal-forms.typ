#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Normal Forms",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

#let rewrite = $arrow.double.long$

= Normal Forms

== Normal Forms in Propositional Logic

#definition[Normal form][
  A _normal form_ is a standardized syntactic representation of logical formulas with a _restricted_ structure.

  Normal forms enable efficient reasoning, simplification, and decision procedures, making them essential in automated theorem proving, model checking, and logic synthesis.
]

There are several _normal forms_ commonly used in propositional logic:
- Negation normal form (NNF)
- Conjunctive normal form (CNF)
- Disjunctive normal form (DNF)
- Algebraic normal form (ANF)
- Binary decision diagram (BDD)

Each normal form has its own advantages and disadvantages, and is used in different contexts.

Every propositional formula can be converted to an _equivalent_ formula in any of these normal forms.

== Negation Normal Form

#definition[Negation Normal Form (NNF)][
  A formula is in _negation normal form_ if the negation operator ($not$) is only applied to variables, and the only allowed logical connectives are $and$ and $or$.
]

#example[
  The formula $(p and q) or (not p and not q)$ is in NNF.
]
#example[
  The formula $not (p and q) or (not p and not q)$ is _not_ in NNF due to $not (dots)$.
]

*Grammar* for NNF formulas:
$
  angle.l "Atom" angle.r &::= top | bot | angle.l "Variable" angle.r \
  angle.l "Literal" angle.r &::= angle.l "Atom" angle.r | not angle.l "Atom" angle.r \
  angle.l "Formula" angle.r &::= angle.l "Literal" angle.r | angle.l "Formula" angle.r and angle.l "Formula" angle.r | angle.l "Formula" angle.r or angle.l "Formula" angle.r \
$

== Literals

#definition[Literal][
  A _literal_ is a propositional variable or its negation.
  - $p$ is a _positive literal_.
  - $not p$ is a _negative literal_.
]

#definition[Complement][
  The _complement_ of a literal $p$ is denoted by $overline(p)$.
  $
    overline(p) = cases(
      not p "if" p "is positive",
      p "if" p "is negative"
    )
  $

  Note: _complementary_ literals $p$ and $overline(p)$ are each other's completement.
]

== NNF Transformation

Any propositional formula can be converted to NNF by the repeated application of the following rewriting rules ($rewrite$) to the formula and its sub-formulas, to completion (until none apply):
#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[*Description*][*Rewrite rule*],
  [Eliminate implications], [$(A implies B) rewrite (not A or B)$],
  [Eliminate bi-implications], [$(A iff B) rewrite (not A or B) and (A or not B)$],
  [Push negation inside conjunctions], [$not (A and B) rewrite (not A or not B)$],
  [Push negation inside disjunctions], [$not (A or B) rewrite not A and not B$],
  [Eliminate double negations], [$not not A rewrite A$],
)

// #theorem[
//   If $A'$ is obtained from a formula $A$ by applying the NNF conversion rules, then $A' equiv A$.
// ]

#theorem[
  Every well-formed formula not containing $iff$ can be converted to an _equivalent_ NNF with a _linear increase_ in the size#footnote[For example, number of variable occurences, or number of sub-formulas.] of the formula.
]

== Exponential Blowup of NNF

The NNF of formulas containing $iff$ can grow _exponentially_ in size.

#example[
  Let's convert the following formula to NNF...
  $
    F = & a iff (b iff (c iff d)) rewrite \
    = & a iff (b iff ((c imply d) and (d imply c))) rewrite \
    = & a iff ((b imply ((c imply d) and (d imply c))) and (((c imply d) and (d imply c)) imply b)) rewrite \
    = & a iff ((b or (dots)) and (not (dots) or b)) rewrite \
    = & (not a or (dots)) and (a or not (dots)) rewrite \
    = & (not a or ((b or (dots)) and (not (dots) or b))) and \
    & (a or not ((b or (dots)) and (not (dots) or b)))
  $

  The original $F$ contains only 4 variable occurences, while the NNF of $F$ contains 16 variable occurences.
]

== Disjunctive Normal Form

#definition[Disjunctive Normal Form (DNF)][
  A formula is said to be in _disjunctive normal form_ if it is a disjunction of _cubes_ (conjunctions of literals).
  $
    A = or.big_i and.big_j p_(i j)
  $
  #example[
    $A = (p and q) or (not p and q and r) or not q$
  ]
]

*Grammar* for DNF formulas:
$
  angle.l "Atom" angle.r &::= top | bot | angle.l "Variable" angle.r \
  angle.l "Literal" angle.r &::= angle.l "Atom" angle.r | not angle.l "Atom" angle.r \
  angle.l "Cube" angle.r &::= angle.l "Literal" angle.r | angle.l "Literal" angle.r and angle.l "Cube" angle.r \
  angle.l "Formula" angle.r &::= angle.l "Cube" angle.r | angle.l "Cube" angle.r or angle.l "Formula" angle.r \
$

== Cubes and Clauses

#definition[Cube][
  A _cube_ is a conjunction of literals.
]

#definition[Clause][
  A _clause_ is a disjunction of literals.
  - An _empty clause_ is a clause with no literals, commonly denoted by $square$.
  - A _unit clause_ is a clause with a single literal, that is, just a literal itself.
  - A _Horn clause_ is a clause with at most one positive literal.

  *Note:* $square$ is _false in every interpretation_, that is, unsatisfiable.
]

== Conjunctive Normal Form

#definition[Conjunctive Normal Form (CNF)][
  A formula is said to be in _conjunctive normal form_ if it is a conjunction of _clauses_.
  $
    A = and.big_i or.big_j p_(i j)
  $
  #example[
    $A = (not p or q) and (not p or q or r) and not q$
  ]
]

== Satisfiability on CNF

An interpretation $nu$ satisfies a clause $C = p_1 or dots or p_n$ if it satisfies some (at least one) literal $p_k$ in $C$.

An interpretation $nu$ satisfies a CNF formula $A = C_1 and dots and C_n$ if it satisfies every clause $C_i$ in $A$.

A CNF formula $A$ is _satisfiable_ if there exists an interpretation $nu$ that satisfies $A$.

The *SAT problem* is about determining whether a given CNF formula is satisfiable.

== CNF Transformation

Any propositional formula can be converted to CNF by the repeated application of these rewriting rules:
- Any NNF transformation rules.
- Distribute $or$ over $and$ (another source of exponential blowup):
  - $A or (B and C) rewrite (A or B) and (A or C)$
  - $(A and B) or C rewrite (A or C) and (B or C)$
- Normalize nested $and$ and $or$ operators:
  - $A and (B and C) rewrite (A and B and C)$
  - $A or (B or C) rewrite (A or B or C)$

// #theorem[
//   If $A'$ is obtained from a formula $A$ by applying the CNF conversion rules, then $A' equiv A$.
// ]

#theorem[
  Every well-formed formula $alpha$ can be converted to an _equivalent_ CNF $alpha'$ with a _potentially exponential increase_ in the size of the formula.
]

== Exponential Blowup of CNF

Distributive law is the main source of the exponential blowup in CNF conversion:
$
  n "cubes"
  { vec(delim: #none,
      (&x_1 and y_1) &or,
      (&x_2 and y_2) &or,
       &dots,
      (&x_n and y_n) &or,
    )
    quad
    arrow.double.long^"CNF"
    quad
    vec(delim: #none,
      (&x_1 or x_2 or dots or x_n) &and,
      (&y_1 or x_2 or dots or x_n) &and,
       &dots,
      (&x_1 or y_2 or dots or y_n) &and,
      (&y_1 or y_2 or dots or y_n)
    ) }
  2^n "clauses"
$

#v(2em)
*Is there a way to avoid the exponential blowup?* _Yes!_

== Tseitin Transformation

A space-efficient way to convert a formula to CNF is the _Tseitin transformation_, which is based on so-called "_naming_" or "_definition introduction_", allowing to replace subformulas with the "_fresh_" (new) variables.

+ Take a subformula $A$ of a formula $F$.
+ Introduce a new propositional variable $n$.
+ Add a _definition_ for $n$, that is, a formula stating that $n$ is equivalent to $A$.
+ Replace $A$ with $n$ in $F$.

Overall, construct $S := F[n slash A] and (n iff A)$

$
  F = & p_1 iff \(p_2 iff \(p_3 iff \(p_4 iff overshell((p_5 iff p_6), A))) arrow.double.long \
  S = & p_1 iff (p_2 iff (p_3 iff (p_4 iff n))) and \
  & n iff (p_5 iff p_6)
$

#note[
  The resulting formula is, in general, *not equivalent* to the original one, but it is _equisatisfiable_, i.e., it is satisfiable iff the original formula is satisfiable.
]

== Equisatisfiability

#definition[Equisatisfiability][
  Two formulas $A$ and $B$ are _equisatisfiable_ if $A$ is satisfiable _if and only~if_ $B$ is satisfiable.
]

The set $S$ of clauses obtained by the Tseitin transformation is _equisatisfiable_ with the original formula $F$.
- Every model of $S$ is a model of $F$.
- Every model of $F$ can be extended to a model of $S$ by assigning the values of fresh variables according to their definitions.

== Avoiding the Exponential Blowup

#example[
  $F = p_1 iff (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))$

  Applying the Tseitin transformation gives us:
  $
    S = & p_1 iff (p_2 iff n_3) &and \
    & n_3 iff (p_3 iff n_4) &and \
    & n_4 iff (p_4 iff n_5) &and \
    & n_5 iff (p_5 iff p_6)
  $

  The equivalent CNF of $F$ consists of $2^5 = 32$ clauses, and grows exponentially with number of variables.

  The equisatisfiable CNF of $F$ consists of $16$ clauses, yet introduces $3$ fresh variables, and grows linearly with the number of variables.
]

== Clausal Form

#definition[Clausal form][
  A _clausal form_ of a formula $F$ is a set $S_F$ of clauses which is satisfiable iff $F$ is satisfiable.

  A clausal form of a _set_ of formulas $S$ is a set $S'$ of clauses which is satisfiable iff $S$ is satisfiable.

  Even stronger requirement:
  - $F$ and $S_F$ have the same models in the language of $F$.
  - $S$ and $S'$ have the same models in the language of $S$.
]

The main advantage of the clausal form over the equivalent CNF is that we can convert any formula into a set of clauses in _almost linear time_.
+ If $F$ is a formula which has the form $C_1 and dots and C_n$, where $n > 0$ and each $C_i$ is a clause, then its clausal form is $S eq.def {C_1, dots, C_n}$.
+ Otherwise, apply Tseitin transformation: introduce a name for each subformula $A$ of $F$ such that $A$ is not a literal and use this name instead of a subformula $A$.

== TODO

#show: cheq.checklist
- [ ] Exercises
- [ ] Example: convert formula to clausal form
- [ ] DNF vs CNF satisfiability

// == Bibliography
// #bibliography("refs.yml")
