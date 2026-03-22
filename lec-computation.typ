#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Theory of Computation",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

#let yields = $scripts(arrow.double)$
#let tapestart = box(baseline: 1pt)[$triangle.small.r$]
#let Blank = math.class("normal", sym.square.stroked)

= Languages

== Why Theory of Computation?

We have studied _propositional logic_, _SAT_, and _first-order logic_.
A natural question recurs: *"Which problems can be solved automatically?"*

#Block(color: yellow)[
  *The central question of this lecture:*

  Given a decision problem (e.g., "is this FOL formula valid?"), does there exist an _algorithm_ that always answers correctly in _finite time_?
]

#columns(2)[
  *We have already seen:*
  - SAT is NP-complete --- hard, but _decidable_ \
    _(an answer always exists, just slowly)_
  - FOL validity is only _semi-decidable_ \
    _(provability but not refutability)_
  - Some SMT theories are _decidable_ \
    _(e.g., linear arithmetic over $RR$)_
  - FOL over $NN$ (Peano Arithmetic) is undecidable

  #colbreak()

  *This lecture provides:*
  - Formal definition of "computation"
  - Precise meaning of _decidability_
  - Rice's theorem: why program verification is _hard in general_
  - Why SMT solvers restrict to specific _theories_
]

#Block(color: blue)[
  *Payoff:* You will understand precisely _why_ automated verification requires carefully chosen decidable fragments --- and why general program verification is fundamentally undecidable.
]

== Formal Languages

#definition[
  An _alphabet_ $Sigma$ is a finite non-empty set of symbols.

  A _word_ (or _string_) over $Sigma$ is a finite sequence of symbols from $Sigma$.
  The _empty word_ is $epsilon$.

  The set of all finite words over $Sigma$ is $Sigma^* = limits(union.big)_(k=0)^infinity Sigma^k$.

  A _formal language_ $L subset.eq Sigma^*$ is any set of finite words over $Sigma$.
]

#example[
  - $Sigma = {0, 1}$, $L_1 = {0^n 1^n mid(|) n geq 0} = {epsilon, 01, 0011, 000111, dots}$
  - $Sigma = {a, b}$, $L_2 = {w mid(|) w "has equal number of" a"s and" b"s"}$
  - $L_3 = {"SAT", "HALT", "VALID", dots}$ --- languages encoding decision problems
]

#note[
  Every decision problem is a formal language: the set of _yes-instances_.
  Solving the problem = deciding membership in the language.
]

== Chomsky Hierarchy

Formal languages are classified into four nested levels:

#align(center)[
  #table(
    columns: 4,
    align: (center, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Type*], [*Class*], [*Recognizing Machine*], [*Example Language*]),
    [3], [Regular], [DFA / NFA], [$a^* b^*$, ${ a^n mid(|) n "even" }$],
    [2], [Context-Free], [Pushdown Automaton], [${ a^n b^n mid(|) n geq 0 }$],
    [1], [Context-Sensitive], [Linear-Bounded TM], [${ a^n b^n c^n mid(|) n geq 0 }$],
    [0], [Recursively Enum.], [Turing Machine], [${ angle.l M, w angle.r mid(|) M "halts on" w }$],
  )
]

#Block(color: blue)[
  Each level adds _more memory_:
  finite states $arrow.r$ unlimited stack $arrow.r$ bounded tape $arrow.r$ infinite tape.

  More expressive = harder algorithmic questions about the language class.
]

#note[
  The classes are _nested_: every regular language is context-free, every context-free is context-sensitive, etc.
  The containments are strict --- each level is strictly more powerful than the one below.
]

== Decision Problems as Languages

#definition[
  A _decision problem_ is a question with a "yes" or "no" answer depending on the input.
  Formally, the set of inputs for which the answer is "yes" forms a language $L subset.eq Sigma^*$.

  _Deciding_ the problem = _recognizing_ the language $L$.
]

#grid(
  columns: 1,
  gutter: 0.4em,
  block(width: 100%)[
    *SAT:* Given a CNF formula $phi$, is it satisfiable?
    $ "SAT" = { phi mid(|) phi "is a satisfiable Boolean formula" } $

    *FOL Validity:* Given a first-order formula $phi$, is it valid?
    $ "VALID" = { phi mid(|) phi "is a valid (universally true) FOL formula" } $

    *Halting Problem:* Given a TM $M$ and input $w$, does $M$ halt on $w$?
    $ "HALT" = { angle.l M, w angle.r mid(|) "TM" M "halts on input" w } $
  ],
)

#Block(color: yellow)[
  "Is $w in L$?" and "does the algorithm say yes on input $w$?" are _the same question_.
  Formal language theory gives us the mathematics to study the _limits of computation_.
]

