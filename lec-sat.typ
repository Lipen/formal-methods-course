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

SAT is a _decision_ problem --- the answer is either "yes" or "no".
In practice, we are mainly interested in _finding_ the actual satisfying assignment if it exists --- this search problem is called _functional_ SAT.

== Cook--Levin Theorem

Historically, SAT was the first problem proven to be NP-complete, independently by Stephen Cook @cook1971 and Leonid Levin @levin1973 in 1971.

#theorem[Cook--Levin][
  SAT is NP-complete.

  That is, SAT is in NP, and _any_ problem in NP can be _reduced_ to SAT in polynomial time.
] <cook-levin>

#[
  #let fig = grid(
    columns: 3,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    image("assets/Stephen_Cook.jpg", height: 3cm),
    image("assets/Leonid_Levin.jpg", height: 3cm),
    image("assets/Richard_Karp.jpg", height: 3cm),

    [Stephen Cook], [Leonid Levin], [Richard Karp],
  )
  #let body = [
    Cook's original proof was based on the concept of _Turing reductions_ (now called _Cook reductions_).
    Richard Karp @karp1972 later refined this with a stronger concept of polynomial-time _many-one reductions_ (now known as _Karp reductions_), establishing the modern framework for NP-completeness.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

== Karp Reduction

#definition[Many-one reduction #h(1pt, weak: true)#href("https://en.wikipedia.org/wiki/Many-one_reduction")#h(1pt, weak: true)][
  A polynomial-time _many-one reduction_ from problem $A$ to~$B$, denoted $A scripts(lt.eq)_p B$, is a polynomial-time computable function $f$ such that for every instance $x$ of $A$, $x$ is a "yes" instance of $A$ if and only if $f(x)$ is a "yes" instance of $B$.

  A reduction of this kind is also called a _polynomial transformation_ or _Karp reduction_.
]

== Proving the Cook--Levin Theorem

#proof[(SAT $in$ NP)][
  A satisfying assignment serves as a _certificate_ verifiable in linear time.
]

#proof[of @cook-levin][
  _Any problem in NP can be reduced to SAT in polynomial time._

  A problem $L$ is in NP if there exists a polynomial-time _verifier_ (Turing machine) $V(x, c)$ that checks whether $c$ is a valid certificate for $x in L$.

  A _Karp reduction_ from $L$ to SAT is a polynomial-time computable function mapping instances $x$ of $L$ to propositional formulas $phi_x$, such that $phi_x$ is satisfiable iff $x in L$.

  Construct a formula $phi_x$ encoding the computation of $V(x, c)$ for input $x$ and certificate $c$.
  - Variables encode the Turing machine state, tape cells, and head position at each step $t$.
  - Clauses enforce the initial configuration (fixed input $x$, free variables for certificate $c$), valid transitions (per $V$'s rules), and acceptance at step $T in cal(O)(p(abs(x)))$.
  A satisfying assignment to $phi_x$ corresponds to a valid certificate $c$ causing $V(x, c)$ to accept, thus $x in L$.
]

#underline[
  This foundational result shows that SAT is a "universal" problem for NP.
]

== Solving General Search Problems with SAT

SAT solvers are powerful tools for solving general search problems.
Given a problem, we can encode it as a SAT instance and use a SAT solver to find a solution.

To model a search problem as a SAT instance, the general approach is as follows:
+ Define propositional variables to represent the problem's _state_.

+ Encode the problem's _constraints_ using propositional formulas.

+ Translate the formulas into a _clausal form_ using the Tseitin transformations.

+ Run a SAT solver to find a satisfying assignment or prove its non-existence.

== Example: Graph Coloring

Graph $G = (V,E)$ consists of a set $V$ of vertices and a set $E$ of edges, where each edge is an unordered pair of vertices.
A complete graph on $n$ vertices, denoted $K_n$, is a graph with $abs(V) = n$ such that $E$ contains all possible pairs of vertices.
In total, $K_n$ has $n(n-1)/2$ edges.

Given a graph, color its vertices such that no two adjacent vertices have the same color.

Given a complete graph $K_n$, color its edges using $k$ colors without creating a monochromatic triangle.
What is the largest complete graph for which this is possible for a given number of colors?#footnote[
  For a more general case, see #link("https://en.wikipedia.org/wiki/Ramsey's_theorem")[Ramsey's theorem]
]
- For $k = 1$, the answer is $n = 2$.
  - The graph $K_2$ has only one edge, which can be colored with a single color.
- For $k = 2$, the answer is $n = 5$.
  - See the example of 2-colored $K_5$ on the right.
- For $k = 3$, the answer is $n = 16$.
  - This is the work for a SAT solver. See the next slides.

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

+ _Describe states using propositional variables._
  - A simple (_one-hot_, or _direct_) encoding uses three (as $k = 3$) variables for each edge: $e_1$, $e_2$, and $e_3$.
    There are $2^3 = 8$ possible combinations of values of three variables, but only 3 of them are _valid_.

+ _Describe constrains using propositional formulas._
  - Each edge must be colored with exactly one color.
    For each edge $e$:
    $ (e_1 or e_2 or e_3) and not (e_1 and e_2) and not (e_1 and e_3) and not (e_2 and e_3) $
  - No monochromatic triangles are allowed.
    For each triangle $(e,f,g)$:
    $ not (e_1 and f_1 and g_1) and not (e_2 and f_2 and g_2) and not (e_3 and f_3 and g_3) $

+ _Translate the formula into a clausal form._

+ _Run a SAT solver to find a satisfying assignment or prove its non-existence._

Now, perform this process for increasing values of $n$, and find the largest $n$ for which the formula is satisfiable.
The answer is $n = 16$ for $k = 3$.

== TODO

#show: cheq.checklist
- [ ] Encodings
- [ ] SAT Solvers
- [ ] Applications
- [ ] Exercises

== Bibliography
#bibliography("refs.yml")
