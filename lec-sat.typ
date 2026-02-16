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


= SAT Encoding

== Boolean Satisfiability Problem (SAT)

SAT is the problem of determining whether a given Boolean formula has a _satisfying assignment_ --- a mapping of truth values to variables that makes the formula true.

#definition[Boolean Satisfiability (SAT)][
  Given a propositional formula $phi$ over variables $X = {x_1, dots, x_n}$, decide whether
  $ exists nu : X to {0, 1}. quad nu models phi $
]

SAT is a _decision_ problem (yes/no), but in practice we want the actual assignment --- the _functional SAT_ problem.
SAT instances are typically given in *CNF* (conjunctive normal form): a conjunction of _clauses_, where each clause is a disjunction of _literals_.

#Block(color: yellow)[
  *Recall:* SAT is NP-complete (Cook--Levin, 1971).
  Any problem in NP can be encoded as a SAT instance --- making SAT solvers _universal search engines_.
]

== The Cook--Levin Theorem: Proof Sketch

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

The resulting formula $phi$ is satisfiable $iff$ there exists a certificate that $V$ accepts.
The reduction is polynomial: $O(T^2)$ clauses, where $T = p(n)$ is the verifier's runtime.

#place[
  #v(1em)
  #Block(color: blue)[
    Cook--Levin makes SAT solvers _universal search engines_ --- any polynomially verifiable property can be checked by compiling it to SAT.
  ]
]

== SAT Encoding Methodology

To solve a search problem with a SAT solver:

+ *Define variables* to represent the problem's _state_. \
  Each variable captures a binary choice in the solution.

+ *Encode constraints* as propositional formulas. \
  Express what makes a solution _valid_.

+ *Translate to CNF* (clausal form). \
  Use Tseitin if needed to avoid exponential blowup.

+ *Run a SAT solver* to find a satisfying assignment or prove UNSAT.

#Block(color: blue)[
  *The power of SAT:* This methodology turns _any_ combinatorial search problem into a standard format that state-of-the-art solvers handle efficiently.
]

== Encoding Patterns: At-Least-One & At-Most-One

Many encoding tasks require constraining _how many_ variables in a group are true.

#definition[
  _At least one_ (ALO) of $x_1, dots, x_n$ is true:
  $ (x_1 or x_2 or dots or x_n) $
  *single $n$-literal clause*
]

#definition[
  _At most one_ (AMO) of $x_1, dots, x_n$ is true.
  _Pairwise_ encoding: for each pair $i < j$, add
  $ (not x_i or not x_j) $
  *$binom(n, 2)$ binary clauses*
]

#note[
  Pairwise AMO produces $O(n^2)$ clauses.
  For large $n$, _commander--variable_ or _logarithmic_ encodings reduce this to $O(n)$ clauses using auxiliary variables.
]

== Encoding Patterns: Exactly-One & Implications

#definition[Exactly-One (EO)][
  Exactly one of $x_1, dots, x_n$ is true: $"ALO" and "AMO"$ combined.
  $ underbrace((x_1 or dots or x_n), "ALO") and underbrace(and.big_(i < j) (not x_i or not x_j), "AMO") $
]

Common encoding primitives:

- *Implication:* $a imply b$ becomes $(not a or b)$ --- one clause.
- *If-then-else:* $"ite"(c, t, e)$ becomes $(not c or t) and (c or e)$ --- two clauses.
- *Mutual exclusion:* "at most one of $x_1, dots, x_n$" --- use AMO.
- *Channeling:* link two groups of variables, e.g., $x_(i,j) iff y_(j,i)$.

#Block(color: orange)[
  *Common pitfall:* Forgetting AMO and only encoding ALO. Without AMO, the solver can set _multiple_ variables true --- leading to invalid solutions.
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


= Worked Encodings

== Example: Graph Coloring

Graph $G = (V, E)$: vertices $V$, edges $E$ (unordered pairs).
$K_n$ --- the complete graph on $n$ vertices (every pair connected).

