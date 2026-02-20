#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Boolean Satisfiability",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)
#show table.cell.where(y: 0): strong


= SAT Problem

== Boolean Satisfiability Problem (SAT)

A propositional formula is _satisfiable_ if it has a _model_ --- an assignment of truth values that makes it true.

#definition[Boolean Satisfiability (SAT)][
  Given a propositional formula $phi$ over variables $X = {x_1, dots, x_n}$, decide whether
  $ exists nu : X to {0, 1}. quad nu models phi $
  *SAT* (decision): does a model exist?
  *Functional SAT*: also return a concrete $nu$.
]

SAT solvers work with formulas in CNF: a conjunction of _clauses_, each a disjunction of _literals_.

#example[
  Formula: $(x_1 or not x_2) and (not x_1 or x_3) and (x_2 or x_3)$.
  - Assignment ${x_1 = 1, x_2 = 0, x_3 = 1}$: every clause is satisfied --- this is a _model_.
  - Assignment ${x_1 = 0, x_2 = 1, x_3 = 0}$: *not* a _model_.
    - clause $(x_2 or x_3) = (1 or 0) = 1$ #YES
    - clause $(not x_1 or x_3) = (1 or 0) = 1$ #YES
    - clause $(x_1 or not x_2) = (0 or 0) = 0$ #NO
]

// #Block(color: yellow)[
//   *Recall:* SAT is NP-complete (Cook--Levin, 1971).
//   Any NP problem reduces to SAT in polynomial time, making SAT solvers _universal search engines_.
// ]

== The Cook--Levin Theorem

#theorem[Cook--Levin (Cook 1971, Levin 1973)][
  SAT is NP-complete: it is in NP, and _every_ problem in NP can be reduced to SAT in polynomial time.
]

*Proof idea:* Every NP problem has a polynomial-time verifier $V$ (a Turing machine). We encode $V$'s execution as a Boolean formula:

#columns(2)[
  *Variables* (for $T$ steps, $S$ cells):
  - $q_(t,s)$: machine in state $s$ at step $t$
  - $h_(t,p)$: head at position $p$ at step $t$
  - $c_(t,p,sigma)$: cell $p$ has symbol $sigma$ at step $t$

  #colbreak()

  *Clauses* enforce valid computation:
  - _Initial config_ --- input on tape
  - _Transition function_ --- $delta$ as implications
  - _Acceptance_ --- accepting state reached
]

The resulting formula $phi$ is satisfiable iff $V$ accepts on some certificate.
The reduction is polynomial: $O(T^2)$ clauses, where $T = p(n)$ is the verifier's runtime.

== SAT Encoding Methodology

To reduce a search problem to SAT:

+ *Define variables* for each binary choice in the problem.
+ *Encode constraints* as propositional clauses.
+ *Convert to CNF* if needed (use Tseitin to avoid exponential blowup).
+ *Run a SAT solver* to obtain a model or an UNSAT proof.

#example[
  *Graph $k$-colorability:* can we color the vertices of $G = (V, E)$ with $k$ colors so adjacent vertices receive different colors?
  - *Variables:* $c_(v, i)$ = "vertex $v$ gets color $i$", for $v in V$, $i in {1, dots, k}$.
  - *EO per vertex:* each vertex gets exactly one color.
  - *Edge constraint:* for each $(u,v) in E$ and color $i$: $(not c_(u,i) or not c_(v,i))$.
  If the solver returns SAT, reading off the values of $c_(v, dot)$ gives the coloring.
]

== Encoding Patterns: At-Least-One & At-Most-One

Encoding cardinality constraints is a recurring task.

#definition[
  _At least one_ (ALO) of $x_1, dots, x_n$ is true:
  $ (x_1 or x_2 or dots or x_n) $
  One clause with $n$ literals.
]

#definition[
  _At most one_ (AMO) of $x_1, dots, x_n$ is true.
  *Pairwise encoding:* for each pair $i < j$,
  $ (not x_i or not x_j) $
  One clause per pair: $binom(n, 2)$ clauses total.
]

#pagebreak()

#example[
  AMO on ${x_1, x_2, x_3}$: three clauses $(not x_1 or not x_2) and (not x_1 or not x_3) and (not x_2 or not x_3)$.
  The assignment $x_1 = 1, x_2 = 1, x_3 = 0$ falsifies the first clause: $(0 or 0) = 0$.
  Any assignment with at most one true variable satisfies all three.
]

#note[
  Pairwise AMO produces $O(n^2)$ clauses.
  For large $n$, _commander--variable_ or _logarithmic_ encodings achieve $O(n)$ clauses using auxiliary variables.
]

== Encoding Patterns: Exactly-One & Implications