== Language Complexity Classes

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (0.8, 0.4))
    circle((0, 0.4), radius: (1.4, 0.8))
    circle((0, 0.8), radius: (2, 1.2))
    circle((0, 1.2), radius: (2.6, 1.6))
    circle((0, 2.4), radius: (4, 2.8), stroke: blue)
    circle((0, 1.2), radius: (4, 2.8), stroke: red)
    content((0, 0))[Finite]
    content((0, .7))[Regular]
    content((0, 1.55))[Context-Free]
    content((0, 2.3))[Context-Sensitive]
    content((0, 3.2))[#set text(fill: purple); Decidable = $"RE" inter "co-RE"$]
    content((0, 4.4))[#set text(fill: blue); Recursively Enumerable (RE)]
    content((0, -1))[#set text(fill: red); co-RE]
    circle((2.5, 2.5), radius: 3pt, fill: yellow)
    content((2.5, 2.5), anchor: "north-west", padding: 5pt)[SAT]
    circle((3.2, 3.8), radius: 3pt, fill: yellow)
    content((3.2, 3.8), anchor: "south-west", padding: 5pt)[HALT]
    circle((2.8, 5), radius: 3pt, fill: yellow)
    content((2.8, 5), anchor: "south-west", padding: 5pt)[$"REGULAR"_"TM"$]
  })
]

#note[
  *SAT* is decidable (NP-complete). *HALT* is recognizable but _not_ decidable: a TM can confirm halting by simulation, but cannot confirm non-halting. $"REGULAR"_"TM"$ = "does TM $M$ recognize a regular language?" --- in neither RE nor co-RE.
]

= Machines

== Finite Automata

#definition[
  A _Deterministic Finite Automaton_ (DFA) is a 5-tuple $(Q, Sigma, delta, q_0, F)$:
  - $Q$ --- finite set of _states_
  - $Sigma$ --- _input alphabet_
  - $delta: Q times Sigma to Q$ --- _transition function_
  - $q_0 in Q$ --- _start state_
  - $F subset.eq Q$ --- set of _accepting states_

  A DFA processes input left-to-right, one symbol at a time, and accepts if it ends in an accepting state.
  DFAs recognize exactly the _regular_ languages (Type 3 in the Chomsky hierarchy).
]

== DFA Example: Even Number of 0s

#example[
  Automaton $cal(A)$ over $Sigma = {0, 1}$ recognizing $cal(L)(cal(A)) = { w mid(|) w "has an even number of 0s" }$.

  States: $q_0$ = "seen even many 0s" (start, accepting), $q_1$ = "seen odd many 0s".
  - Reading a *0*: flip parity (switch state).
  - Reading a *1*: parity unchanged (stay in state).

  #let aut = (
    q0: (q1: 0, q0: 1),
    q1: (q0: 0, q1: 1),
  )
  #grid(
    columns: 2,
    column-gutter: 3em,
    align: horizon,
    finite.transition-table(aut),
    finite.automaton(
      aut,
      final: ("q0",),
      style: (
        state: (radius: 0.5, extrude: 0.8),
        transition: (curve: 0.4),
        q0-q0: (anchor: top + left),
        q1-q1: (anchor: top + right),
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
  #import fletcher: diagram, edge, node
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
      import fletcher: cetz
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

== TM Language and Acceptance

#definition[
  The language _recognized_ by $M$, written $cal(L)(M)$, is the set of inputs $M$ accepts:
  $ cal(L)(M) = { w in Sigma^* mid(|) M "halts in state" q_"acc" "on input" w } $

  For inputs _not_ in $cal(L)(M)$, the machine either _rejects_ (halts in $q_"rej"$) or _loops forever_.
]

#Block(color: yellow)[
  *The crucial distinction:*
  - A _recognizer_ only needs to accept members of $L$. It may loop forever on non-members.
  - A _decider_ must always halt --- it accepts members and _rejects_ non-members.

  $ "Decider" = "Recognizer that never loops" $
]

#definition[
  A TM is a _decider_ for $L$ if it halts on _every_ input (accepting $L$ and rejecting its complement).
  A language is _decidable_ (recursive) if it has a decider.
  A language is _recognizable_ (RE) if it has a recognizer.
]

== TM Configuration

// Helper: draw TM read/write head pointing at a tape cell
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

#definition[TM Configuration][
  A _configuration_ describes the complete state of a TM at a given moment:
  $ (u ; q ; v) quad u, v in Gamma^*, quad q in Q $
  - $u$ --- tape contents to the _left_ of the head
  - $q$ --- current _state_
  - $v$ --- tape contents from the head _rightward_ (head reads $v[0]$)
]

#example[
  Configuration $(u ; q ; a v)$ is visualized as:
  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      scale(55%)
      content((-0.5, 0.5))[$tapestart$]
      rect((0, 0), (rel: (2, 1)), name: "u")
      content("u.center")[$u$]
      rect((2, 0), (rel: (1, 1)), name: "a", fill: orange.lighten(80%))
      content("a.center")[$a$]
      rect((3, 0), (rel: (2, 1)), name: "v")
      content("v.center")[$v$]
      for-each-anchor("a", name => {}, exclude: ("center",))
      line((0, 0), (5.5, 0))
      line((0, 1), (5.5, 1))
      line((5.5, 0), (6.2, 0), stroke: (dash: "dashed"))
      line((5.5, 1), (6.2, 1), stroke: (dash: "dashed"))
      tm-head((rel: (0, -1pt), to: "a.south"))[$q$]
    })
  ]
  The head reads $a$; the next transition depends on $(q, a)$.
]