*Problem:* Color the _edges_ of $K_n$ using $k$ colors with _no monochromatic triangle_.
What is the largest $n$ for which this is possible?

- For $k = 1$: $n = 2$ (only 1 edge).
- For $k = 2$: $n = 5$ (see diagram on the right).
- For $k = 3$: $n = 16$ --- a job for a SAT solver.

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
  *Pattern recognition:* The EO constraint on edge colors is exactly the ALO + AMO pattern from the previous section.
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

If SAT, the solver prints a _model_ (variable assignments). \
If UNSAT, it may produce a _proof certificate_.

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

== Example: N-Queens (Sketch)

Place $n$ queens on an $n times n$ board so no two attack each other.

*Variables:* $q_(i,j)$ = "queen on row $i$, column $j$" #h(1em) ($n^2$ variables).

*Constraints:*
- *EO per row:*  exactly one queen in each row $i$: ALO$(q_(i,1), dots, q_(i,n))$ + AMO.
- *AMO per column:*  at most one queen in each column $j$: AMO$(q_(1,j), dots, q_(n,j))$.
- *AMO per diagonal:*  at most one queen on each diagonal and anti-diagonal.

*Size:* $n^2$ variables, $O(n^3)$ clauses (pairwise AMO on each line).

#note[
  N-Queens is a classic SAT benchmark. For $n = 1000$, the encoding has $10^6$ variables and $~10^9$ clauses --- but modern solvers handle it in seconds.
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
  This is why DPLL (which implicitly produces resolution proofs) struggles with pigeonhole --- and why CDCL with learned clauses does better (though it's still hard).
]

== Encodings: Key Takeaways

#Block(color: yellow)[
  *The SAT encoding recipe:*
  + Identify the _choices_ in your problem $=>$ propositional variables.
  + Express _validity conditions_ using ALO, AMO, EO, implication patterns.
  + Convert to CNF (usually straightforward; use Tseitin if needed).
  + Feed to a SAT solver and interpret the result.
]

The expressiveness of SAT encoding comes from NP-completeness: _any_ polynomially verifiable problem can be encoded.
The efficiency comes from modern solvers: _billions_ of clauses, solved in minutes.


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
    The first algorithm for SAT was proposed by Martin Davis and Hilary Putnam in 1960 @davis1960.

    Satisfiability-preserving simplification rules:
    + *Unit propagation* --- propagate forced assignments.
    + *Pure literal elimination* --- remove variables appearing with one polarity.
    + *Resolution* (variable elimination) --- resolve away a variable.

    The original DP algorithm uses resolution, which can _increase_ formula size. DPLL (1962) replaces resolution with _splitting_ (backtracking search), which is far more practical.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

Hereinafter, formulas are given in *CNF*: a set of clauses, where each clause is a set of literals.

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
  The unit clause $(A)$ forces $A = 1$.
  Remove clauses with $A$; remove $not A$ from the rest:
  $#r($(A or B)$) and #r($(A or not B)$) and (#r($not A$) or B) and (#r($not A$) or not B) and #r($(A)$)$
  Result: $(B) and (not B)$ --- still unsatisfiable.
]

== Pure Literal Rule

#definition[Pure literal][
  A literal $p$ is _pure_ if it appears in the formula only positively or only negatively.
]

Pure literal elimination:
- Assign the pure literal to true.
- Remove all clauses containing it (they are now satisfied).

#example[
  $(A or B) and (A or C) and (B or C)$.
  Literal $A$ is pure (appears only positively).
  Assign $A = 1$, remove clauses containing $A$: result is $(B or C)$.
]

#note[
  Unit propagation is a _forced_ assignment (no choice). Pure literal elimination is a _safe_ assignment (any model can be extended). Both reduce the formula without branching.
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
    DPLL @davis1962 replaces resolution with _splitting_: choose a variable, try both values, recurse.

    DPLL is _complete_: it always terminates and finds a satisfying assignment iff one exists.

    The search forms a _binary decision tree_ where each internal node is a variable choice and leaves are SAT/UNSAT.
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