#definition[
  _Exactly one_ (EO) of $x_1, dots, x_n$ is true: $"ALO" and "AMO"$ combined.
  $ underbrace((x_1 or dots or x_n), "ALO") and underbrace(and.big_(i < j) (not x_i or not x_j), "AMO") $
]

Common encoding primitives:

- *Implication:* $a imply b$ becomes $(not a or b)$ --- one clause.
- *If-then-else:* $"ite"(c, t, e)$ becomes $(not c or t) and (c or e)$ --- two clauses.
- *Mutual exclusion:* "at most one of $x_1, dots, x_n$" --- use AMO.
- *Channeling:* link two groups of variables, e.g., $x_(i,j) iff y_(j,i)$.

#Block(color: orange)[
  *Common mistake:* Encoding ALO without AMO.
  Without the pairwise clauses, the solver is free to set _multiple_ variables true --- the encoding is too weak to rule out invalid solutions.
]

== Encoding Patterns: Summary

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Pattern*][*Clauses*][*Aux Vars*][*When to Use*],
    [ALO$(x_1, dots, x_n)$], [$1$], [$0$], [Something must be chosen],
    [AMO pairwise], [$binom(n, 2)$], [$0$], [At most one choice ($n lt.eq 10$)],
    [AMO commander], [$O(n)$], [$O(n)$], [At most one choice ($n > 10$)],
    [EO = ALO + AMO], [$1 + binom(n, 2)$], [$0$], [Exactly one choice],
    [Implication $a imply b$], [$1$], [$0$], [Dependency between choices],
    [If-then-else], [$2$], [$0$], [Conditional assignment],
  )
]


= SAT Encodings

== Example: Graph Coloring

Graph $G = (V, E)$: vertices $V$, edges $E$ (unordered pairs).
$K_n$ --- the complete graph on $n$ vertices (every pair connected).

*Problem:* Color the _edges_ of $K_n$ using $k$ colors with _no monochromatic triangle_.
What is the largest $n$ for which this is possible?

- For $k = 1$: $n = 2$ (only 1 edge).
- For $k = 2$: $n = 5$ (see diagram on the right).
- For $k = 3$: $n = 16$ (requires a SAT solver to verify).

#place(bottom + right)[
  #fletcher.diagram({
    let nodes = (1, 2, 3, 4, 5)
    for i in nodes {
      let angle = 18deg + i * 72deg
      fletcher.node((angle, 1cm), str(i), stroke: 1pt, outset: 1pt, name: str(i))
    }
    for i in nodes {
      for j in nodes {
        if i < j {
          fletcher.edge(
            label(str(i)),
            label(str(j)),
            "-",
            stroke: if (calc.abs(i - j) == 1 or (i == 1 and j == 5)) { 2pt + red } else { 1pt + blue },
          )
        }
      }
    }
  })
]

== Modelling Graph Coloring as SAT

+ *Variables:* For each edge $e$ and color $c in {1, dots, k}$, define $e_c$ ("edge $e$ has color $c$").

+ *Constraints:*

  Each edge gets _exactly one_ color (#Blue[ALO] + #Red[AMO]):
  $ #Blue[$(e_1 or e_2 or e_3)$] and #Red[$not (e_1 and e_2) and not (e_1 and e_3) and not (e_2 and e_3)$] $

  No monochromatic triangle --- for each triangle $(e, f, g)$ and color $c$:
  $ not (e_c and f_c and g_c) $

+ *CNF:* The constraints above are already (close to) CNF.

+ *Solve:* Increase $n$ until the formula becomes UNSAT.

#Block(color: yellow)[
  The EO constraint on edge colors is exactly the ALO + AMO pattern from the previous section --- applied to the set of color variables for each edge.
]

== DIMACS CNF Format

SAT solvers use the _DIMACS CNF_ format --- a standard text representation:

#columns(2)[
  ```
  c This is a comment
  p cnf 4 3
  1 2 -3 0
  -1 3 0
  2 3 4 0
  ```

  #colbreak()

  - `p cnf <vars> <clauses>` --- header
  - Variables: positive integers $1, 2, dots$
  - Negation: prefix with `-`
  - Each clause ends with `0`
  - Comments start with `c`
]

#v(0.5em)

Run a solver:
```sh
cadical formula.cnf
```

If SAT, the solver outputs a _model_ (a line of `v` values).
If UNSAT, a DRAT _proof certificate_ can be requested with `--proof`.

== Code: Graph Coloring SAT Encoding