== TM Computation

#definition[Computation][
  A _computation_ of TM $M$ on input $w$ is a sequence of configurations:
  $ C_1 yields C_2 yields dots.c yields C_n $
  - $C_1 = (#tapestart ; q_0 ; w)$ --- _start configuration_
  - $C_i yields C_{i+1}$ --- "$C_i$ yields $C_{i+1}$ in one step"
  - $C_n$ is a _halting configuration_ (state is $q_"acc"$ or $q_"rej"$)
]

The relation $yields^*$ (yields in any number of steps) is the reflexive-transitive closure of $yields$.

#Block(color: yellow)[
  *Intuition:* Think of a computation as a "snapshot sequence" of the machine.
  Each snapshot captures the tape contents, the current state, and the head position.
  The machine moves from snapshot to snapshot by applying one transition.
]

#note[
  A _terminating_ computation always reaches $q_"acc"$ or $q_"rej"$.
  A _looping_ computation produces an infinite sequence $C_1 yields C_2 yields dots.c$ that never halts.
]

== TM Yields Relation

How does one configuration yield the next?

#definition[Yields ($yields$)][
  Let $u, v in Gamma^*$, $a, b, c in Gamma$, $q_i, q_j in Q$.

  *Move left* ($L$): $(u a ; q_i ; b v) yields (u ; q_j ; a c v)$ when $delta(q_i, b) = (q_j, c, L)$

  *Move right* ($R$): $(u ; q_i ; b a v) yields (u c ; q_j ; a v)$ when $delta(q_i, b) = (q_j, c, R)$

  In both cases: overwrite $b$ with $c$, move the head, change to state $q_j$.
]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    scale(50%)

    // Left move: before
    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "a")
    content("a.center")[$a$]
    rect((3, 0), (rel: (1, 1)), name: "b", fill: orange.lighten(80%))
    content("b.center")[$b$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "b.south"))[$q_i$]

    translate(x: 8)
    content((-1, -0.4))[$limits(yields)_(delta(q_i, b) = (q_j, c, L))$]

    // Left move: after
    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "a", fill: orange.lighten(80%))
    content("a.center")[$a$]
    rect((3, 0), (rel: (1, 1)), name: "c")
    content("c.center")[$c$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "a.south"))[$q_j$]

    translate(x: 9)

    // Right move: before
    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "b", fill: orange.lighten(80%))
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

    // Right move: after
    rect((0, 0), (rel: (2, 1)), name: "u")
    content("u.center")[$u$]
    rect((2, 0), (rel: (1, 1)), name: "c")
    content("c.center")[$c$]
    rect((3, 0), (rel: (1, 1)), name: "a", fill: orange.lighten(80%))
    content("a.center")[$a$]
    rect((4, 0), (rel: (2, 1)), name: "v")
    content("v.center")[$v$]
    line((-0.3, 0), (6.3, 0))
    line((-0.3, 1), (6.3, 1))
    tm-head((rel: (0, -1pt), to: "a.south"))[$q_j$]
  })
]

#note[
  *Left-end special case:* If the head is at the tape start and the transition says "move left", the head stays in place:
  $( #tapestart ; q_i ; b v) yields (#tapestart ; q_j ; c v)$ when $delta(q_i, b) = (q_j, c, L)$.
]

== TM Tape Visualization

#example[
  Initial tape state for ${ 0^n 1^n }$ TM on input $w = 0011$:
  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      scale(90%)
      let cells = ("", "0", "0", "1", "1", " ", " ", " ")
      for (i, c) in cells.enumerate() {
        let fill-color = if c == "0" or c == "1" { blue.lighten(80%) } else { white }
        rect((i, 0), (i + 1, 1), fill: fill-color, stroke: 0.6pt)
        content((i + 0.5, 0.5))[#c]
      }
      content((-0.3, 0.5))[$tapestart$]
      // Draw head pointer
      line(
        (1.5, -0.15),
        (1.1, -0.6),
        (1.9, -0.6),
        close: true,
        fill: orange.lighten(60%),
        stroke: 0.6pt,
      )
      content((1.5, -1.0), anchor: "north")[$q_0$]
    })
  ]

  Blue cells = input. The head (orange triangle) points at the first cell. State is $q_0$.
]

#note[
  The machine strategy: repeatedly find the leftmost `0`, mark it `X`, find the matching `1`, mark it `Y`. Accept when all 0s and 1s are paired. Reject if counts mismatch.
]

== TM Example: Recognizing *$0^n 1^n$*

Step-by-step configuration trace for input $0011$ ($n = 2$). The _underlined_ symbol is at the head.