Model: $nu = {A = 1, B = 0, C = 1}$. Verify: all clauses satisfied.

#note[
  In this example, DPLL found a solution without backtracking. On harder instances (e.g., pigeonhole), it may explore exponentially many branches.
]

== From DPLL to CDCL

DPLL's weakness: *chronological backtracking*.

When a conflict occurs, DPLL backtracks to the _most recent_ decision --- even if that decision was irrelevant to the conflict. This leads to re-exploring huge search spaces.

#columns(2)[
  *DPLL:*
  - Backtrack to the previous decision
  - Undo it, try the other value
  - No "memory" of _why_ the conflict occurred
  - May repeat the same mistake in a different subtree

  #colbreak()

  *CDCL insight:*
  - _Analyze_ the conflict: which decisions caused it?
  - _Learn_ a new clause that prevents the same scenario
  - _Backjump_ to the source of the problem
  - Never make the same mistake again
]

#Block(color: yellow)[
  *Key question:* When a conflict occurs, can we jump back to the _cause_ rather than just the last decision?
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
  DPLL can be formalized as a _transition system_ with rules for unit propagation, decisions, and backtracking @nieuwenhuis2006. This abstract framework extends naturally to CDCL via Learn and Backjump rules.
]


= Conflict-Driven Clause Learning

== Implication Graph

During propagation, each forced assignment has a _reason_ --- the clause that caused it.
The *implication graph* records these dependencies.

#definition[Implication Graph][
  A directed acyclic graph where:
  - *Nodes* are assigned literals (annotated with _decision level_).
  - *Edges* trace the clause that _forced_ each propagated literal.
  - *Decision nodes* have no incoming edges (marked with $square.small.filled$).
  - A *conflict node* $kappa$ is added when a clause becomes empty.
]

#example[
  Suppose at decision level 3 we decide $x_1 = 1$, and this forces propagations:
  - $x_1 = 1$ forces $x_4 = 1$ (via clause $c_1: not x_1 or x_4$).
  - $x_4 = 1$ and prior $x_2 = 1$ force $x_5 = 0$ (via clause $c_2: not x_4 or not x_2 or not x_5$).
  - $x_5 = 0$ and prior $x_3 = 1$ create a _conflict_ (via clause $c_3: x_5 or not x_3$).

  The implication graph shows the chain: $x_1 => x_4 => not x_5 => kappa$, with side edges from prior decisions $x_2, x_3$.
]

== Conflict Analysis

When a conflict occurs, CDCL traces the implication graph backward to find the _root cause_.

#definition[1-UIP (Unique Implication Point)][
  The _1-UIP_ is the last decision-level node on every path from the current decision to the conflict.
  Cut the implication graph at the 1-UIP boundary --- the literals on the _reason side_ (negated) form the *learned clause*.
]

#example[
  From the previous example: the 1-UIP cut at $x_4$ yields the learned clause
  $ (not x_2 or not x_4) $
  This clause prevents the solver from ever simultaneously setting $x_2 = 1$ and $x_4 = 1$ again.
]

The learned clause is added permanently to the clause database --- the solver _remembers_ this conflict.

#Block(color: blue)[
  *Learned clauses are resolution proofs in disguise.* Each learned clause corresponds to a sequence of resolution steps on the original clauses.
]

== Worked CDCL Example

Consider formula $F$ with variables $x_1, dots, x_5$ and clauses:
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
    [$c_1 => x_2 = 1$; \ $c_3 => x_3 = 1$; \ $c_4 => x_4 = 1$; \ $c_5$ conflict: needs $not x_4$ but $x_4 = 1$],
    [#Red[Conflict!]],

    [], [Analyze: learned clause $(x_1)$], [], [Backjump to level 0],
    [0], [Unit prop: $x_1 = 1$], [$c_2 => x_3 = 1$; $c_4 => x_4 = 1$; $c_5$ conflict again], [#Red[Conflict!]],
    [], [Level 0 conflict $=>$ *UNSAT*], [], [],
  )
]

