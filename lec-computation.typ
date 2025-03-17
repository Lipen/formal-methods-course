#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Theory of Computation",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#let yields = $scripts(arrow.double)$
#let tapestart = box(baseline: 1pt)[$triangle.small.r$]

= Languages

== Formal Languages

#definition[Formal language][
  A set of strings over an alphabet $Sigma$, closed under concatenation.
]

#place(right)[
  #grid(
    columns: 1,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Noam_Chomsky", image("assets/Noam_Chomsky.jpg", height: 3cm)),
    [Noam Chomsky],
  )
]

Formal languages are classified by _Chomsky hierarchy_:
- Type 0: Recursively Enumerable
- Type 1: Context-Sensitive
- Type 2: Context-Free
- Type 3: Regular

#v(1.5cm, weak: true)
_Examples_:
- $L = { a^n | n geq 0 }$
- $L = { a^n b^n | n geq 0 }$
- $L = { a^n b^n c^n | n geq 0 }$
- $L = { angle.l M, w angle.r | M "is a TM that halts on input" w }$

#place(horizon + center, dx: 1em, dy: 1em)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (1, .5))
    circle((0, 0.5), radius: (1.5, 1))
    circle((0, 1), radius: (2.2, 1.5))
    circle((0, 1.6), radius: (3.2, 2.1))
    content((0, 0))[Regular]
    content((0, 0.9))[Context-Free]
    content((0, 1.9))[Context-Sensitive]
    content((0, 2.9))[Recursively Enumerable]
  })
]

== Decision Problems as Languages

#definition[Decision problem][
  A _decision problem_ is a question with a "yes" or "no" answer.

  Formally, the set of inputs for which the problem has an answer "yes" corresponds to a subset $L subset.eq Sigma^ast$, where $Sigma$ is an alphabet.
]

#example[
  SAT Problem as a language: \
  $ "SAT" = { phi | phi "is a satisfiable Boolean formula" } $
]
#example[
  Validity Problem as a language: \
  $ "VALID" = { phi | phi "is a valid logical formula (tautology)" } $
]
#example[
  Halting Problem as a language: \
  $ "HALT" = { angle.l M, w angle.r | "Turing machine" M "halts on input" w } $
]

== Language Classes

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (0.8, 0.4))
    circle((0, 0.4), radius: (1.4, 0.8))
    circle((0, 0.8), radius: (2, 1.2))
    circle((0, 1.2), radius: (2.6, 1.6))
    circle((0, 2.4), radius: (4, 2.8), stroke: blue)
    circle((0, 1.2), radius: (4, 2.8), stroke: red)
    // rect((-5, -1.5), (5, 6))
    content((0, 0))[Finite]
    content((0, .7))[Regular]
    content((0, 1.55))[Context-Free]
    content((0, 2.3))[Context-Sensitive]
    content((0, 3.2))[#set text(fill: purple); Decidable = $"RE" intersect "co-RE"$]
    content((0, 4.4))[#set text(fill: blue); Recursively Enumerable (RE)]
    content((0, -1))[#set text(fill: red); co-RE]
    circle((2.5, 2.5), radius: 3pt, fill: yellow)
    content((2.5, 2.5), anchor: "north-west", padding: 5pt)[SAT]
    circle((3.2, 3.8), radius: 3pt, fill: yellow)
    content((3.2, 3.8), anchor: "south-west", padding: 5pt)[HALT]
    circle((2.8, 5), radius: 3pt, fill: yellow)
    content((2.8, 5), anchor: "south-west", padding: 5pt)[REGULAR]
    // content((0, 6), anchor: "north", padding: 5pt)[All languages]
  })
]

= Machines

== Finite Automata

#definition[
  Deterministic Finite Automaton (DFA) is a 5-tuple $(Q, Sigma, delta, q_0, F)$ where:
  - $Q$ is a _finite_ set of states,
  - $Sigma$ is an _alphabet_ (finite set of input symbols),
  - $delta: Q times Sigma to Q$ is a _transition function_,
  - $q_0 in Q$ is the _start_ state,
  - $F subset.eq Q$ is a set of _accepting_ states.

  DFA recognizes _regular_ languages (Type 3).
]

#example[
  Automaton $cal(A)$ recognizing strings with an even number of 0s, $cal(L)(cal(A)) = { 0^n | n "is even" }$.

  #let aut = (
    q0: (q1: (0, 1)),
    q1: (q0: 0, q1: 1),
  )
  #grid(
    columns: 2,
    column-gutter: 2em,
    finite.transition-table(aut),
    box(
      height: 0pt,
      finite.automaton(
        aut,
        final: ("q0",),
        style: (
          state: (radius: 0.5, extrude: 0.8),
          transition: (curve: 0.6),
          q1-q1: (anchor: top + right),
        ),
      ),
    ),
  )
]