#align(center)[
  #table(
    columns: 3,
    align: (left, auto, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Step*], [*Configuration $(u ; q ; v)$*], [*Action*]),
    [Start], [$(#tapestart ; q_0 ; 0011)$], [Read `0` → write `X`, move right],
    [Mark first 0], [$(#tapestart X ; q_1 ; 011)$], [Scan right past 0s to find `1`],
    [Found first 1], [$(#tapestart X 0 ; q_2 ; 11)$], [Write `Y`, move left],
    [Mark first 1], [$(#tapestart X 0 Y ; q_3 ; 1)$], [Move back to start],
    [Back at start], [$(#tapestart ; q_0 ; X 0 Y 1)$], [Read `X` → skip, find next `0`],
    [Mark second 0], [$(#tapestart X X ; q_1 ; Y 1)$], [Scan right past Y to find `1`],
    [Found second 1], [$(#tapestart X X Y ; q_2 ; 1)$], [Write `Y`, move left],
    [All matched], [$(#tapestart X X Y Y ; q_"acc" ; #Blank)$], [Tape is all X/Y --- *Accept!*],
  )
]

#Block(color: yellow)[
  *Key insight:* The tape acts as scratch memory. At each round, one `0`--`1` pair is matched and "consumed" by overwriting with `X` and `Y`. This requires $O(n^2)$ steps for input length $2n$.
]

== Machine Comparison

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Property*], [*DFA*], [*PDA*], [*TM*]),
    [Memory], [None (finite states)], [Stack (LIFO)], [Infinite R/W tape],
    [Reading], [Left-to-right,\ each symbol once], [Left-to-right,\ each symbol once], [Arbitrary R/W movement],
    [Language class], [Regular], [Context-Free], [RE (or R if decider)],
    [Determinism], [Equivalent to NDFA], [NDPDA more powerful], [NTM = DTM],
    [Emptiness check], [Decidable], [Decidable], [Undecidable],
    [Equality check], [Decidable], [Undecidable], [Undecidable],
    [Example language], [$a^n (n "even")$], [$a^n b^n$], [$a^n b^n c^n$],
  )
]

#note[
  NTM $=$ DTM is the _Church--Turing thesis_ in action: non-determinism does not add power, only speed. Compare with NP vs P!
]

== TM Variants

All the following are equivalent in computational power (they recognize the same class of languages):

#columns(2)[
  *Standard TM*
  - Single infinite tape, one head
  - Alphabet $Gamma$, states $Q$, transition $delta$

  *Multi-tape TM*
  - $k$ tapes, $k$ heads moving independently
  - Easier to program, same power

  *Non-deterministic TM (NTM)*
  - At each step, choose from multiple transitions
  - Accepts if _any_ branch accepts
  - Non-determinism $arrow.r$ exponential simulation overhead

  #colbreak()

  *Two-way infinite tape*
  - Tape extends in both directions
  - Simulated by storing two tapes on one

  *TM with stay*
  - Head can stay in place ($S$ move)
  - Easier to define, trivially equivalent

  *Random Access Machine (RAM)*
  - Memory indexed by address
  - Polynomially equivalent to standard TM (relevant for complexity!)
]

#Block(color: yellow)[
  *Church--Turing thesis (operational form):* Any reasonable model of computation computes exactly the same class of functions as a Turing machine. The thesis is supported by the equivalence of all known models.
]

== Recognizing vs Deciding

There are _two_ types of Turing machines:
+ *Decider* (total TM): always halts on every input.
+ *Recognizer* (general TM): may loop forever on some inputs.

#definition[Recognition][
  A TM _recognizes_ language $L$ if it accepts every $w in L$ and does not accept any $w notin L$ (but may loop on non-members).

  Such a language is called _recognizable_ (also: Turing-recognizable, recursively enumerable, semi-decidable --- all equivalent). The class of all recognizable languages is *RE*.
]

#definition[Decision][
  A TM _decides_ language $L$ if it accepts every $w in L$ and _rejects_ every $w notin L$; it always halts.

  Such a language is called _decidable_ (also: recursive, computable). The class of all decidable languages is *R* ($subset.neq$ RE).
]

#Block(color: yellow)[
  *Key distinction:* A recognizer is allowed to loop on non-members. A decider _must_ halt and give an answer for every input.
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

- *RE* --- Languages _accepted_ by any TM. Not all RE languages are decidable.
- *R* = RE $inter$ co-RE --- Languages _decided_ by a halting TM. Closed under complement.
- *EXP* --- Decided in _exponential time_ by a deterministic TM. Closed, proper superset of NP.
- *PSPACE* --- Decided in _polynomial space_. Contains NP and co-NP. QBF is PSPACE-complete.
- *NP* --- Accepted by a _non-deterministic_ TM in polynomial time. SAT, graph coloring, etc.
- *P* --- Decided in _polynomial time_ by a deterministic TM. Primality, BFS/DFS, LP.

#note[
  All containments are known, but many strict separations are open: $"P" eq.quest "NP"$, $"NP" eq.quest "co-NP"$, $"NP" eq.quest "PSPACE"$, etc.
]

== Polynomial Hierarchy

The _polynomial hierarchy_ PH refines the NP/co-NP picture using alternating quantifiers:

$ Sigma_0^P = Pi_0^P = "P" $
$ Sigma_(k+1)^P = "NP"^(Sigma_k^P), quad Pi_(k+1)^P = "co-NP"^(Sigma_k^P) $

- $Sigma_1^P = "NP"$: $exists$ witness, polynomial verifier
- $Pi_1^P = "co-NP"$: $forall$ witnesses, polynomial verifier
- $Sigma_2^P$: $exists forall$ witnesses (e.g., "does $phi$ have an assignment that satisfies all clauses for every setting of some variables?")
- $Pi_2^P$: $forall exists$ witnesses

#Block(color: yellow)[
  *Relevance to FM:* Model checking for $mu$-calculus is PSPACE-complete. Bounded model checking for quantified Boolean formulas (QBF) is PSPACE-complete. SMT with quantifiers ($forall/exists$) stratifies across the polynomial hierarchy.
]

#note[
  If PH collapses to any level (i.e., $Sigma_k^P = Sigma_(k+1)^P$ for some $k$), it implies strong consequences about the structure of NP. In particular, P $=$ NP would collapse the entire hierarchy to P.
]

== Complexity Zoo

#align(center)[
  #table(
    columns: 3,
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Problem*], [*Complexity*], [*Practical Approach*]),
    [Propositional SAT], [NP-complete], [CDCL SAT solvers (CaDiCaL, MiniSat)],
    [QBF (SMT over $2^"nd"$ order)], [PSPACE-complete], [QBF solvers (DepQBF)],
    [Linear arith. ($RR$)], [P (LP), NP in SMT], [Simplex + DPLL(T) (Z3, CVC5)],
    [Linear arith. ($ZZ$)], [NP-hard], [Branch-and-bound + cutting planes],
    [Non-linear arith. ($RR$)], [Decidable (Tarski)], [Cylindrical Algebraic Decomp.],
    [Non-linear arith. ($ZZ$)], [Undecidable (Hilbert 10)], [Semi-decidable fragments only],
    [FOL validity], [Undecidable (semi-decidable)], [Tableau / resolution (incomplete)],
    [Program verification], [Undecidable (Rice)], [Require invariants, bounded checking],
  )
]

