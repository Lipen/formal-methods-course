#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "DPLL",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

#import fletcher: diagram, node, edge

#let transition = $scripts(arrow.double.long)$

= Algorithms for SAT

== Davis--Putnam Algorithm

#[
  #let fig = grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    box(inset: (right: -0.6cm), clip: true, image("assets/Martin_Davis.jpg", height: 3cm)),
    image("assets/Hilary_Putnam.jpg", height: 3cm),

    [Martin Davis], [Hilary Putnam],
  )
  #let body = [
    The first algorithm for solving the SAT problem was proposed by Martin Davis and Hilary Putnam in 1960 @davis1960.

    Satisfiability-preserving transformations:
    - The 1-literal rule (*unit propagation*).
    - The affirmative-negative rule (*pure literal*).
    - The atomic formula elimination rule (*resolution*).
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

The first two rules reduce the total number of literals in the formula.
The third rule reduces the number of variables in the formula.
By repeatedly applying these rules, we can simplify the formula until it becomes _trivially_ satisfiable (formula without clauses) or unsatisfiable (formula containing an empty clause).

Hereinafter, we assume that the formulas are given in CNF form.

== Unit Propagation Rule

#definition([Unit clause])[
  A _unit clause_ is a clause with a single literal.
]

Suppose $(p)$ is a unit clause.
Recall that $overline(p)$ denotes the complement literal:
#h(1em, weak: true)
$overline(p) = cases(
  not p "if" p "is positive",
  p "if" p "is negative"
)$

Then, the unit propagation rule is defined as follows:
- Assign the value of $p$ to true.
- Remove all instances of $overline(p)$ from clauses in the formula (shortening the corresponding clauses).
- Remove all clauses containing $p$ (including the unit clause itself).

#example[
  #let r(x) = $cancel(#x, stroke: #red, cross: #true)$
  //
  Consider the formula $(A or B) and (A or not B) and (not A or B) and (not A or not B) and (A)$.
  The unit clause $(A)$ is present in the formula.
  Applying the unit propagation rule, we remove all clauses containing $A$ (positive literal), and remove $neg A$ (negative literal) from the remaining clauses: $#r($(A or B)$) and #r($(A or not B)$) and (#r($not A$) or B) and (#r($not A$) or B) and (#r($not A$) or not B) and #r($(A)$)$, which simplifies to $(B) and (not B)$.
]

== Pure Literal Rule

#definition([Pure literal])[
  A literal $p$ is _pure_ if it appears in the formula only positively or only negatively.
]

The pure literal rule is defined as follows:
- Assign the value of $p$ to true.
- Remove all clauses containing a pure literal.

#example[
  Consider the formula $(A or B) and (A or C) and (B or C)$.
  The literal $A$ is pure, as it appears only positively.
  Applying the pure literal rule, we assign $A = 1$ and remove all clauses containing $A$, which simplifies the formula to $(B or C)$.
]

== Resolution Rule

+ Select a propositional variable $p$ that appears both positively and negatively in the formula.
+ Partition the relevant clauses:
  - Let $P$ be the set of all clauses that contain $p$.
  - Let $N$ be the set of all clauses that contain $not p$.
+ Perform the resolution step:
  - For each pair of clauses $C_P in P$ and $C_N in N$, construct the _resolvent_ by removing $p$ and $not p$, then merging the remaining literals:
  $ C_P times.circle_p C_N = (C_P setminus {p}) union (C_N setminus {not p}) $
  #example[
    $(a or b or not c) times.circle_b (a or not b or d or not e) = (a or not c or d or not e)$
  ]
+ Update the formula:
  - Remove all clauses in $P$ and $N$.
  - Add the newly derived resolvents to the formula.

== Davis--Putnam--Logemann--Loveland (DPLL) Algorithm

The DPLL algorithm @davis1962 is a complete, backtracking search algorithm for deciding the satisfiability of propositional logic formulas in CNF, that is, for solving the CNF-SAT problem.

Introduced by Martin Davis, George Logemann, and Donald Loveland in 1961, the algorithm is a refinement of the Davis--Putnam algorithm.

In DPLL, the resolution rule is replaced with a _splitting_ rule.
+ Let $Delta$ be the current set of clauses.
+ Choose a propositional variable $p$ occuring in the formula.
+ Test the satisfiability of $Delta union {(p)}$:
  - If satisfiable, assign $p = 1$ and continue with the new formula.
  - If unsatisfiable, test the satisfiability of $Delta union {(not p)}$:
    - If satisfiable, assign $p = 0$ and continue with the new formula.
    - If unsatisfiable, backtrack.

The DPLL algorithm is a _complete_ algorithm: it will eventually find a satisfying assignment iff one exists.

== DPLL Pseudocode