== Turing Machines

Informally, a Turing machine is a _finite-state_ machine with an _infinite tape_ and a _head_ that can read and write symbols.
Initially, the tape contains the _input_ string, the rest are blanks, and the machine is in the _start_ state.
At each step, the machine reads the symbol under the head, changes the state, writes a new symbol, and moves the head left or right.
When the machine reaches the _accept_ or _reject_ state, it immediately halts.

#note[
  If the machine never reaches the _accept_ or _reject_ state, it _loops_ forever.
]

#v(1em)
#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    node-corner-radius: 2pt,
    edge-stroke: 1pt,
    mark-scale: 70%,

    blob((0, 0), [Input], tint: blue, name: <input>),
    blob((1, 0), [Turing \ machine], tint: purple, name: <tm>),
    blob((2, -0.5), [Accept], tint: green, name: <accept>),
    blob((2, 0), [Loop], tint: yellow, name: <loop>),
    blob((2, 0.5), [Reject], tint: red, name: <reject>),

    edge(<input>, <tm>, "-|>"),
    edge(<tm>, <accept>, "-|>"),
    edge(<tm>, <loop>, "-|>"),
    edge(<tm>, <reject>, "-|>"),

    render: (grid, nodes, edges, options) => {
      // cetz is also exported as fletcher.cetz
      cetz.canvas({
        // this is the default code to render the diagram
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

        let n-accept = fletcher.find-node(nodes, <accept>)
        let n-loop = fletcher.find-node(nodes, <loop>)
        let n-reject = fletcher.find-node(nodes, <reject>)

        fletcher.get-node-anchor(
          n-accept,
          0deg,
          pa => {
            fletcher.get-node-anchor(
              n-loop,
              0deg,
              pl => {
                fletcher.get-node-anchor(
                  n-reject,
                  0deg,
                  pr => {
                    cetz.decorations.brace((rel: (1pt, 5pt), to: pa), (rel: (1pt, 5pt), to: pl), name: "b1")
                    cetz.decorations.brace((rel: (1pt, -5pt), to: pl), (rel: (1pt, -5pt), to: pr), name: "b2")
                  },
                )
              },
            )
          },
        )

        cetz.draw.content("b1.content", anchor: "west")[Does not reject]
        cetz.draw.content("b2.content", anchor: "west")[Does not accept]
      })
    },
  )
]

== TM Formal Definition

#definition[
  Turing Machine (TM) is a 7-tuple $(Q, Sigma, Gamma, delta, q_0, q_"acc", q_"rej")$ where:
  - $Gamma$ is a _tape alphabet_ (including blank symbol $square in Gamma$),
  - $Sigma subset.eq Gamma$ is a _input alphabet_,
  - $delta: Q times Gamma to Q times Gamma times {L, R}$ is a transition function,
  - $q_"acc"$ and $q_"rej"$ are the _accept_ and _reject_ states.

  TM recognizes _recursively enumerable_ languages (Type 0).
]

== TM Language

#definition[
  The language _recognized_ by a TM $M$, denoted $cal(L)(M)$, is the set of strings $w in Sigma^*$ that $M$ accepts, that is, for which $M$ halts in the _accept_ state.

  - For any $w in cal(L)(M)$, $M$ accepts $w$.
  - For any $w notin cal(L)(M)$, $M$ does not accept $w$, that is, $M$ either _rejects_ $w$ or _loops forever_ on $w$.
]

#definition[
  A TM is a _decider_ if it halts on all inputs.
]

== TM Configuration

#let tm-head(pos, state, name: none, ..style) = {
  import cetz.draw: *
  group(
    name: name,
    {
      let lu = (rel: (-1, -0.5), to: pos)
      let ld = (rel: (0, -0.8), to: lu)
      let ru = (rel: (1, -0.5), to: pos)
      let rd = (rel: (0, -0.8), to: ru)
      anchor("state", (rel: (0, -0.7), to: pos))
      content("state", state)
      line(pos, lu, ld, rd, ru, ..style, close: true)
    },
  )
}

#definition[
  A _configuration_ of a TM is a _string_ $(u ; q ; v)$ where $u,v in Gamma^*$, $q in Q$, meaning:
  - Tape contents: $u v$ followed by the blanks.
  - Current state is $q$.
  - Head position: at the first symbol of $v$.

  For example, configuration $(u ; q ; a v)$, where $a in Gamma$, is represented as follows:
  #cetz.canvas({
    import cetz.draw: *
    scale(50%)
    content((-0.5, 0.5))[$tapestart$]
    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((3, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    tm-head((rel: (0, -1pt), to: "a.south"))[$q$]
    line((0, 0), (5.5, 0))
    line((0, 1), (5.5, 1))
  })
]