#Block(color: blue)[
  *Why decidable fragments matter:* SMT works precisely because it uses _restricted but decidable_ theories.
  Once you add full integer multiplication or quantified arithmetic, the theories become undecidable --- and no complete solver can exist.
]

See also: #link("https://complexityzoo.net/Petting_Zoo")[Complexity Zoo Petting Zoo]

= Computability

== The Church--Turing Thesis

#definition[Church--Turing Thesis][
  _Every effectively computable function is computable by a Turing machine._

  "Effectively computable" means: can be carried out by a finite, deterministic, mechanical step-by-step procedure, with no creativity or luck required.
]

#note[
  This is a *thesis*, not a theorem. "Effectively computable" is informal. We cannot formally _prove_ the thesis, but no counterexample has ever been found.
]

#Block(color: teal)[
  *Historical note:* In 1936, Alonzo Church ($lambda$-calculus) and Alan Turing (Turing machines) independently formalized computability and proved these models equivalent. Every other general-purpose model proposed since --- register machines, $mu$-recursive functions, Post systems --- computes exactly the same class of functions.
]

== Computable Functions

#definition[Computable function][
  A partial function $f : NN^k arrow.hook NN$ is _computable_ if there exists a TM $M$ such that:
  - If $f(arrow(x))$ is defined: $M$ halts on input $arrow(x)$ with output $f(arrow(x))$.
  - If $f(arrow(x))$ is undefined: $M$ loops forever on input $arrow(x)$.
]

_Computable functions:_
- $f(x) = x^2$, $f(x) = x!$, $f(x) = x mod 2$ --- basic arithmetic
- $f(n) =$ the $n$-th prime --- search computable
- $f(n) =$ the $n$-th digit of $pi$ --- BBP formula
- The Ackermann function $A(m, n)$ --- computable but not primitive recursive

_Non-computable functions:_

#definition[Busy Beaver][
  $"BB"(n)$ = the maximum number of 1s a _halting_ $n$-state TM over ${0, 1}$ can write on an initially blank tape.
]

== The Busy Beaver

$"BB"$ grows faster than _any_ computable function:

#example[
  $"BB"(1) = 1$, $"BB"(2) = 4$, $"BB"(3) = 6$, $"BB"(4) = 13$, $"BB"(5) geq 47{,}176{,}870$.

  $"BB"(6)$ is astronomically large (on the order of $10^{10^{10^{10^{18705352}}}}$).
]

#Block(color: orange)[
  *BB is not computable.* Suppose we could compute $"BB"(n)$. Then to check whether an $n$-state TM $M$ halts on blank tape: run $M$ for $"BB"(n)$ steps. If $M$ hasn't halted by then, it never will. But this solves the Halting Problem --- a contradiction.
]

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
  The existence of _undecidable_ sets can be shown as follows.

  An algorithm is completely determined by its _finite_ description.
  Thus, there are only _countably many_ effective procedures.
  But there are _uncountably many_ subsets of $NN$ (by Cantor's theorem).
  Hence, _most_ sets of natural numbers are undecidable --- decidable sets are the exception, not the rule.
]