#columns(2)[
  #set text(size: 0.8em)
  #show raw: block.with(stroke: 0.4pt, inset: 1em, radius: 5pt)
  ```py
  n = 17
  k = 3
  m = n * (n - 1) // 2

  edges = {}
  for u in range(1, n + 1):
      for v in range(u + 1, n + 1):
          edges[(u, v)] = len(edges) + 1

  def color(e, c):
      return (e - 1) * k + c

  clauses = []
  for e in range(1, m + 1):
      # ALO: at least one color per edge
      clauses.append([
        color(e, c) for c in range(1, k + 1)
      ])
      # AMO: at most one color per edge
      for c1 in range(1, k + 1):
          for c2 in range(c1 + 1, k + 1):
              clauses.append([
                -color(e, c1), -color(e, c2)
              ])
  # No monochromatic triangles
  for v1 in range(1, n + 1):
      for v2 in range(v1 + 1, n + 1):
          for v3 in range(v2 + 1, n + 1):
              e12 = edges[(v1, v2)]
              e23 = edges[(v2, v3)]
              e13 = edges[(v1, v3)]
              for c in range(1, k + 1):
                  clauses.append([
                    -color(e12, c),
                    -color(e23, c),
                    -color(e13, c)
                  ])
  # Output DIMACS CNF
  print(f"p cnf {color(m, k)} {len(clauses)}")
  for clause in clauses:
      print(" ".join(map(str, clause)) + " 0")
  ```
]

== Example: N-Queens

Place $n$ queens on an $n times n$ board so no two attack each other.

*Variables:* $q_(i,j)$ = "queen on row $i$, column $j$" #h(1em) ($n^2$ variables).

*Constraints:*
- *EO per row:*  exactly one queen in each row $i$: ALO$(q_(i,1), dots, q_(i,n))$ + AMO.
- *AMO per column:*  at most one queen in each column $j$: AMO$(q_(1,j), dots, q_(n,j))$.
- *AMO per diagonal:*  at most one queen on each diagonal and anti-diagonal.

*Size:* $n^2$ variables, $O(n^3)$ clauses (pairwise AMO on each line).

#note[
  N-Queens is a classic SAT benchmark.
  For $n = 1000$, the encoding has $10^6$ variables and $~10^9$ clauses --- but modern solvers handle it in seconds.
]

== Example: Pigeonhole Principle (Sketch)

Place $n + 1$ pigeons into $n$ holes, at most one pigeon per hole.

*Variables:* $p_(i,j)$ = "pigeon $i$ goes into hole $j$" #h(1em) ($n(n+1)$ variables).

*Constraints:*
- *ALO per pigeon:* each pigeon gets a hole: $(p_(i,1) or dots or p_(i,n))$.
- *AMO per hole:* each hole has at most one pigeon: $(not p_(i,j) or not p_(k,j))$ for $i eq.not k$.

This formula is *always UNSAT* ($n + 1$ pigeons cannot fit in $n$ holes).

#Block(color: orange)[
  *Proof complexity:* Resolution proofs of $"PHP"_(n+1)^n$ require exponentially many steps (Haken, 1985).
  DPLL implicitly constructs resolution proofs, so it struggles here.
  CDCL with learned clauses can do better --- but pigeonhole remains hard for all known solvers.
]

== Encodings: Key Takeaways

#Block(color: yellow)[
  *The SAT encoding recipe:*
  + Identify the _choices_ in your problem $=>$ propositional variables.
  + Express _validity conditions_ using ALO, AMO, EO, implication patterns.
  + Convert to CNF (usually straightforward; use Tseitin if needed).
  + Feed to a SAT solver and interpret the result.
]

The expressiveness comes from NP-completeness: any polynomially verifiable property encodes into SAT.
The efficiency comes from the solvers themselves: modern CDCL handles _billions_ of clauses.


= Algorithms for SAT

== Davis--Putnam Algorithm

#[
  #let fig = grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    box(
      inset: (right: -0.6cm),
      clip: true,
      stroke: 1pt + blue,
      radius: 5pt,
      image("assets/Martin_Davis.jpg", height: 3cm),
    ),
    box(
      stroke: 1pt + blue,
      radius: 5pt,
      image("assets/Hilary_Putnam.jpg", height: 3cm),
    ),

    [Martin Davis], [Hilary Putnam],
  )
  #let body = [
    The first algorithm for SAT was proposed by Martin Davis and Hilary Putnam in 1960 @davis1960.

    Satisfiability-preserving simplification rules:
    + *Unit propagation* --- propagate forced assignments.
    + *Pure literal elimination* --- remove variables appearing with one polarity.
    + *Resolution* (variable elimination) --- resolve away a variable.

    The original DP algorithm uses resolution, which can _increase_ formula size.
    DPLL (1962) replaces resolution with _splitting_ (backtracking search), which is far more practical.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

Henceforth, formulas are represented in *CNF*: a set of clauses, each a set of literals.

== Unit Propagation Rule