== TM Computation

#definition[Computation][
  The process of _computation_ by a TM on input $w in Sigma^*$ is a _sequence_ of configurations $C_1, C_2, dots, C_n$.
  - $C_1 = (tapestart; q_0; w)$ is the _start_ configuration with input $w in Sigma^*$.
  - $C_i yields C_(i+1)$ for each $i$.
  - $C_n$ is a _final_ configuration.
]

Configuration $C_1$ _yields_ $C_2$, denoted $C_1 yields C_2$, if TM can move from $C_1$ to $C_2$ in _one_ step.
- See the formal definition on the next slide.

The relation $yields^*$ is the _reflexive_ and _transitive_ closure of $yields$.
- $C_1 yields^* C_2$ denotes "yields in _some_ number of steps".

== TM Yields Relation

#definition[Yields][
  Let $u,v in Gamma^*$, $a,b,c in Gamma$, $q_i, q_j in Q$.
  - Move left: $(u a ; q_i ; b v) yields (u ; q_j ; a c v)$ if $delta(q_i, b) = (q_j, c, L)$ (overwrite $b$ with $c$, move left)
  - Move right: $(u ; q_i ; b a v) yields (u c ; q_j ; a v)$ if $delta(q_i, b) = (q_j, c, R)$ (overwrite $b$ with $c$, move right)

  #cetz.canvas({
    import cetz.draw: *
    scale(50%)

    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((3, 0), (rel: (1, 1)), name: "b")
    content("b.center")[$b$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "b.south"))[$q_i$]

    translate(x: 8)
    content((-1, -0.4))[$limits(yields)_(delta(q_i, b) = (q_j, c, L))$]

    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((3, 0), (rel: (1, 1)), name: "c")
    content("c.center")[$c$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "a.south"))[$q_j$]

    translate(x: 9)

    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "b")
    content("b.center")[$b$]
    rect((3, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "b.south"))[$q_i$]

    translate(x: 8)
    content((-1, -0.4))[$limits(yields)_(delta(q_i, b) = (q_j, c, R))$]

    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "c")
    content("c.center")[$c$]
    rect((3, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "a.south"))[$q_j$]
  })

  Special case for the left end:
  - $(tapestart ; q_i ; b v) yields (tapestart ; q_j ; c v)$ if $delta(q_i, b) = (q_j, c, L)$ (overwrite $b$ with $c$, do not move).
]

== Recognizing vs Deciding

There are _two_ types of Turing machines:
+ Total TM: always halts. Also called _decider_.
+ General TM: may loop forever. Also called _recognizer_.

#definition[Recognition][
  A TM _recognizes_ a language $L$, if it halts and accepts all words $w in L$, but no others.
  A language recognized by a TM is called _semi-decidable_ or _recursively enumerable_ or _recursively computable_ or _Turing-recognizable_.
  The set of all recognizable languages is denoted by *RE*.
]

#definition[Decision][
  A TM _decides_ a language $L$, if it halts and accepts all words $w in L$, and halts and rejects any other word $w notin L$.
  A language decided by a TM is called _decidable_ or _recursive_ or _computable_.
  The set of all decidable languages is denoted by *R*.
]

== MIU. MU?

#definition[MIU system][
  The _MIU system_ is a "formal system" consisting of:
  - an alphabet $Sigma = { #`M`, #`I`, #`U` }$,
  - a single axiom: `MI`,
  - a set of inference rules:
    #table(
      columns: 3,
      column-gutter: 1em,
      stroke: (x, y) => if y == 0 { (bottom: .4pt) },
      table.header[*Rule*][*Description*][*Example*],
      [$x#`I` entails x#`IU`$], [add `U` to the end of any string ending with `I`], [`MI` to `MIU`],
      [$#`M`x entails #`M`x x$], [double the string after $M$], [`MIU` to `MIUIU`],
      [$x#`III`y entails x#`U`y$], [replace any `III` with `U`], [`MUIIIU` to `MUUU`],
      [$x#`UU`y entails x y$], [remove any $U U$], [`MUUU` to `MU`],
    )

  *Question*: Is `MU` a theorem of the MIU system?
]

= Complexity

== P and NP

#definition[
  Class $P$ consists of problems that can be _solved_ in _polynomial time_.

  Equivalently, $L in P$ iff $L$ is _decidable_ in polynomial time by a _deterministic_ TM.
]
#examples[
  Shortest path, primality testing (AKS algorithm), linear programming.
]

#definition[
  Class NP consists of problems where a _certificate_ of a solution ("yes" answer) can be _verified_ in polynomial time.

  Equivalently, $L in "NP"$ iff $L$ is _decidable_ in polynomial time by a _non-deterministic_ TM.

  Equivalently, $L in "NP"$ iff $L$ is _recognizable_ in polynomial time by a _deterministic_ TM.
]
#examples[
  SAT, graph coloring, graph isomorphism, subset sum, knapsack, vertex cover, clique.
]