#Block(color: blue)[
  *FM implication:* The set of _valid FOL formulas_ is semi-decidable but not decidable (Church--Turing, 1936). This is why automated theorem provers for full FOL cannot be _complete deciders_ --- they can confirm validity but cannot always confirm invalidity.

  Restricted theories (linear arithmetic, equality + uninterpreted functions) _are_ decidable, which is exactly why SMT solvers work!
]

= Undecidability

== Halting Problem

#definition[Halting problem #href("https://en.wikipedia.org/wiki/Halting_problem")][
  Given a program $P$ and an input $x$, determine whether $P$ halts on $x$ (stops after finite time) or loops forever.
]

#theorem[Turing, 1936][
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

Observe that ```py halts(self_halts, self_halts)``` cannot return neither ```py True``` nor ```py False```. *Contradiction!*

Thus, the `halts` function _does not exist_ (cannot be implemented), and the halting problem is _undecidable_.

#Block(color: orange)[
  *Common confusion:* The halting problem is _undecidable_ for TMs (and all equivalent models). It does _not_ mean we cannot detect simple loops in practice --- a static analyzer can catch obvious infinite loops. It means there is _no algorithm_ that correctly decides all possible programs.
]

== Many-One Reductions

#definition[Many-one reduction][
  Language $A$ is _many-one reducible_ to language $B$, written $A leq_m B$, if there exists a _total computable_ function $f : Sigma^* to Sigma^*$ such that for all $w in Sigma^*$:
  $ w in A iff f(w) in B $
  The function $f$ is called the _reduction function_.
]

#theorem[
  If $A leq_m B$ and $B$ is decidable, then $A$ is decidable.
]

#Block(color: yellow)[
  *Contrapositive (more useful):* If $A leq_m B$ and $A$ is _undecidable_, then $B$ is _undecidable_.

  *Strategy:* To prove $B$ is undecidable, show $"HALT" leq_m B$ (or reduce from another known undecidable $A$).
]

#example[
  To prove $E_"TM" = { angle.l M angle.r mid(|) cal(L)(M) = emptyset }$ is undecidable:

  Reduce $"HALT"$ to the _complement_ of $E_"TM"$: from $angle.l M, w angle.r$, construct $M'$ that ignores its own input and simulates $M$ on $w$. Then $M'$ accepts something iff $M$ halts on $w$.

  Since $"HALT"$ is undecidable and the reduction is computable, $E_"TM"$ is undecidable.
]

== Rice's Theorem

#definition[Semantic property][
  A property $P$ of TMs is _semantic_ if it depends only on the _language_ recognized by the TM, not on the implementation.

  Formally: if $cal(L)(M_1) = cal(L)(M_2)$ then $P(M_1) = P(M_2)$.

  A property is _non-trivial_ if _some_ TMs satisfy it and _some_ TMs do not.
]

#theorem[Rice, 1953][
  Every non-trivial semantic property of Turing machines is _undecidable_.

  That is, for any non-trivial semantic property $P$, the language
  $ L_P = { angle.l M angle.r mid(|) M "has property" P } $
  is undecidable.
] <rice>

#Block(color: orange)[
  *What Rice's theorem says:* There is _no algorithm_ that reads a TM (or program) description and correctly determines _any non-trivial language property_ of what it computes.
]

== Rice's Theorem --- Proof

#proof[
  Let $P$ be a non-trivial semantic property.
  WLOG assume $P$ does not hold for the TM $M_emptyset$ recognizing the empty language $emptyset$.
  (If it does, use the complement of $P$ instead.)

  Since $P$ is non-trivial, some TM $M_P$ satisfies $P$, so $cal(L)(M_P) neq emptyset$.

  We reduce $A_"TM" = { angle.l M, w angle.r mid(|) M "accepts" w }$ to $L_P$.
  Given $angle.l M, w angle.r$, construct a new machine $M'$ as follows:

  _On input $x$:_
  1. Simulate $M$ on $w$ (ignoring $x$ for now).
  2. If $M$ rejects $w$, *reject*.
  3. If $M$ accepts $w$, simulate $M_P$ on $x$ and output its result.

  Then:
  - If $M$ accepts $w$: $M'$ simulates $M_P$, so $cal(L)(M') = cal(L)(M_P)$, and $P(M')$ holds.
  - If $M$ does not accept $w$: $M'$ never reaches step 3, so $cal(L)(M') = emptyset$, and $P(M')$ fails.

  Thus $angle.l M, w angle.r in A_"TM" iff angle.l M' angle.r in L_P$.
  Since $A_"TM"$ is undecidable, so is $L_P$. $square$
]

== Rice's Theorem --- Consequences