#definition[Unit clause][
  A _unit clause_ is a clause with a single literal.
]

Suppose $(p)$ is a unit clause.
Recall that $overline(p)$ denotes the complement literal:
#h(1em, weak: true)
$overline(p) = cases(
  not p "if" p "is positive",
  p "if" p "is negative"
)$

Unit propagation:
- Assign $p$ to true.
- Remove all clauses containing $p$ (they are satisfied).
- Remove $overline(p)$ from all remaining clauses (it is falsified).

#example[
  #let r(x) = $cancel(#x, stroke: #red, cross: #true)$
  Consider $(A or B) and (A or not B) and (not A or B) and (not A or not B) and (A)$.

  - The unit clause $(A)$ forces #box[$A = 1$].

  - Remove clauses with $A$; remove $not A$ from the rest:
    $ #r($(A or B)$) and #r($(A or not B)$) and (#r($not A$) or B) and (#r($not A$) or not B) and #r($(A)$) $

  - Result: $(B) and (not B)$ --- still unsatisfiable.
]

== Pure Literal Rule

#definition[
  A literal $p$ is _pure_ if it appears in the formula only positively or only negatively.
]

Pure literal elimination:
- Assign the pure literal to true.
- Remove all clauses containing it (they are now satisfied).

#example[
  $(A or B) and (A or C) and (B or C)$.
  - Literal $A$ is pure (appears only positively).
  - Assign $A = 1$, remove clauses containing $A$: result is $(B or C)$.
]

#note[
  Unit propagation is a _forced_ assignment (no choice).
  Pure literal elimination is a _safe_ assignment (any model can be extended).
  Both reduce the formula without branching.
]

== Davis--Putnam--Logemann--Loveland (DPLL)

#grid(
  columns: (40%, auto),
  column-gutter: 1em,

  lovelace.pseudocode-list(
    hooks: 0.5em,
    line-gap: 0.7em,
  )[
    - #smallcaps[*Input:*] set of clauses $S$
    - #smallcaps[*Output:*] _satisfiable_ or _unsatisfiable_
    + $S := "propagate"(S)$
    + *if* $S$ is empty *then*
      - *return* _satisfiable_
    + *if* $S$ contains the empty clause $square$ *then*
      - *return* _unsatisfiable_
    + $L := "select_literal"(S)$
    + *if* $"DPLL"(S union {L}) =$ _satisfiable_ *then*
      - *return* _satisfiable_
    + *else*
      - *return* $"DPLL"(S union {not L})$
    + *end*
  ],
  [
    DPLL @davis1962 replaces resolution with _splitting_: pick a literal, assert it, propagate, recurse; on failure, assert its negation.

    DPLL is _complete_: it always terminates and finds a satisfying assignment iff one exists.

    The search forms a binary tree where each internal node is a literal choice and leaves are SAT or UNSAT.
  ],
)

== DPLL Flowchart

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #diagram(
    spacing: 3em,
    node-corner-radius: 3pt,
    edge-stroke: 1pt,
    edge-corner-radius: 5pt,
    mark-scale: 80%,
    blob(
      (0, 0),
      [$"DPLL"(S)$],
      tint: purple,
      shape: shapes.rect,
      corner-radius: 1em,
      name: <start>,
    ),
    edge("-|>"),
    blob(
      (0, 1),
      [Propagate],
      tint: blue,
      shape: shapes.rect,
      name: <propagate>,
    ),
    edge("-|>"),
    blob(
      (0, 2),
      [Empty? \ $S =^? emptyset$],
      tint: yellow,
      shape: shapes.diamond,
      name: <empty>,
    ),
    blob(
      (0, 3),
      [Conflict? \ $square in^? S$],
      tint: yellow,
      shape: shapes.diamond,
      name: <conflict>,
    ),
    blob(
      (-1, 2),
      [SAT],
      tint: green,
      shape: shapes.parallelogram,
      name: <sat>,
    ),
    blob(
      (-1, 3),
      [UNSAT],
      tint: red,
      shape: shapes.parallelogram,
      name: <unsat>,
    ),
    blob(
      (1, 3),
      [Select literal $L$],
      tint: blue,
      shape: shapes.rect,
      name: <select>,
    ),
    blob(
      (1, 2),
      [Recursive call \ $"DPLL"(S union {L})$],
      tint: blue,
      shape: shapes.hexagon,
      name: <recursive-positive>,
    ),
    blob(
      (1, 1),
      [Recursive call \ $"DPLL"(S union {not L})$],
      tint: blue,
      shape: shapes.hexagon,
      name: <recursive-negative>,
    ),
    node(
      (1, 0),
      [SAT/UNSAT],
      fill: gradient.linear(green.lighten(80%), red.lighten(80%)),
      shape: shapes.parallelogram,
      stroke: 1pt + gradient.linear(green.darken(20%), red.darken(20%)),
      name: <return>,
    ),
    edge(<empty>, "-|>", <conflict>, [no], label-pos: 0.1),
    edge(<empty>, "-|>", <sat>, [yes], label-pos: 0.1),
    edge(<conflict>, "-|>", <unsat>, [yes], label-pos: 0.1),
    edge(<conflict>, "-|>", <select>, [no], label-pos: 0.1),
    edge(<select>, "-|>", <recursive-positive>),
    edge(
      <recursive-positive>,
      "-|>",
      <sat.north>,
      text(fill: green.darken(20%))[SAT],
      label-pos: 0.1,
      bend: -40deg,
      label-angle: auto,
    ),
    edge(
      <recursive-positive>,
      "-|>",
      <recursive-negative>,
      text(fill: red.darken(20%))[UNSAT],
    ),
    edge(<recursive-negative>, "-|>", <return>),
  )
]