== NP-Hard and NP-Complete

#definition[
  A problem $H$ is _NP-hard_ if every problem $L in "NP"$ is polynomial-time _reducible_ to $H$.
]
#examples[
  Halting problem (undecidable), Traveling Salesman Problem (TSP).
]

#definition[
  A problem $H$ is _NP-complete_ if:
  1. $H in "NP"$
  2. $H$ is NP-hard
]
#examples[
  SAT, 3-SAT, Hamiltonian path...
  Actually, almost all NP problems are NP-complete!
]

#theorem[Cook--Levin][
  SAT is NP-complete.
]

== co-NP

#definition[
  Complexity class $"co-NP"$ contains problems where _"no"_ instances can be _verified_ in _polynomial time_.

  Equivalently, $L in "co-NP"$ iff the complement of $L$ is in $"NP"$:
  $ "co-NP" = { L | overline(L) in "NP" } $
]

_Open question_: $"NP" eq.quest "co-NP"$? Implies $"P" neq "NP"$ if false.

#examples[
  - *VALID*: Check if a Boolean formula is always true (tautology).
  - *UNSAT*: Check if a formula has no satisfying assignment.
]

== Computational Hierarchy

#place(top + right)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (0.5, 0.5))
    circle((0.5, 0), radius: (1, 0.7))
    circle((1.5, 0), radius: (2, 1.1))
    circle((2, 0), radius: (2.5, 1.3))
    circle((2.5, 0), radius: (3, 1.5))
    circle((3, 0), radius: (3.5, 1.7))
    content((0, 0))[P]
    content((1, 0))[NP]
    content((2.5, 0))[PSPACE]
    content((4, 0))[EXP]
    content((5, 0))[R]
    content((6, 0))[RE]
  })
]

$"P" subset.eq "NP" subset.eq "PSPACE" subset.eq "EXP" subset "R" subset "RE"$

- *RE* \
  Languages _accepted_ (_recognized_) by any TM.

- *R* = RE $intersect$ co-RE \
  Languages _decided_ by any TM (always halt).

- *EXP* \
  Languages _decided_ by a _deterministic_ TM in _exponential time_.

- *PSPACE* \
  Languages _decided_ by a _deterministic_ TM in _polynomial space_.

- *NP* \
  Languages _accepted_ (_recognized_) by any TM, or _decided_ by a _non-deterministic_ TM, in _polynomial time_.

- *P* \
  Languages _decided_ by a _deterministic_ TM in _polynomial time_.

== Complexity Zoo

TODO

See also: https://complexityzoo.net/Petting_Zoo

= Computability

== Computable Functions

#definition[Church--Turing thesis][
  _Computable functions_ are exactly the functions that can be calculated using a mechanical (that is, automatic) calculation device given unlimited amounts of time and storage space.

  // Any algorithmically solvable problem can be computed by a Turing machine.
]

#quote[
  _Every model of computation that has ever been imagined can compute _only_ computable functions, and _all_ computable functions can be computed by any of several _models of computation_ that are apparently very different, such as Turing machines, register machines, lambda calculus and general recursive functions._
]

#definition[Computable function][
  A partial function $f : NN^k arrow.hook NN$ is _computable_ ("can be calculated") if there exists a computer program with the following properties:
  - If $f(x)$ is defined, then the program terminates on the input $x$ with the value $f(x)$ stored in memory.
  - If $f(x)$ is undefined, then the program never terminates on the input $x$.
]

== Effective Procedures

#definition[Effective procedure][
  An _effective procedure_ is a finite, deterministic, mechanical algorithm that guarantees to terminate and produce the correct answer in a finite number of steps.

  An algorithm (set of instructions) is called an _effective procedure_ if it:
  - Consists of _exact_, finite steps.
  - Always _terminates_ in finite time.
  - Produces the _correct_ answer for given inputs.
  - Requires no external assistance to execute.
  - Can be performed _manually_, with pencil and paper.
]

#definition[
  A function is _computable_ if there exists an effective procedure that computes it.
]

== Examples of Computable Functions