#Block(color: orange)[
  *No algorithm can decide, for an arbitrary program $P$:*
  #columns(2)[
    - Does $P$ terminate on _all_ inputs?
    - Does $P$ ever produce output on _some_ input?
    - Are programs $P_1$ and $P_2$ _equivalent_?
    - Does $P$ recognize a _regular_ language?
    #colbreak()
    - Does $P$ satisfy its specification?
    - Does $P$ have any security vulnerability?
    - Does $P$ produce infinite output?
    - Does $P$ access memory safely?
  ]

  All of these are _non-trivial semantic properties_ --- all undecidable by Rice's theorem.
]

#Block(color: blue)[
  *The key message for Formal Methods:*

  Automated _complete_ program verification is _mathematically impossible_ in full generality.
  This is not just an engineering obstacle --- it is a _theorem_.

  This is why Dafny requires _human-provided loop invariants_ and pre/postconditions;
  why SMT solvers restrict to _decidable theories_;
  and why static analyzers produce _false positives_.

  Formal verification is the art of finding the _right decidable fragment_ for the problem at hand.
]

== Map of Decidability

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    set-style(stroke: 1pt)

    // Outer rectangle = all languages
    rect((-5.5, -3), (5.5, 3), stroke: 0.8pt, name: "all")
    content((4.5, 2.3))[All languages]

    // RE circle (left-shifted)
    circle((-1.5, 0), radius: (3.2, 2.4), stroke: blue + 1pt, fill: blue.lighten(92%))
    content((-4.2, 0))[#set text(fill: blue); RE]

    // co-RE circle (right-shifted)
    circle((1.5, 0), radius: (3.2, 2.4), stroke: red + 1pt, fill: red.lighten(92%))
    content((4.2, 0))[#set text(fill: red); co-RE]

    // The intersection label
    content((0, 0), padding: 3pt)[
      #set text(fill: purple, weight: "bold")
      Decidable \
      #set text(fill: purple, weight: "regular", size: 0.85em)
      $= "RE" inter "co-RE"$
    ]

    // Landmarks
    circle((-0.9, 0.9), radius: 2.5pt, fill: orange)
    content((-0.9, 0.9), anchor: "south", padding: 4pt)[#set text(size: 0.75em); SAT]

    circle((-0.3, -0.5), radius: 2.5pt, fill: orange)
    content((-0.3, -0.5), anchor: "north", padding: 4pt)[#set text(size: 0.75em); HALT(bounded)]

    circle((-2.5, 0.4), radius: 2.5pt, fill: blue)
    content((-2.5, 0.4), anchor: "south", padding: 4pt)[#set text(size: 0.75em, fill: blue); HALT]

    circle((2.5, -0.4), radius: 2.5pt, fill: red)
    content((2.5, -0.4), anchor: "north", padding: 4pt)[#set text(size: 0.75em, fill: red); $overline("HALT")$]

    circle((-4.5, 1.3), radius: 2.5pt, fill: gray)
    content((-4.5, 1.3), anchor: "south", padding: 4pt)[#set text(size: 0.75em, fill: gray); $"REGULAR"_"TM"$]
  })
]

#note[
  *HALT* $in$ RE $setminus$ co-RE (recognizable but not co-recognizable).
  $overline("HALT") in$ co-RE $setminus$ RE.
  *SAT* $in$ R (decidable, NP-complete).
  $"REGULAR"_"TM"$ --- in neither RE nor co-RE!
]

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
  There are more synonyms for _computably enumerable_, such as _effectively enumerable_, _recursively enumerable_ (do not confuse with just _recursive_!), and _Turing-recognizable_, or simply _recognizable_.
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
              emptyset & models alpha, \
             {sigma_1} & models alpha, \
    {sigma_1, sigma_2} & models alpha, \
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

      grid(
        (0, 0),
        (rel: (w + .3, h + .3)),
      )
      // grid((-1, 0), (rel: (1, h + .3)))
      // grid((0, -1), (rel: (w + .3, 1)))
      grid(
        (0, h + 1),
        (rel: (w + 0.3, 1)),
      )
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

_Many-one reductions_ are the primary tool for proving undecidability: show that if you could decide $B$, you could decide $A$ (which is already known to be undecidable).

#definition[Many-one reduction ($scripts(lt.eq)_M$)][
  $A scripts(lt.eq)_M B$ ("$A$ reduces to $B$") means there is a computable total function $f$ such that for all $x$: $x in A iff f(x) in B$.

  If $A scripts(lt.eq)_M B$ and $B$ is decidable, then $A$ is decidable.

  _Contrapositive:_ If $A scripts(lt.eq)_M B$ and $A$ is undecidable, then $B$ is undecidable.
]

#Block(color: yellow)[
  *Pattern for undecidability proofs:*
  + Take a known undecidable problem $A$ (e.g., the Halting Problem $"HALT"_"TM"$).
  + Show $A scripts(lt.eq)_M B$ by constructing $f$ explicitly.
  + Conclude $B$ is undecidable.
]

See the Undecidability section for worked examples: Halting Problem $scripts(lt.eq)_M$ Rice's theorem problems.

== Extremely Hard Problem

Regular languages are decidable.
Some Turing machines accept regular languages and some do not.

#definition[
  Let *REGULAR* be the language of all TMs that accept regular languages.

  $ "REGULAR"_"TM" = { angle.l M angle.r | cal(L)(M) "is regular" } $
]