== Worked DPLL Trace

Consider: $(A or B) and (not A or C) and (not B or not C) and (A or not C)$ --- 4 clauses, 3 variables.

#align(center)[
  #table(
    columns: 5,
    align: (center, left, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Step*][*Action*][*Assignment*][*Clauses*][*Status*],
    [1], [Decide $A = 1$], [$A = 1$], [$(not A or C) => (C)$; others simplified], [],
    [2], [Unit prop $C = 1$], [$A = 1, C = 1$], [$(not B or not C) => (not B)$], [],
    [3], [Unit prop $B = 0$], [$A = 1, C = 1, B = 0$], [Check $(A or B)$: satisfied], [#Green[SAT] #YES],
  )
]

Model: $nu = {A = 1, B = 0, C = 1}$.
Verify: all clauses satisfied.

#note[
  In this trace, DPLL found a model without backtracking.
  On structured hard instances (pigeonhole, parity), the search tree can have exponentially many branches.
]

== From DPLL to CDCL

DPLL has a fundamental limitation: *chronological backtracking*.

When a conflict occurs, DPLL backtracks to the most recent decision --- even if that decision was irrelevant to the conflict.
This forces the solver to re-explore search spaces that cannot possibly contribute to a solution.

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    *DPLL:*
    - Backtrack to the previous decision
    - Undo it, try the other value
    - No "memory" of _why_ the conflict occurred
    - May repeat the same mistake \ in a different subtree
  ],
  [
    *CDCL:*
    - Analyze the conflict: which prior decisions caused it?
    - Learn a new clause that excludes this combination.
    - Backjump to the earliest relevant decision level.
    - The same conflict assignment is now ruled out \ by the learned clause.
  ],
)

#Block(color: yellow)[
  *CDCL answer:* analyze the implication graph to identify which decisions caused the conflict, learn a clause encoding that fact, and jump directly to the responsible level.
]

== DPLL: Key Takeaways

#Block(color: yellow)[
  *DPLL = backtracking + unit propagation + pure literal.*
  - Decides a variable, propagates consequences, recurses.
  - Complete: always finds a solution or proves UNSAT.
  - Worst case: $O(2^n)$ --- explores the full binary decision tree.
  - The backbone of _all_ modern SAT solvers.
]

#note[
  DPLL can be formalized as a _transition system_ with rules for unit propagation, decisions, and backtracking @nieuwenhuis2006.
  This abstract framework extends naturally to CDCL via Learn and Backjump rules.
]


= Conflict-Driven \ Clause Learning

== Implication Graph

During propagation, each forced assignment has a _reason_ --- the clause that caused it. \
The implication graph makes these dependencies explicit.

#v(-0.5em)
#definition[Implication Graph][
  A labeled directed acyclic graph where:
  - *Nodes* represent assigned literals, labeled with their decision level (1, 2, 3, ...).
  - *Edges* from a clause $C$ point to the propagated literal $ell$ with label $C$ ("clause $C$ forced $ell$").
  - *Source nodes* correspond to decisions (no incoming edges, marked $square.small.filled$).
  - *Sink node* $kappa$ is a special conflict node, with incoming edges from literals in the conflicting clause.
]
#v(-0.5em)

#example[
  Consider the formula from the next slide: $c_1 = (x_1 or x_2)$, $c_3 = (not x_2 or x_3)$, $c_4 = (not x_3 or x_4)$, $c_5 = (not x_3 or not x_4)$.
  At decision level 1, assign $x_1 := 0$.

  Unit propagations: $c_1$ forces $x_2 := 1$; $c_3$ forces $x_3 := 1$; $c_4$ forces $x_4 := 1$; $c_5 = (0 or 0)$ --- conflict.

  All four literals are at level 1.
  Implication graph (edges labeled by forcing clause):
  #v(-0.3em)
  $ overline(x)_1 arrow.r^(c_1) x_2 arrow.r^(c_3) x_3 arrow.r^(c_4) x_4 arrow.r^(c_5) kappa $
  #v(-0.3em)
  with a second edge $x_3 arrow.r^(c_5) kappa$ (both $not x_3$ and $not x_4$ are in the conflict clause).
]