_Examples:_
- The function $f(x) = x^2$ is computable.
- The function $f(x) = x!$ is computable.
- The function $f(n) =$ "$n$-th prime number" is computable.
- The function $f(n) =$ "the $n$-th digit of $pi$" is computable.
- The Ackermann function is computable.
- The function that answers the question "Does God exist?" is computable.
- If the Collatz conjecture is true, the stopping time (number of steps to reach 1) of any $n$ is computable.

= Decidability

== Decidable Sets

#definition[Decidable set][
  Given a universal set $cal(U)$, a set $S subset.eq cal(U)$ is _decidable_ (or _computable_, or~_recursive_) if there exists a computable function $f : cal(U) to {0,1}$ such that $f(x) = 1$ iff $x in S$.
]

#example(title: [Examples])[
  - The set of all WFFs is decidable.
    - _We can check if a given string is well-formed by recursively verifying the syntax rules._

  - For a given finite set $Gamma$ of WFFs, the set ${alpha | Gamma models alpha}$ of all tautological consequences of $Gamma$ is decidable.
    - _We can decide $Gamma models alpha$ using a truth table algorithm by enumerating all possible interpretations (at~most~$2^abs(Gamma)$) and checking if each satisfies all formulas in $Gamma$._

  - The set of all tautologies is decidable. \
    - _It is the set of all tautological consequences of the empty set._
]

== Undecidable Sets

#definition[Undecidable set][
  A set $S$ is _undecidable_ if it is not decidable.
]

#example[
  The existence of _undecidable_ sets of expressions can be shown as follows.

  An algorithm is completely determined by its _finite_ description.
  Thus, there are only _countably many_ effective procedures.
  But there are uncountably many sets of expressions.
  (Why? The set of expressions is countably infinite. Therefore, its power set is uncountable.)
  Hence, there are _more_ sets of expressions than there are possible effective procedures.
]

= Undecidability

== Halting Problem

#definition[Halting problem #href("https://en.wikipedia.org/wiki/Halting_problem")][
  Given a program and an input, determine whether the program _halts_ (stops after a finite time) on that input or _loops_ forever.
]

#theorem[Turing][
  The halting problem is undecidable.
]

#proof[sketch][
  Suppose there exists a procedure $H$ that decides the halting problem.
  We can construct a program $P$ that takes itself as input and runs $H$ on it.
  If $H$ says that $P$ halts, then $P$ enters an infinite loop.
  If $H$ says that $P$ does not halt, then $P$ halts.
  This leads to a contradiction, proving that $H$ cannot exist.
]

== Halting Problem Pseudocode

#shadowed.shadowed(inset: 5pt, radius: 5pt)[
  ```py
  def halts(P, x) -> bool:
    """
    Returns True if program P halts on input x.
    Returns False if P loops forever.
    """

  def self_halts(P):
    if halts(P, P):
      while True: # loop forever
    else:
      return # halt
  ```
]

Observe that ```py halts(self_halts, self_halts)``` cannot return neither ```py True``` nor ```py False```. *Contradition!*

Thus, the `halts` _does not exist_ (cannot be implemented), and thus the halting problem is _undecidable_.

== Post Correspondence Problem

#definition[Post correspondence problem #href("https://en.wikipedia.org/wiki/Post_correspondence_problem")][
  Given two finite lists $a_1, dots, a_n$ and $b_1, dots, b_n$ of strings (over the alphabet with at least two symbols), determine whether there exists a sequence of indices $i_1, dots, i_k$, such that $a_(i_1) dots med a_(i_k) = b_(i_1) dots med b_(i_k)$.
]

#example[
  Let $A = [a, a b, b b a]$, $B = [b a a, a a, b b]$.
  A solution is $(3, 2, 3, 1)$:
  $
    a_3 a_2 a_3 a_1 = b b a dot a b dot b b a dot a = b b a a b b b a a = b b dot a a dot b b dot b a a = b_3 b_2 b_3 b_1
  $
]