The formula is unsatisfiable. CDCL proved this by learning a clause at level 1 and detecting a conflict at level 0.

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
  *This is the key insight:* Backjumping skips irrelevant search space. Combined with clause learning, CDCL avoids repeating the same mistakes. This is why CDCL solvers outperform DPLL by orders of magnitude on structured problems.
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
- Bump the _activity score_ of variables involved in recent conflicts.
- Periodically decay all scores.
- Always decide the highest-activity variable next.
- Effect: focuses search on the "hard" part of the problem.

*Restarts:*
- Periodically restart the search from scratch, keeping all learned clauses.
- Uses Luby sequence or geometric schedule for restart intervals.
- Effect: avoids getting stuck in unproductive search regions.

*Phase saving:*
- When deciding a variable, use its _last assigned polarity_ as default.
- Effect: quickly reconstructs parts of previous partial solutions.

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
  *Key solvers*:
  - *MiniSat* (Eén & Sörensson, 2003): clean, educational, widely embedded.
  - *CaDiCaL* (Biere): state-of-the-art, incremental, proof logging.
  - *Kissat* (Biere, 2020): competition-optimized, _inprocessing_ techniques.

  #colbreak()

  *SAT Competition* (annual since 2002):
  - *Industrial* track: real-world instances (verification, planning).
  - *Crafted* track: hard combinatorial problems.
  - *Random* track: random $k$-SAT near phase transition.
  - Drives solver improvement; open-source requirement.
]

#Block(color: yellow)[
  *Scale:* modern solvers routinely handle _millions_ of variables and _billions_ of clauses. From NP-complete in theory to practical workhorse --- the gap is bridged by CDCL + smart engineering.
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
  *The pipeline:* Problem $=>$ SAT encoding (ALO/AMO/EO) $=>$ DIMACS CNF $=>$ CDCL solver $=>$ model or UNSAT proof. \
  *Next:* FOL theories and SMT --- extending SAT with richer background knowledge.
]

== Exercises: SAT Encoding

+ Encode the following problem as a SAT instance:
  _Schedule 4 lectures into 3 time slots such that no two lectures with a shared student occur in the same slot._
  Define the variables, ALO/AMO/EO constraints, and conflict constraints.

+ Write a Python script to generate the DIMACS CNF encoding for vertex coloring of a graph with $n$ vertices, $m$ edges, and $k$ colors.
  Test it on the Petersen graph ($n = 10$, $k = 3$).

+ Show that a DNF formula can be converted to an equivalent CNF in exponential size in the worst case, but the Tseitin encoding produces an _equisatisfiable_ CNF of linear size. Why does equisatisfiability (rather than equivalence) suffice for SAT solving?

== Exercises: DPLL

+ Run the DPLL algorithm (with unit propagation) on the formula:
  $(A or B or C) and (not A or B) and (not B or C) and (not C or A) and (not A or not B or not C)$
  Draw the search tree showing all decisions, propagations, and backtracks.

+ Explain why the pure literal rule is _sound_ (preserves satisfiability) but is rarely used in modern solvers.

+ $star$ Consider the pigeonhole formula $"PHP"_4^3$ (4 pigeons, 3 holes). How many nodes does the DPLL search tree have in the worst case? What is the optimal variable ordering?

== Exercises: CDCL

+ Given the following implication graph, identify the 1-UIP and derive the learned clause: \
  Decisions: $x_1 = 1$ (level 1), $x_2 = 0$ (level 2). \
  Propagations: $x_3 = 1$ (from $c_1: not x_1 or x_3$), $x_4 = 1$ (from $c_2: x_2 or x_4$), conflict on $c_3: not x_3 or not x_4$.

+ Explain why a conflict at decision level 0 implies UNSAT.

+ Compare DPLL and CDCL on the formula from Exercise 1 above. Does CDCL learn any useful clauses?

+ $star$ Show that every CDCL execution on an unsatisfiable formula implicitly constructs a _resolution proof_. Explain why this means CDCL can never be worse than tree-like resolution (up to polynomial overhead).

== Bibliography

#bibliography("refs.yml")