== Conflict Analysis

When a conflict occurs, CDCL traces the implication graph backward to derive a clause that explains the conflict.

#definition[1-UIP (Unique Implication Point)][
  The _first unique implication point_ (1-UIP) is the node at the current decision level $d$ that is closest to $kappa$ and dominates _all_ paths from the level-$d$ decision to $kappa$.

  _Learned clause:_ negate the 1-UIP literal, plus the negations of all prior-level literals that have edges into the conflict side of the cut.
]

#example[
  From the previous slide.
  - Paths from $overline(x)_1$ to $kappa$: $overline(x)_1 -> x_2 -> x_3 -> x_4 -> kappa$ and $overline(x)_1 -> x_2 -> x_3 -> kappa$.
  - Both pass through $x_3$; neither requires $x_4$ on both.
  - So $x_3$ dominates all paths --- it is the 1-UIP.

  Apply the resolution procedure:
  - Start with conflict clause $c_5 = (not x_3 or not x_4)$.
  - Two level-1 literals.
  - Resolve on $x_4$ with its reason $c_4 = (not x_3 or x_4)$: the resolvent is $(not x_3)$.
  - One level-1 literal remains.
  - *Learned clause: $(not x_3)$.*

  No prior-level literals appear, so backjump to level 0 and propagate $x_3 := 0$.
]

The learned clause is added permanently to the clause database.

#Block(color: blue)[
  Each learned clause is a _resolution proof_ on the original clauses.
  The 1-UIP resolution procedure is exactly backward chaining through the implication graph via resolution steps.
]

== Worked CDCL Example

Consider formula $F$ over variables $x_1, x_2, x_3, x_4$ with clauses:
$
  c_1 = (x_1 or x_2), quad c_2 = (not x_1 or x_3), quad c_3 = (not x_2 or x_3), quad c_4 = (not x_3 or x_4), quad c_5 = (not x_3 or not x_4)
$

#align(center)[
  #table(
    columns: 4,
    align: (center, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Level*][*Action*][*Propagation*][*Status*],
    [1],
    [Decide $x_1 = 0$],
    [$c_1 => x_2 = 1$; $c_3 => x_3 = 1$; \ $c_4 => x_4 = 1$; $c_5 = (0 or 0)$ --- conflict],
    [#Red[Conflict!]],

    [], [1-UIP: resolve $c_5$ on $x_4$ with $c_4$; learned clause $(not x_3)$], [], [Backjump to level 0],
    [0], [Unit prop: $x_3 = 0$], [$c_2 => x_1 = 0$; $c_1 => x_2 = 1$; $c_3 = (0 or 0)$ --- conflict], [#Red[Conflict!]],
    [], [Level 0 conflict $=>$ *UNSAT*], [], [],
  )
]

The formula is unsatisfiable.
CDCL discovered this in two conflicts: the first at level 1 (learning $not x_3$), the second at level 0 (no further backtracking possible).

== Non-Chronological Backtracking

#columns(2)[
  *Chronological* (DPLL):
  - Conflict at level $k$
  - Go back to level $k - 1$
  - Try the other branch
  - May waste work if level $k - 1$ was irrelevant

  #colbreak()

  *Non-chronological* (CDCL):
  - Conflict at level $k$
  - Analyze: learned clause has highest levels $k$ and $j$ ($j < k$)
  - *Backjump* directly to level $j$
  - Skip all levels between $j$ and $k$
]

#v(1em)

#Block(color: yellow)[
  Backjumping skips irrelevant search space.
  A learned clause with highest levels $k$ and $j$ ($j < k$) means: once we have tried the level-$k$ decision, we can jump straight to level $j$ without exploring anything in between.
  Combined with clause learning, the solver never makes the same conflict-causing assignment twice.
]