An alternative formulation of PCP is a collection of _dominoes_, each with a _top_ and a _bottom_ half, with an unlimited supply of each block, and the goal is to find a sequence of blocks such that the string formed by the _top_ halves is equal to the string formed by the _bottom_ halves.

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    let w = 1
    let h = 0.6
    let gap = 0.2

    stroke(0.8pt)

    rect((0, h), (rel: (w, h)), name: "t1")
    content("t1.center")[$b b a$]
    rect((0, 0), (rel: (w, h)), name: "b1")
    content("b1.center")[$b b$]
    content((w / 2, -0.2), anchor: "north")[#set text(size: 0.8em); $i_1 = 3$]

    translate(x: w + gap)
    rect((0, h), (rel: (w, h)), name: "t2")
    content("t2.center")[$a b$]
    rect((0, 0), (rel: (w, h)), name: "b2")
    content("b2.center")[$a a$]
    content((w / 2, -0.2), anchor: "north")[#set text(size: 0.8em); $i_2 = 2$]

    translate(x: w + gap)
    rect((0, h), (rel: (w, h)), name: "t3")
    content("t3.center")[$b b a$]
    rect((0, 0), (rel: (w, h)), name: "b3")
    content("b3.center")[$b b$]
    content((w / 2, -0.2), anchor: "north")[#set text(size: 0.8em); $i_3 = 3$]

    translate(x: w + gap)
    rect((0, h), (rel: (w, h)), name: "t4")
    content("t4.center")[$a$]
    rect((0, 0), (rel: (w, h)), name: "b4")
    content("b4.center")[$b a a$]
    content((w / 2, -0.2), anchor: "north")[#set text(size: 0.8em); $i_4 = 1$]
  })
]

= Semi-decidability

== Semi-decidability

Suppose we want to determine $Sigma models alpha$, where $Sigma$ is infinite.
In general, it is _undecidable_.

#definition[Semi-decidable set][
  A set $S$ is _computably enumerable_ if there is an _enumeration procedure_ which lists, in some order, every member of $S$: $s_1, s_2, s_3 dots$

  Equivalently (see @enumerable), a set $S$ is _semi-decidable_ if there is an algorithm such that the set of inputs for which the algorithm halts is exactly $S$.
]

#note[
  There are more synonyms for _computably enumerable_, such as _effectively enumerable_, _recursively enumerable_ (do not confuse with just _recursive_!), and _Turing-recognizable_, or simply _recorgizable_.
]

#note[
  If $S$ is infinite, the enumeration procedure will _never_ finish, but every member of $S$ will be listed _eventually_, after some finite amount of time.
]

#note[
  Some properties of _decidable_ and _semi-decidable_ sets:
  - Decidable sets are closed under union, intersection, Cartesian product, and complement.
  - Semi-decidable sets are closed under union, intersection, and Cartesian product.
]

== Enumerability and Semi-decidability

#theorem[
  A set $S$ is computably enumerable iff it is semi-decidable.
] <enumerable>

#proof[($arrow.double.r$)][
  _If $S$ is computably enumerable, then it is semi-decidable._

  Since $S$ is computably enumerable, we can check if $alpha in S$ by enumerating all members of $S$ and checking if $alpha$ is among them.
  If it is, we answer "yes"; otherwise, we continue enumerating.
  Thus, if $alpha in S$, the procedure produces "yes".
  If $alpha notin S$, the procedure runs forever.
]

#pagebreak()

#proof[($arrow.double.l$)][
  _If $S$ is semi-decidable, then it is computably enumerable._

  Suppose we have a procedure $P$ which, given $alpha$, terminates and produces "yes" iff $alpha in S$.
  To show that $S$ is computably enumerable, we can proceed as follows.
  + Construct a systematic enumeration of _all_ expressions (for example, by listing all strings over the alphabet in length-lexicographical order): $beta_1, beta_2, beta_3, dots$
  + Break the procedure $P$ into a finite number of "steps" (for example, by program instructions).
  + Run the procedure on each expression in turn, for an increasing number of steps (see #link("https://en.wikipedia.org/wiki/Dovetailing_(computer_science)")[dovetailing]):
    - Run $P$ on $beta_1$ for 1 step.
    - Run $P$ on $beta_1$ for 2 steps, then on $beta_2$ for 2 steps.
    - ...
    - Run $P$ on each of $beta_1, dots, beta_n$ for $n$ steps each.
    - ...
  + If $P$ produces "yes" for some $beta_i$, output (yield) $beta_i$ and continue enumerating.

  This procedure will eventually list all members of $S$, thus $S$ is computably enumerable.
]

== Dual Enumerability and Decidability

#theorem[
  A set is decidable iff both it and its complement are semi-decidable.
]

#proof[($arrow.double.r$)][
  _If $A$ is decidable, then both $A$ and its complement $overline(A)$ are effectively enumerable._

  Since $A$ is decidable, there exists an effective procedure $P$ that halts on all inputs and returs "yes" if $alpha in A$ and "no" otherwise.

  To enumerate $A$:
  - Systematically generate all expressions $alpha_1, alpha_2, alpha_3, dots$
  - For each $alpha_i$, run $P$. If $P$ outputs "yes", yield $alpha_i$. Otherwise, continue.

  Similarly, enumerate $overline(A)$ by yielding $alpha_i$ when $P$ outputs "no".

  Both enumerations are effective, since $P$ always halts, so $A$ and its complement are semi-decidable.
]

#pagebreak()

