#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Boolean Satisfiability",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

= Boolean Satisfiability

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
  #wrap-it.wrap-content(fig, body, align: top + right)
]

== Cook--Levin Theorem

#theorem[Cook--Levin][
  SAT is NP-complete.

  That is, _any_ problem in NP can be _reduced_ to SAT in polynomial time (using #link("https://en.wikipedia.org/wiki/Many-one_reduction")[many-one reduction]).
]

// TODO: Add a proof sketch.
// TODO: mention Karp
// TODO: define Karp's many-one reduction

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