== CDCL Flowchart

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #diagram(
    spacing: (3em, 2em),
    node-corner-radius: 3pt,
    edge-stroke: 1pt,
    edge-corner-radius: 5pt,
    mark-scale: 80%,
    blob(
      (0, 0),
      [Start],
      tint: purple,
      shape: shapes.parallelogram,
    ),
    edge("-|>"),
    blob(
      (0, 1),
      [Propagate],
      tint: blue,
      shape: shapes.rect,
      name: <propagate>,
    ),
    edge("-|>"),
    blob(
      (0, 2),
      [Conflict?],
      tint: yellow,
      shape: shapes.diamond,
      name: <conflict>,
    ),
    blob(
      (-1, 2),
      [All vars\ assigned?],
      tint: yellow,
      shape: shapes.diamond,
      name: <empty>,
    ),
    blob(
      (-1, 3),
      [SAT],
      tint: green,
      shape: shapes.parallelogram,
      name: <sat>,
    ),
    blob(
      (-1, 1),
      [Decide\ next literal],
      tint: blue,
      shape: shapes.rect,
      name: <select>,
    ),
    blob(
      (1, 2),
      [Level 0?],
      tint: yellow,
      shape: shapes.diamond,
      name: <level>,
    ),
    blob(
      (1, 3),
      [UNSAT],
      tint: red,
      shape: shapes.parallelogram,
      name: <unsat>,
    ),
    blob(
      (1, 1),
      [Analyze \ Learn \ Backjump],
      tint: blue,
      shape: shapes.rect,
      name: <analyze>,
    ),
    edge(<conflict>, "-|>", <empty>)[no],
    edge(<conflict>, "-|>", <level>)[yes],
    edge(<level>, "-|>", <unsat>)[yes],
    edge(<level>, "-|>", <analyze>)[no],
    edge(<empty>, "-|>", <sat>)[yes],
    edge(<empty>, "-|>", <select>)[no],
    edge(<select>, "-|>", <propagate>),
    edge(<analyze>, <propagate>, "-|>"),
  )
]

== CDCL Heuristics

Beyond the core algorithm, several heuristics make CDCL practical:

*VSIDS* (Variable State Independent Decaying Sum):
- Track an _activity score_ per variable; bump the score of variables in each conflict clause.
- Periodically multiply all scores by a decay factor.
- Always pick the highest-activity unassigned variable next.
- Focuses search on variables that appear in recent conflicts --- the structurally "hard" part.

*Restarts:*
- Periodically restart from scratch, keeping all learned clauses.
- Schedule via Luby sequence or geometric intervals.
- Escapes unproductive regions of the search space.

*Phase saving:*
- When a variable is decided, use its most recently assigned polarity.
- Quickly rediscovers satisfying sub-assignments after a restart.

// #note[
//   These heuristics matter more than the core algorithm for practical performance. A solver with poor heuristics can be orders of magnitude slower.
// ]

== SAT Solver Architecture

A modern CDCL solver (e.g., MiniSat, ~2k lines of C++) consists of:

#align(center)[
  #table(
    columns: 2,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Component*][*Purpose*],
    [Clause database], [Stores original + learned clauses; periodically garbage-collects],
    [Two-watched-literal scheme],
    [Efficient unit propagation --- only visit a clause when a watched literal becomes false],

    [Decision heuristic (VSIDS)], [Pick the next branching variable; bump activity on conflict],
    [Conflict analysis (1-UIP)], [Derive learned clause from implication graph],
    [Restart policy], [Luby or geometric; prevents getting stuck in unproductive subtrees],
    [Phase saving], [Remember last polarity of each variable for faster re-exploration],
  )
]

#note[
  The two-watched-literal scheme is the key to scalability --- it makes unit propagation amortized $O(1)$ per propagation step, instead of scanning every clause.
]

== Modern SAT Solvers and Competitions

#columns(2)[
  *Key solvers:*
  - *MiniSat* (Eén & Sörensson, 2003) --- clean reference implementation, widely embedded in tools.
  - *CaDiCaL* (Biere) --- state-of-the-art, incremental API, DRAT proof logging.
  - *Kissat* (Biere, 2020) --- competition-optimized, inprocessing techniques.

  #colbreak()

  *SAT Competition* (annual since 2002):
  - *Industrial* track: verification and planning instances from industry.
  - *Crafted* track: hard combinatorial benchmarks.
  - *Random* track: random $k$-SAT near the phase transition.
  - Open-source requirement drives solver improvement.
]

#Block(color: yellow)[
  Modern solvers routinely handle _millions_ of variables and _billions_ of clauses.
  NP-complete in theory; polynomial in practice for structured industrial instances --- the gap is entirely due to CDCL plus engineering.
]