This language is _neither_ recognizable nor co-recognizable.
(See theorems on the next slides.)

#Block[
  - No computer program can confirm that a given Turing machine has a _regular_ language.

  - No computer program can confirm that a given Turing machine has a _non-regular_ language.
]

#Block(color: yellow)[
  This problem is _beyond_ the limits of what computers can _ever_ do.
]

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

= Alternative Models of Computation

== Alternative Models

Beyond Turing machines, every general-purpose model computes the same class of functions:

#align(center)[
  #table(
    columns: 2,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Model*], [*Author (year)*]),
    [$lambda$-calculus], [Church (1936)],
    [$mu$-recursive functions], [Kleene (1936)],
    [Post correspondence systems], [Post (1943)],
    [Register machines (RAM)], [Shepherdson & Sturgis (1963)],
    [Any general-purpose language], [(present day)],
  )
]

#Block(color: teal)[
  *Historical note:* Church and Turing independently proved these models equivalent in 1936. Their results also resolved Hilbert's Entscheidungsproblem: FOL validity is _not_ decidable.
]

== $lambda$-Calculus in a Nutshell

The $lambda$-calculus is a minimal language with just three constructs:

#definition[$lambda$-Calculus Syntax][
  $ M ::= x | (lambda x. M) | (M space N) $
  Variables, abstraction (function definition), and application (function call).
]

#example[
  - _Identity:_ $lambda x. x$ --- takes $x$, returns $x$.
  - _Application:_ $(lambda x. x) space y arrow.squiggly y$ --- $beta$-reduction.
  - _Church numeral_ $overline(2)$: $lambda f. lambda x. f(f(x))$ --- "apply $f$ twice".
]

Computation is #emph[$beta$-reduction]: $(lambda x. M) space N arrow.squiggly M[x := N]$ (substitute $N$ for $x$ in $M$).

#Block(color: yellow)[
  *Key insight:* Despite having no numbers, booleans, or loops, $lambda$-calculus can encode _all_ computable functions. This is the theoretical foundation of functional programming (Haskell, ML, Coq, Lean).
]


= From Theory to Practice

== Bridging Computability and Software Engineering

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 1em,
  [
    *Theory says:*
    - Program correctness is undecidable (Rice).
    - Halting is undecidable.
    - FOL validity is undecidable.
    - Full functional equivalence is undecidable.
  ],
  [
    *Practice responds:*
    - Sound approximation (abstract interpretation).
    - Decidable fragments (SMT theories).
    - Programmer annotations (Dafny, ACSL, JML).
    - Bounded verification (SAT, BMC, $k$-induction).
  ],
)

#v(0.5em)

#example[
  Dafny's approach combines decidable theories (linear arithmetic, arrays, sets) with programmer-supplied loop invariants and pre/postconditions to make verification _tractable_ for real programs.
]

#Block(color: yellow)[
  *The key message:* Undecidability is not a dead end --- it is a _design constraint_. Formal methods succeed by carefully choosing _what_ to verify and _how much_ automation to provide.
]

== Looking Ahead

#grid(
  columns: 3,
  column-gutter: 1.5em,
  [
    *Week 3: SAT*
    - NP-completeness
    - CDCL solvers
    - SAT encodings
  ],
  [
    *Week 6: SMT*
    - Decidable theories
    - DPLL(T) architecture
    - Theory combination
  ],
  [
    *Weeks 9--12: Dafny*
    - Annotations
    - Loop invariants
    - Verified programs
  ],
)

#v(0.5em)

Each step makes the _gap between theory and practice_ narrower: from "undecidable in general" to "verified for this specific program".


= Exercises

== Exercises: Decidability and Computability

+ Show that the language ${ angle.l M angle.r | M "accepts at least one string" }$ is recognizable but not decidable.

+ Using Rice's theorem, explain why each of the following is undecidable:
  - ${ angle.l M angle.r | cal(L)(M) = Sigma^* }$ (universality)
  - ${ angle.l M angle.r | cal(L)(M) "is context-free" }$
  - ${ angle.l M angle.r | |cal(L)(M)| = 42 }$

+ Construct a reduction from $"HALT"_"TM"$ to $"TOTAL"_"TM" = { angle.l M angle.r | M "halts on all inputs" }$ to prove $"TOTAL"_"TM"$ is undecidable.

+ Explain why Rice's theorem does _not_ apply to the property "M has fewer than 10 states." What kind of property is this?

+ $star$ The _Busy Beaver_ function $"BB"(n)$ = the maximum number of steps any halting TM with $n$ states can make. Argue that $"BB"$ grows faster than any computable function. _Hint:_ if $"BB"$ were computable, we could decide the halting problem.

+ $star$ Consider $lambda$-terms $I = lambda x. x$ and $Omega = (lambda x. x space x)(lambda x. x space x)$. \
  Show that $I$ has a normal form, but $Omega$ does not (i.e., $beta$-reduction does not terminate on $Omega$).

== Bibliography
#bibliography("refs.yml")
