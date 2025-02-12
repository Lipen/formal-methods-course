#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "SAT",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

= Foundations

== Literals

#definition([Literal])[
  A _literal_ is a propositional variable or its negation.
  - $p$ is a _positive literal_.
  - $not p$ is a _negative literal_.
]

#definition([Complement])[
  The _complement_ of a literal $p$ is denoted by $overline(p)$.
  $
    overline(p) = cases(
      not p "if" p "is positive",
      p "if" p "is negative"
    )
  $

  Note: _complementary_ literals $p$ and $overline(p)$ are each other's completement.
]

== Conjunctive Normal Form

#definition([Clause])[
  A _clause_ is a disjunction of literals.
  - An _empty clause_ is a clause with no literals, commonly denoted by $square$.
  - A _unit clause_ is a clause with a single literal.
  - A _Horn clause_ is a clause with at most one positive literal.

  Note: $square$ is _false in every interpretation_, that is, unsatisfiable.
]

#definition([Conjunctive Normal Form (CNF)])[
  A formula is said to be in _conjunctive normal form_ if it is a conjunction of clauses.
  $
    A = and.big_i or.big_j p_(i j)
  $
  #example[
    $A = (not p or q) and (not p or q or r) and p and (not q or not r)$
  ]
]

== Satisfiability on CNF

An interpretation $nu$ satisfies a clause $C = p_1 or dots or p_n$ if it satisfies some (at least one) literal $p_k$ in $C$.

An interpretation $nu$ satisfies a CNF formula $A = C_1 and dots and C_n$ if it satisfies every clause $C_i$ in $A$.

A CNF formula $A$ is _satisfiable_ if there exists an interpretation $nu$ that satisfies $A$.

== CNF Transformation

Any propositional formula can be converted to CNF by the repeated application of these rewriting rules:
+ $(A implies B) arrow.double.long (not A or B)$
+ $(A iff B) arrow.double.long (not A or B) and (A or not B)$
+ $(A xor B) arrow.double.long (A or B) and (not A or not B)$
+ $not (A and B) arrow.double.long (not A or not B)$
+ $not (A or B) arrow.double.long not A and not B$
+ $not not A arrow.double.long A$
+ $(A_1 and dots and A_n) or (B_1 and dots and B_m) arrow.double.long (A_1 or B_1 and dots and B_m) and dots and (A_n or B_1 and dots and B_m)$

#theorem[
  If $A'$ is obtained from a formula $A$ by applying the CNF conversion rules, then $A' equiv A$.
]

== Problem with Exponential Blowup

Let's convert the following formula to CNF...
$
  F = & p_1 iff (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6)))) arrow.double.long \
  = & (not p_1 or (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))) and \
  & (p_1 or not (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))) arrow.double.long \
  = & (not p_1 or (not p_2 or (p_3 iff (p_4 iff (p_5 iff p_6))))) and \
  & (not p_1 or (p_2 or not (p_3 iff (p_4 iff (p_5 iff p_6))))) and \
  & (p_1 or not (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))) arrow.double.long dots \
$

If we continue, the formula will _grow exponentially large_!
The CNF of $F$ consists of $2^5 = 32$ clauses.

There are formulas for which the minimum CNF has an exponential size.

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
  The resulting formula is, in general, *not equivalent* to the original one, but it is _equisatisfiable_, i.e., it is _satisfiable_ iff the original formula is satisfiable.
]

== Equisatisfiability

#definition([Equisatisfiability])[
  Two formulas $A$ and $B$ are _equisatisfiable_ if $A$ is satisfiable _if and only if_ $B$ is satisfiable.
]

The set $S$ of clauses obtained by the Tseitin transformation is _equisatisfiable_ with the original formula $F$.
- Every model of $S$ is a model of $F$.
- Every model of $F$ can be extended to a model of $S$ by assigning the values of fresh variables according to their definitions.

== Avoiding the Exponential Blowup

#example[
  $F = p_1 iff (p_2 iff (p_3 iff (p_4 iff (p_5 iff p_6))))$

  Applying the Tseitin transformation gives us:
  $
    S = & p_1 iff (p_2 iff n_3) and \
    & n_3 iff (p_3 iff n_4) and \
    & n_4 iff (p_4 iff n_5) and \
    & n_5 iff (p_5 iff p_6)
  $

  The equivalent CNF of $F$ consists of $2^5 = 32$ clauses.

  The equisatisfiable CNF of $F$ consists of $16$ clauses, yet introduces $3$ fresh variables.
]

== Clausal Form

#definition([Clausal Form])[
  A _clausal form_ of a formula $F$ is a set $S_F$ of clauses which is satisfiable iff $F$ is satisfiable.

  A clausal form of a _set_ of formulas $F'$ is a set $S'$ of clauses which is satisfiable iff $F'$ is satisfiable.

  Even stronger requirement:
  - $F$ and $S_F$ have the same models in the language of $F$.
  - $F'$ and $S'$ have the same models in the language of $F'$.
]

The main advantage of the clausal form over the CNF is that we can convert any formula into a set of clauses in _almost linear time_.
+ If $F$ is a formula which has the form $C_1 and dots and C_n$, where $n > 0$ and each $C_i$ is a clause, then its clausal form is $S eq.def {C_1, dots, C_n}$.
+ Otherwise, apply Tseitin transformation: introduce a name for each subformula $A$ of $F$ such that $B$ is not a literal and use this name instead of a subformula.