#proof[($arrow.double.l$)][
  _If both $A$ and its complement $overline(A)$ are effectively enumerable, then $A$ is decidable._

  Let $E$ be an enumerator for $A$ and $overline(E)$ an enumerator for $overline(A)$.

  To decide if $alpha in A$, _interleave_ the execution of $E$ and $overline(E)$, that is, for $n = 1,2,3,dots$
  - Run $E$ for $n$ steps and if it produces $alpha$, _halt_ and output "yes".
  - Run $overline(E)$ for $n$ steps and if it produces $alpha$, _halt_ and output "no".

  Since $alpha$ is either in $A$ or in $overline(A)$, one of the enumerators will eventually produce $alpha$.
  The interleaving with increasing number of steps ensures fair scheduling without starvation.

  _Remark:_
  The "dovetailing" technique (alternating between enumerators with increasing step) avoids infinite waiting while maintaining finite memory requirements.
  The alternative is to run both enumerators _simultaneosly_, in parallel, using, for example, two computers.
]

== Enumerability of Tautological Consequences

#theorem[
  If $Sigma$ is an effectively enumerable set of WFFs, then the set ${alpha | Sigma models alpha}$ of tautological consequences of $Sigma$ is effectively enumerable.
]

#proof[
  Consider an enumeration of the elements of $Sigma$: $sigma_1, sigma_2, sigma_3, dots$

  By the compactness theorem, $Sigma models alpha$ iff ${sigma_1, dots, sigma_n} models alpha$ for some $n$.

  Hence, it is sufficient to successively test (using truth tables)
  $
    emptyset &models alpha, \
    {sigma_1} &models alpha, \
    {sigma_1, sigma_2} &models alpha, \
  $
  and so on.
  If any of these tests succeeds (each is decidable), then $Sigma models alpha$.

  This demonstrates that there is an effective procedure that, given any WFF $alpha$, will output "yes" iff $alpha$ is a tautological consequence of $Sigma$.
  Thus, the set of tautological consequences of $Sigma$ is effectively enumerable.
]

= Universal Machines

== Universal Turing Machine

A _universal Turing machine_ is a Turing machine that is capable of computing any computable sequence. @turing1937

#definition[
  A _universal Turing machine_ $U_"TM"$ is a Turing machine that can simulate any other TM.

  High-level description of a universal Turing machine $U_"TM"$:
  - Given an input $angle.l M, w angle.r$, where $M$ is a TM and $w in Sigma^*$:
    - Run (simulate a computation of) $M$ on $w$.
    - If $M$ halts and accepts $w$, $U_"TM"$ accepts $angle.l M, w angle.r$.
    - If $M$ halts and rejects $w$, $U_"TM"$ rejects $angle.l M, w angle.r$.
    - _Implicitly_, if $M$ loops on $w$, $U_"TM"$ loops on $angle.l M, w angle.r$.
]

#definition[
  The _language of a universal Turing machine_ $U_"TM"$ is the set $A_"TM"$ of all pairs $(M, w)$ such that $M$ is a TM and $M$ accepts $w$.

  $ A_"TM" = cal(L)(U_"TM") = { angle.l M, w angle.r | M "is a TM and" w in cal(L)(M) } $
]

== Diagonalization Language

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    Consider all possible Turing machines, listed in some order, and all strings that are valid TM descriptions:
    $ angle.l M_0 angle.r, angle.l M_1 angle.r, dots $

    #definition[
      Construct the _diagonalization language_ $L_Delta$ of all TMs that do not accept their own description:
      $ L_Delta = cal(L)(M_Delta) = { angle.l M angle.r | M "is a TM and" angle.l M angle.r notin cal(L)(M) } $
    ]

    #note[$M_Delta$ is _not_ listed in the table, since its behavior differs from each other $M_i$ at least on input $angle.l M_i angle.r$.]
  ],
  [
    #set align(center)
    #cetz.canvas({
      import cetz.draw: *

      scale(95%)
      scale(y: -1)
      stroke(0.8pt)

      let n = 5
      let w = n
      let h = n

      grid((0, 0), (rel: (w + .3, h + .3)))
      // grid((-1, 0), (rel: (1, h + .3)))
      // grid((0, -1), (rel: (w + .3, 1)))
      grid((0, h + 1), (rel: (w + 0.3, 1)))
      line((0, 0), (rel: (-0.3, -0.3)))

      // for i in range(n) {
      //   rect((i, i), (rel: (1, 1)), fill: yellow.lighten(80%))
      // }

      translate(x: 0.5, y: 0.5)

      for j in range(0, h) {
        content((-1, j))[$M_#j$]
      }
      for i in range(0, w) {
        content((i, -1))[$angle.l M_#i angle.r$]
      }

      for i in range(0, w) {
        content((i, h))[$dots$]
      }
      for j in range(0, h) {
        content((w, j))[$dots$]
      }
      content((-1, h))[$dots.v$]
      content((w, -1))[$dots$]
      content((w, h))[$dots$]
      content((w, h + 1))[$dots$]
      content((-1, h + 1))[$M_Delta$]

      let data = (
        (true, false, false, true, false),
        (true, true, true, true, true),
        (true, true, false, false, false),
        (false, true, true, true, true),
        (false, true, false, false, false),
      )

      for (j, row) in data.enumerate() {
        for (i, value) in row.enumerate() {
          let res = if value { [Acc] } else { [No] }
          if i == j {
            let color = if value {
              red.lighten(80%)
            } else {
              green.lighten(80%)
            }
            group({
              translate(x: -0.5, y: -0.5)
              stroke(none)
              on-layer(-1, rect((i, i), (rel: (1, 1)), fill: color))
              on-layer(-1, rect((i, h + 1), (rel: (1, 1)), fill: color))
            })
            let notres = if value { [No] } else { [Acc] }
            content((i, h + 1), notres)
          }
          content((i, j), res)
        }
      }
    })
  ],
)