== Applications of SAT

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Hardware Verification*
    - Bounded Model Checking (BMC): unroll circuit $k$ times, check for bugs via SAT.
    - Equivalence checking: are two circuits functionally identical?
    - Used at Intel, AMD, ARM for chip design validation.
    - _Intel Pentium FDIV bug (1994)_: cost \$475M. Modern SAT-based verification would have caught it.

    *AI Planning*
    - Encode: can we reach goal state in $k$ steps?
    - SATPlan: competitive with dedicated planners.
    - Mars rover path planning: 60-minute problems solved in seconds.
  ],
  [
    *Software Analysis*
    - Symbolic execution backends (KLEE, SAGE).
    - Concolic testing: concrete + symbolic execution.
    - Configuration coverage: Linux kernel has 15k+ options $=>$ $2^(15000)$ configs --- SAT finds bugs in specific combinations.

    *Cryptanalysis & Mathematics*
    - _Boolean Pythagorean Triples theorem (2016)_: proved using SAT solver, generated 200~TB proof!
    - Attack stream ciphers via algebraic SAT encoding.
    - Factorization: $n = p times q$ encoded as multiplication circuit + SAT.
  ],
)

#Block(color: teal)[
  In 2016, researchers used a SAT solver to solve the Boolean Pythagorean Triples problem --- a 35-year-old open problem in Ramsey theory.
  The solver ran for 2 days on ~800 cores, exploring $10^(18)$ search states, and produced a 200~TB proof (largest math proof ever).
  - _The problem:_ Can we 2-color positive integers such that no Pythagorean triple $a^2 + b^2 = c^2$ is monochromatic?
  - _Answer:_ Yes up to 7824, impossible beyond.
]

== CDCL: Key Takeaways

#Block(color: yellow)[
  *CDCL = DPLL + clause learning + non-chronological backtracking.*
  - Analyzes conflicts via _implication graphs_.
  - Derives _learned clauses_ that prune future search.
  - _Backjumps_ to the relevant decision level, skipping irrelevant levels.
  - VSIDS + restarts + phase saving = practical efficiency.
  - Basis of _every_ competitive SAT solver since ~2000.
]


= Summary and Exercises

== Summary

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *SAT Encoding:*
    - Variables capture binary choices
    - ALO, AMO, EO constrain cardinality
    - Implication $a imply b$ = one clause
    - 4-step methodology: model $=>$ constrain $=>$ CNF $=>$ solve
  ],
  [
    *SAT Solving:*
    - DPLL: backtracking + unit propagation
    - CDCL: + clause learning + backjumping
    - Implication graphs trace propagation
    - 1-UIP: derive learned clauses at conflicts
    - VSIDS, restarts: practical performance
  ],
)

#v(0.5em)

#Block(color: blue)[
  *The pipeline:* Problem $->$ SAT encoding (ALO/AMO/EO) $->$ DIMACS CNF $->$ CDCL solver $->$ model or UNSAT proof. \
  *Next lecture:* FOL theories and SMT --- extending SAT with background knowledge about arithmetic, arrays, and uninterpreted functions.
]

== Exercises: SAT Encoding

+ Encode the following problem as a SAT instance:
  _Schedule 4 lectures into 3 time slots such that no two lectures with a shared student occur in the same slot._
  Define the variables, ALO/AMO/EO constraints, and conflict constraints.

+ Write a Python script to generate the DIMACS CNF encoding for vertex coloring of a graph with $n$ vertices, $m$ edges, and $k$ colors.
  Test it on the Petersen graph ($n = 10$, $k = 3$).

+ Show that a DNF formula can be converted to an equivalent CNF in exponential size in the worst case, but the Tseitin encoding produces an _equisatisfiable_ CNF of linear size.
  Why does equisatisfiability (rather than equivalence) suffice for SAT solving?

== Exercises: DPLL

+ Run the DPLL algorithm (with unit propagation) on the formula:
  $(A or B or C) and (not A or B) and (not B or C) and (not C or A) and (not A or not B or not C)$
  Draw the search tree showing all decisions, propagations, and backtracks.

+ Explain why the pure literal rule is _sound_ (preserves satisfiability) but is rarely used in modern solvers.

+ $star$ Consider the pigeonhole formula $"PHP"_4^3$ (4 pigeons, 3 holes).
  How many nodes does the DPLL search tree have in the worst case?
  What is the optimal variable ordering?

== Exercises: CDCL

+ Given the following implication graph, identify the 1-UIP and derive the learned clause: \
  Decisions: $x_1 = 1$ (level 1), $x_2 = 0$ (level 2). \
  Propagations: $x_3 = 1$ (from $c_1: not x_1 or x_3$), $x_4 = 1$ (from $c_2: x_2 or x_4$), conflict on $c_3: not x_3 or not x_4$.

+ Explain why a conflict at decision level 0 implies UNSAT.

+ Compare DPLL and CDCL on the formula from Exercise 1 above.
  Does CDCL learn any useful clauses?

+ $star$ Show that every CDCL execution on an unsatisfiable formula implicitly constructs a _resolution proof_.
  Explain why this means CDCL can never be worse than tree-like resolution (up to polynomial overhead).

== Bibliography

#bibliography("refs.yml")