= SAT Problem

== Boolean Satisfiability Problem (SAT)

SAT is the classical NP-complete problem of determining whether a given Boolean formula is _satisfiable_, that is, whether there exists an assignment of truth values to its variables that makes the formula true.
$
  exists X . f(X) = 1
$

SAT is a _decision_ problem, which means that the answer is either "yes" or "no".
However, in practice, we are mainly interested in _finding_ the actual satisfying assignment if it exists --- this is a _functional_ SAT problem.

#[
  #let fig = grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    image("assets/Stephen_Cook.jpg", height: 3cm), image("assets/Leonid_Levin.jpg", height: 3cm),
    [Stephen Cook], [Leonid Levin],
  )
  #let body = [
    Historically, SAT was the first problem proven to be NP-complete, independently by Stephen Cook @cook1971 and Leonid Levin @levin1973 in 1971.
  ]

  #import "@preview/wrap-it:0.1.0": wrap-content
  #wrap-content(fig, body, align: top + right)
]

== Cook--Levin Theorem

#theorem([Cook--Levin])[
  SAT is NP-complete.

  That is, any problem in NP can be _reduced_ to SAT in polynomial time, using #link("https://en.wikipedia.org/wiki/Many-one_reduction")[many-one reductions].
]

== Solving General Search Problems with SAT

Modelling and solving general search problems:
+ Define a finite set of possible _states_.
+ Describe states using propositional _variables_.
+ Describe _legal_ and _illegal_ states using propositional _formulas_.
+ Construct a propositional _formula_ describing the desired state.
+ Translate the formula into an _equisatisfiable_ CNF formula.
+ If the formula is _satisfiable_, the satisfying assignment corresponds to the desired state.
+ If the formula is _unsatisfiable_, the desired state does not exist.

== Example: Graph Coloring

Recall that a graph $G = (V,E)$ consists of a set $V$ of vertices and a set $E$ of edges, where each edge is an unordered pair of vertices.

A complete graph on $n$ vertices, denoted $K_n$, is a graph with $abs(V) = n$ such that $E$ contains all possible pairs of vertices.
In total, $K_n$ has $n(n-1)/2$ edges.

Given a graph, color its vertices such that no two adjacent vertices have the same color.

Given a complete graph $K_n$, color its edges using $k$ colors without creating a monochromatic triangle.
What is the largest complete graph for which this is possible for a given number of colors?
- For $k = 1$, the answer is $n = 2$.
  - The graph $K_2$ has only one edge, which can be colored with a single color.
- For $k = 2$, the answer is $n = 5$.
- For $k = 3$, the answer is $n = 16$.

#place(bottom + right)[
  #diagraph.raw-render(
    ```
    graph {
      rankdir=LR;
      node [shape=circle fixedsize=shape width=.3];
      1 -- 2 -- 3 -- 4 -- 5 -- 1 [color=red penwidth=3 weight=10];
      1 -- 3;
      1 -- 4;
      2 -- 4;
      2 -- 5;
      3 -- 5;
    }
    ```,
    engine: "fdp",
  )
]

== Modelling and Solving the Graph Coloring Example

+ _Define a finite set of possible states._
  - Each possible edge coloring is a state.
    There are $3^abs(E)$ possible states.

+ _Describe states using propositional variables._
  - A simple (_one-hot_, or _direct_) encoding uses three variables for each edge: $e_1$, $e_2$, and $e_3$.
    There are 8 possible combinations of values of three variables, which given a state space of $8^abs(E)$.
    This is larger than necessary, but keeps the encoding simple.

+ _Describe legal and illegal states using propositional formulas._
  - For each edge $e in E$, the formula $e_1 + e_2 + e_3 = 1$ (so called "cardinality constraint") ensures that each edge is colored with exactly one color.
    This reduces the state space to $3^abs(E)$.

+ _Construct a propositional formula describing the desired state._
  - The desired state is one in which there are no monochromatic triangles.
    For each triangle $(e,f,g)$, we explicitly forbid it from being colored with the same color:
    $ not ((e_1 iff f_1) and (f_1 iff g_1) and (e_2 iff f_2) and (f_2 iff g_2) and (e_3 iff f_3) and (f_3 iff g_3)) $

+ _Translate the formula into an equisatisfiable CNF formula._
  - This can be done using the Tseitin transformations.

+ _If the formula is satisfiable, the satisfying assignment corresponds to the desired state._
  - The satisfying assignment corresponds to a valid edge coloring.
    Among variables $e_1$, $e_2$, and $e_3$, the single one with the value of 1 corresponds to the color of the edge.

+ _If the formula is unsatisfiable, the desired state does not exist._
  - If the formula is unsatisfiable, there is no valid edge coloring.

Now, run a SAT solver for increasing values of $n$, and find the largest $n$ for which the formula is satisfiable.
The answer is $n = 16$ for $k = 3$.

== TODO

#show: cheq.checklist
- [ ] Encodings
- [ ] SAT Solvers
- [ ] Applications
- [ ] Exercises

== Bibliography

#bibliography("refs.yml")