#lovelace.pseudocode-list(
  // title: [$"DPLL"(S)$],
  hooks: 0.5em,
  line-gap: 0.7em,
)[
  - #smallcaps[*Input:*] set of clauses $S$
  - #smallcaps[*Output:*] _satisfiable_ or _unsatisfiable_
  + $S := "propagate"(S)$
  + *if* $S$ is empty *then*
    - *return* _satisfiable_
  + *if* $S$ contains the empty clause *then*
    - *return* _unsatisfiable_
  + $L := "select_literal"(S)$
  + *if* $"DPLL"(S union {L}) = $ _satisfiable_ *then*
    - *return* _satisfiable_
  + *else*
    - *return* $"DPLL"(S union {not L})$
  + *end*
]

// #diagram(
//   debug: 3,
//   // axes: (ttb, ltr),
//   blob((0.5, 0), tint: yellow, name: <n0>)[
//     $
//       not a or not b \
//       not a or b \
//       a or not b \
//       a or b \
//     $
//   ],
//   blob((0, 1), tint: yellow, name: <n1>)[
//     $
//       not a \
//       not a or not b \
//       not a or b \
//       a or not b \
//       a or b \
//     $
//   ],
//   blob((1, 1), tint: yellow, name: <n2>)[
//     $
//       a \
//       not a or not b \
//       not a or b \
//       a or not b \
//       a or b \
//     $
//   ],
//   blob((0, 2), tint: yellow, name: <n3>)[$square$],
//   blob((1, 2), tint: yellow, name: <n4>)[$square$],
//   edge(<n0>, "-|>", <n1>)[$a$],
//   edge(<n0>, "-|>", <n2>)[$not a$],
//   edge(<n1>, "..|>", <n3>),
//   edge(<n2>, "..|>", <n4>),
// )

= Advanced Topics

== Abstract DPLL

#definition[
  Abstract DPLL is a high-level framework for a general and simple abstract rule-based formulation of the DPLL procedure. @nieuwenhuis2005 @nieuwenhuis2006
]

DPLL procedure is being modelled by a _transition system_: a set of _states_ and a _transition relation_.
- States are denoted by $S$.
- We write $S transition S'$ when the pair $(S, S')$ is in the transition relation, meaning that $S'$ is _reachable_ from~$S$ in one _transition step_.
- We denote by $transition^*$ the reflexive-transitive closure of $transition$.
- We write $S transition^! S'$ if $S transition^* S'$ and $S'$ is a _final_ state, i.e., there is no $S''$ such that $S' transition S''$.
- A state is either _fail_ or a pair $M || F$, where $M$ is a _model_ (a sequence of _annotated literals_) and $F$ is a finite set of clauses.
- An empty sequence of literals is denoted by $emptyset$.
- A literal can be annotated as _decision literal_, which is denoted by $l^d$.
- We write $F,C$ to denote the set $F union {C}$.

== DPLL

The _basic DPLL system_ consists of the following transition rules:

- _UnitPropagate_: \
  $M || F, (C or l) transition M l || F, (C or l)$
  #h(1em) *if* $cases(
    M med models med  not C,
    l "is undefined in" M,
  )$

- _PureLiteral_: \
  $M || F transition M || F$
  #h(1em) *if* $cases(
    l "occurs in some clause of" F,
    not l "does not occur in any clause of" F,
    l "is undefined in" M,
  )$

- _Decide_: \
  $M || F, C transition M l^d || F, C$
  #h(1em) *if* $cases(
    l "or" not l "occurs in a clause of" F,
    l "is undefined in" M,
  )$

- _Fail_: \
  $M || F, C transition$ _fail_
  #h(1em) *if* $cases(
    M med models med not C,
    M "contains no decision literals",
  )$

- _Backtrack_: \
  $M l^d N || F,C transition M not l || F,C$
  #h(1em) *if* $cases(
    M l^d N med models med not C,
    N "contains no decision literals",
  )$

== CDCL

Extended rules:

- _Learn_: \
  $M || F transition M || F,C$
  #h(1em) *if* $cases(
    "all atoms of" C "occur in" F,
    F models C,
  )$

- _Backjump_: \
  $M l^d N || F,C transition M l' || F,C$
  #h(1em) *if* $cases(
    M l^d N med models med not C,
    "there is asome clause" C' or l' "such that:",
    F\,C med models med C' or l',
    l' "is undefined in" M,
    l' or not l' "occurs in" F "or in" M l^d N,
  )$

- _Forget_: \
  $M || F, C transition M || F$
  #h(1em) *if* $cases(
    F med models med C,
  )$

- _Restart_: \
  $M || F transition emptyset || F$

TODO: discuss

== TODO

#show: cheq.checklist
- [ ] CDCL
- [/] Abstract DPLL

== Bibliography

#bibliography("refs.yml")