== Diagonalization Language is not Recognizable

$L_Delta = { angle.l M angle.r | angle.l M angle.r notin cal(L)(M) }$

#theorem[
  $L_Delta notin "RE"$.
]
#proof[
  Suppose $L_Delta$ is recognizable.
  Then there exists a recognizer $R$ such that $cal(L)(R) = L_Delta$.

  It is the case that either $angle.l R angle.r notin cal(L)(R)$ or $angle.l R angle.r in cal(L)(R)$.

  + $angle.l R angle.r notin cal(L)(R)$.
    Thus, $angle.l R angle.r in L_Delta$.
    Since $cal(L)(R) = L_Delta$, $angle.l R angle.r notin cal(L)(R)$.
    Contradiction.

  + $angle.l R angle.r in cal(L)(R)$.
    Thus, $angle.l R angle.r notin L_Delta$.
    Since $cal(L)(R) = L_Delta$, $angle.l R angle.r in cal(L)(R)$.
    Contradiction.

  In either case, we reach a contradiction.
  Therefore, the initial assumption that $L_Delta$ is recognizable must be false.
  Thus, $L_Delta$ is not recognizable.
]

== Universal Language

$A_"TM" = cal(L)(U_"TM") = { angle.l M, w angle.r | M "is a TM and" w in cal(L)(M) }$

#theorem[
  $A_"TM" in "RE"$.
]
#proof[
  $U_"TM"$ is a TM that recognizes $A_"TM"$.
]

#theorem[
  $overline(A)_"TM" notin "RE"$
]
#proof[
  $L_Delta scripts(lt.eq)_M overline(A)_"TM"$.
  Build a recognizer (impossible) for $L_Delta$ using a (hypothetical) recognizer for $overline(A)_"TM"$.
]

#theorem[
  $A_"TM" notin "R"$.
]
#proof[
  $"R"$ is closed under complement.
  A language $A$ is decidable iff it is both recognizable ($A in "RE"$) and co-recognizable ($overline(A) in "RE"$).
  We know that $overline(A)_"TM" notin "RE"$, thus $A_"TM"$ cannot be decidable.
]

= Reductions

== Mapping Reductions

TODO

== Extremely Hard Problem

Regular languages are decidable.
Some Turing machines accept regular languages and some do not.

#definition[
  Let *REGULAR* be the language of all TMs that accept regular languages.

  $ "REGULAR"_"TM" = { angle.l M angle.r | cal(L)(M) "is regular" } $
]

This language is _neither_ recognizable nor co-recognizable.
(See theorems on the next slides.)

- _No computer program can confirm that a given Turing machine has a regular language._
- _No computer program can confirm that a given Turing machine has a non-regular language._
- _This problem is beyond the limits of what computers can ever do._

== REGULAR is not Recognizable

#theorem[
  $"REGULAR"_"TM" notin "RE"$.
]
#proof[
  $L_Delta scripts(lt.eq)_M "REGULAR"_"TM"$.
]

== REGULAR is not even co-Recognizable

#theorem[
  $"REGULAR"_"TM" notin "co-RE"$
]
#proof[
  $overline(L)_Delta scripts(lt.eq)_M "REGULAR"_"TM"$.
]

== TODO

#show: cheq.checklist

- [ ] Decidable language outside of NP
- [/] Universal TM
- [ ] Encodings
- [ ] Programs
- [ ] Rice's theorem

== Bibliography
#bibliography("refs.yml")
