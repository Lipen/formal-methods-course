#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Specification and Verification",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

#show table.cell.where(y: 0): strong

#let Green(x) = {
  show emph: set text(green.darken(20%))
  text(x, green.darken(20%))
}
#let Red(x) = {
  show emph: set text(red.darken(20%))
  text(x, red.darken(20%))
}

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#let WPsym = $cal(W P)$
#let SPsym = $cal(S P)$

#let WP(S, Q) = $#WPsym bracket.stroked.l thin #S, #Q thin bracket.stroked.r$
#let SP(S, P) = $#SPsym bracket.stroked.l thin #S, #P thin bracket.stroked.r$

#let ITE(B, S, T) = $"if" #B "then" { #S } "else" { #T }$
#let WHILE(B, S) = $"while" #B "do" { #S }$

#set raw(syntaxes: "Dafny.sublime-syntax")

= Program Verification

#let my-program = [
  ```c
  x = 0;
  y = a;
  while (y > 0) {
      x = x + b;
      y = y - 1;
  }
  ```
]

== Motivation

Is this program _correct_?

#my-program

== Program Correctness

#note[
  A program can be _correct_ only with respect to a _specification_.
]

Is this program correct with respect to the following specification? #NO

_"Given integers $a$ and $b$, the program computes and stores in $x$ the product of $a$ and $b$."_

#pagebreak()

#note[
  A program can be _correct_ only with respect to a _specification_.
]

Is this program correct with respect to the following specification? #YES

_"Given *positive* integers $a$ and $b$, the program computes and stores in $x$ the product of $a$ and $b$."_

#my-program

== Design by Contract

Specification of a program can be seen as a _contract_:
- _Pre-conditions_ define what is _required_ to get a meaningful result.
- _Post-conditions_ define what is _guaranteed_ to return when the pre-condition is met.

#align(center)[
  #box[
    #set align(left)
    _requires_ $a$ and $b$ to be positive integers \
    _ensures_ $x$ is the product of $a$ and $b$
  ]
]

== Formal Verification

To formally verify a program you need:
- A formal specification (mathematical description) of the program.
- A formal proof that the specification is correct.
- Automated tools for verification and reasoning.
- Domain-specific expertise.

There are many tools and even specific languages for writing specs and verifying them.

One of them is _Dafny_, both a specification language and a program verifier.

Next, we are going to learn how to:
- _specify_ precisely what a program is supposed to do
- _prove_ that the specification is correct
- _verify_ that the program behaves as specified
- _derive_ a program from a specification
- use the _Dafny_ programming language and verifier

= Dafny

== Introduction to Dafny

```dafny
method Triple(x: int) returns (r: int)
  ensures r == 3 * x
{
  var y := 2 * x;
  r := x + y;
}
```

#note[
  The _caller_ does not need to know anything about the _implementation_ of the method, only its _specification_, which abstracts the method's behavior.
  The method is _opaque_ to the caller.
]

#pagebreak()

Completing the example:

```dafny
method Triple(x: int) returns (r: int)
  requires x >= 0
  ensures r == 3 * x
{
  var y := Double(x);
  r := x + y;
}

method Double(x: int) returns (r: int)
  requires x >= 0
  ensures r == 2 * x
```

*Exercise:* Fix the above code/spec to avoid `requires x >= 0` in the `Triple` method.

== Logic in Dafny

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: .8pt) },
  table.header[Dafny expression][Description],
  [`true`, `false`], [constants],
  [`!A`], ["not $A$"],
  [`A && B`], ["$A$ and $B$"],
  [`A || B`], ["$A$ or $B$"],
  [`A ==> B`], ["$A$ implies $B$" or "$A$ only if $B$"],
  [`A <==> B`], ["$A$ iff $B$"],
  [`forall x :: A`], ["for all $x$, $A$ is true"],
  [`exists x :: A`], ["there exists $x$ such that $A$ is true"],
)

Precedence order: `!`, `&&`, `||`, `==>`, `<==>`

== Verifying the Imperative Procedure

Below is the Dafny program for computing the maximum segment sum of an array.
Source:~@leino2017

#columns(2, gutter: 0pt)[
  #set text(size: 0.8em)
  #block(stroke: 0.4pt, inset: 1em, radius: 5pt)[
    ```dafny
    // find the index range [k..m) that gives the largest sum of any index range
    method MaxSegSum(a: array<int>)
      returns (k: int, m: int)
      ensures 0 ≤ k ≤ m ≤ a.Length
      ensures forall p, q ::
              0 ≤ p ≤ q ≤ a.Length ==>
              Sum(a, p, q) ≤ Sum(a, k, m)
    {
      k, m := 0, 0;
      var s, n, c, t := 0, 0, 0, 0;
      while n < a.Length
        invariant 0 ≤ k ≤ m ≤ n ≤ a.Length &&
                  s == Sum(a, k, m)
        invariant forall p, q ::
                  0 ≤ p ≤ q ≤ n ==> Sum(a, p, q) ≤ s
        invariant 0 ≤ c ≤ n && t == Sum(a, c, n)
        invariant forall b ::
                  0 ≤ b ≤ n ==> Sum(a, b, n) ≤ t
      {
        t, n := t + a[n], n + 1;
        if t < 0 {
          c, t := n, 0;
        } else if s < t {
          k, m, s := c, n, t;
        }
      }
    }

    // sum of the elements in the index range [m..n)
    function Sum(a: array<int>, m: int, n: int): int
      requires 0 ≤ m ≤ n ≤ a.Length
      reads a
    {
      if m == n then 0
      else Sum(a, m, n-1) + a[n-1]
    }
    ```
  ]
]

== Program State

```dafny
method MyMethod(x: int) returns (y: int)
  requires x >= 10
  ensures y >= 25
{
  var a := x + 3;
  var b := 12;
  y := a + b;
}
```

The program variables `x`, `y`, `a`, and `b` together form the method's _state_.

#note[
  Not all program variables are in scope the whole time.
]

== Floyd Logic

Let's propagate the pre-condition _forward_:

```dafny
method MyMethod(x: int) returns (y: int)
  requires x >= 10
  ensures y >= 25
{
  // here, we know x >= 10
  var a := x + 3;
  // here, x >= 10 && a == x+3
  var b := 12;
  // here, x >= 10 && a == x+3 && b == 12
  y := a + b;
  // here, x >= 10 && a == x+3 && b == 12 && y == a + b
}
```

The last constructed condition _implies_ the required post-condition:
$
  (x >= 10) and (a = x + 3) and (b = 12) and (y = a + b) imply (y >= 25)
$

#pagebreak()

Now, let's go _backward_ starting with a post-condition at the last statement:

```dafny
method MyMethod(x: int) returns (y: int)
  requires x >= 10
  ensures y >= 25
{
  // here, we want x + 3 + 12 >= 25
  var a := x + 3;
  // here, we want a + 12 >= 25
  var b := 12;
  // here, we want a + b >= 25
  y := a + b;
  // here, we want y >= 25
}
```

The last calculated condition is _implied_ by the given pre-condition:
$
  (x + 3 + 12 >= 25) <- (x >= 10)
$

== Exercise \#1

Consider a method with the type signature below which returns in `s` the sum of `x` and `y`, and in `m` the maximum of `x` and `y`:

```dafny
method MaxSum(x: int, y: int)
  returns (s: int, m: int)
  ensures ...
```

Write the post-condition specification for this method.

== Exercise \#2

Consider a method that attempts to reconstruct the arguments `x` and `y` from the return values of `MaxSum`.
In~other words, in other words, consider a method with the following type signature and _the same post-condition_ as in Exercise~1:

```dafny
method ReconstructFromMaxSum(s: int, m: int)
  returns (x: int, y: int)
  requires ...
  ensures ...
```

This method cannot be implemented as is. \
Write an appropriate pre-condition for the method that allows you to implement it.

= Floyd-Hoare Logic

== From Contracts to Floyd-Hoare Logic

#[
  #let fig = grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Robert_W._Floyd", image("assets/Robert_Floyd.jpg", height: 3cm)),
    link(
      "https://en.wikipedia.org/wiki/Tony_Hoare",
      box(clip: true, inset: (x: -8pt), image("assets/Tony_Hoare.jpg", height: 3cm)),
    ),

    [Robert Floyd], [Tony Hoare],
  )
  #let body = [
    In the design-by-contract methodology, contracts are usually assigned to procedures or modules.
    In general, it is possible to assign contracts to each statement of a program.

    A formal framework for doing this was developed by Tony Hoare @hoare1969, formalizing a reasoning technique introduced by Robert Floyd @floyd1967.

    It is based on the notion of a _Hoare triple_.

    _Dafny_ is based on Floyd-Hoare Logic.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

== Hoare Triples

#definition[
  For predicates $P$ and $Q$, and a problem $S$, the Hoare triple ${P} thick S thick {Q}$ describes how the execution of a piece of code changes the state of the computation.

  It can be read as "if $S$ is started in any state that satisfies $P$, then $S$ will terminate (and does not crash) in a state that satisfies $Q$".
]

#examples[
  #block(spacing: 1em)[
    $
       { x = 1 } & quad x := 20     & quad & { x = 20 } \
      { x < 18 } & quad y := 18 - x & quad & { y >= 0 } \
      { x < 18 } & quad y := 5      & quad & { y >= 0 } \
    $
  ]
]

#example(title: "Non-examples")[
  #block(spacing: 1em)[
    $
      { x < 18 } & quad x := y & quad & { y >= 0 }
    $
  ]
]

== Forward Reasoning

#definition[
  _Forward reasoning_ is a construction of a _post-condition_ from a given pre-condition.
]

#note[
  In general, there are _many_ possible post-conditions.
]

#examples[
  #block(spacing: 1em)[
    $
      { x = 0 } & quad y := x + 3 & quad & { y < 100 } \
      { x = 0 } & quad y := x + 3 & quad & { x = 0 } \
      { x = 0 } & quad y := x + 3 & quad & { 0 <= x, y = 3 } \
      { x = 0 } & quad y := x + 3 & quad & { 3 <= y } \
      { x = 0 } & quad y := x + 3 & quad & { #`true` } \
    $
  ]
]

== Strongest Post-condition

Forward reasoning constructs the _strongest_ (i.e., _the most specific_) post-condition.

$
  { x = 0 } & quad y := x + 3 & quad & { 0 <= x and y = 3 }
$

#definition[
  $A$ is _stronger_ than $B$ if $A imply B$ is a valid formula.
]

#definition[
  A formula is _valid_ if it is true for any valuation of its free variables.
]

== Backward Reasoning

#definition[
  _Backward reasoning_ is a construction of a _pre-condition_ for a given post-condition.
]

#note[
  Again, there are _many_ possible pre-conditions.
]

#examples[
  #block(spacing: 1em)[
    $
                        { x <= 70 } & quad y := x + 3 & quad & { y <= 80 } \
                 { x = 65, y < 21 } & quad y := x + 3 & quad & { y <= 80 } \
                        { x <= 77 } & quad y := x + 3 & quad & { y <= 80 } \
      { x dot x + y dot y <= 2500 } & quad y := x + 3 & quad & { y <= 80 } \
                       { #`false` } & quad y := x + 3 & quad & { y <= 80 } \
    $
  ]
]

== Weakest Pre-condition

Backward reasoning constructs the _weakest_ (i.e., _the most general_) pre-condition.

$
  { x <= 77 } & quad y := x + 3 & quad & { y <= 80 }
$

#definition[
  $A$ is _weaker_ than $B$ if $B imply A$ is a valid formula.
]

== Weakest Pre-condition for Assignment

#definition[
  The weakest pre-condition for an _assignment_ statement $x := E$ with a post-condition $Q$, is constructed by replacing each $x$ in $Q$ with $E$, denoted $Q[x := E]$.
  $
    { Q[x := E] } quad x := E quad { Q }
  $
]

#example[
  Given a Hoare triple ${ "?" } thick y := a + b thick { 25 <= y }$, we construct a pre-condition ${ 25 <= a + b }$.
]
#examples[
  #block(spacing: 1em)[
    $
      { 25 <= x + 3 + 12 } & quad a := x + 3   & quad & { 25 <= a + 12 } \
            { x + 1 <= y } & quad x := x + 1   & quad & { x <= y } \
       { 6 x + 5 y < 100 } & quad x := 2 dot x & quad & { 3 x + 5 y < 100 } \
    $
  ]
]

== Exercises

+ Explain rigorously why each of these Hoare triples holds:
  + ${ x = y } quad z := x - y quad { z = 0 }$
  + ${ "true" } quad x := 100 quad { x = 100 }$
  + ${ "true" } quad x := 2 y quad { x "is even" }$
  + ${ x = 89 } quad y := x - 34 quad { x = 89 }$
  + ${ x = 3 } quad x := x + 1 quad { x = 4 }$
  + ${ 0 <= x < 100 } quad x := x + 1 quad { 0 < x <= 100 }$

+ For each of the following Hoare triples, find the _strongest post-condition_:
  + ${ 0 <= x < 100 } quad x := 2 x quad { "?" }$ // { 0 < x <= 198 }
  + ${ 0 <= x <= y < 100 } quad z := y - x quad { "?" }$ // 0 <= z < 100
  + ${ 0 <= x < N } quad x := x + 1 quad { "?" }$ // 0 < x <= N

+ For each of the following Hoare triples, find the _weakest pre-condition_:
  + ${ "?" } quad b := (y < 10) quad { b imply (x < y) }$ // (y < 10) -> (x < y) === (y >= 10) or (y > x)
  + ${ "?" } quad x, y := 2 x, x+y quad { 0 <= x <= 100 && y <= x }$ // 0 <= x <= 50 and y <= x
  + ${ "?" } quad x := 2 y quad { 10 <= x <= y }$ // 10 <= 2y and 2 y <= y === y >= 5 and y <= 0 === false


== Swap Example

Consider the following program that swaps the values of $x$ and $y$ using a temporary variable.

```dafny
var tmp := x;
x := y;
y := tmp;
```

Let's prove that it indeed swaps the values, by performing the backward reasoning on it.
First, we need a way to refer to the initial values of $x$ and $y$ in the post-condition.
For this, we use _logical variables_ that stand for some values (initially, $x = X$ and $y = Y$) in our proof, yet cannot be used in the program itself.

#context [
  #let program = ```dafny
  // { x == X, y == Y }
  // { ? }
  var tmp := x;
  // { ? }
  x := y;
  // { ? }
  y := tmp
  // { y == Y, x == X }
  ```
  #place(dx: -1em)[
    #cetz.canvas({
      import cetz.draw: *
      line((0, 0), (0, measure(program).height + 2pt), mark: (end: "stealth"))
    })
  ]
  #program
]

== Simultaneous Assignment

Dafny allows simultaneous assignment of multiple variables in a single statement.

#examples[
  #grid(
    columns: 2,
    gutter: 1em,
    $x, y := 3, 10$, [sets $x$ to $3$ and $y$ to $10$],
    $x, y = x + y, x - y$, [sets $x$ to the sum of $x$, and $y$ and $y$ to their difference],
  )
]

All right-hand sides are evaluated _before_ any variables are assigned.

#note[
  The last example is _different_ from the two statements: ```dafny x = x + y; y = x - y;```
]

== Weakest Pre-condition for Simultaneous Assignment

#definition[
  The weakest pre-condition for a _simultaneous assignment_ $x_1, x_2 := E_1, E_2$ is constructed by replacing each $x_1$ with $E_1$ and each $x_2$ with $E_2$ in post-condition $Q$.
  $
    Q[x_1 := E_1, x_2 := E_2] & quad x_1, x_2 := E_1, E_2 quad { Q }
  $
]

#example[
  Going _backward_ in the following "swap" program:

  #context [
    #let program = ```dafny
    // { x == X, y == Y } -- initial state
    // { y == Y, x == X } -- weakest pre-condition
    x, y = y, x
    // { x == Y, y == X } -- final "swapped" state
    ```
    #place(dx: -1em)[
      #cetz.canvas({
        import cetz.draw: *
        line((0, 0), (0, measure(program).height + 2pt), mark: (end: "stealth"))
      })
    ]
    #program
  ]
]

== Weakest Pre-condition for Variable Introduction

#note[
  The statement ```dafny var x := tmp;``` is actually _two_ statements: ```dafny var x; x := tmp```.
]

What is true about $x$ in the post-condition, must have been true for all $x$ before the variable introduction.

$
  { forall x. thin Q } & quad #`var` x quad & { Q }
$

#examples[
  - ${ forall x. thin 0 <= x } quad #`var x` quad { 0 <= x }$
  - ${ forall x. thin 0 <= x dot x } quad #`var x` quad { 0 <= x dot x }$
]

== Strongest Post-condition for Assignment

Consider the Hoare triple
$
  { w < x, x < y } quad x := 100 quad { "?" }
$

Obviously, $x = 100$ is a post-condition, however it is _not the strongest_.

Something _more_ is implied by the pre-condition: there exists an $n$ such that $(w < n) and (n < y)$, which is equivalent to $w + 1 < y$.

In general:
$
  { P } quad x := E quad { exists n. thin P[x := n] and x = E[x := n] }
$

== Exercises

Replace the "?" in the following Hoare triples by computing _strongest post-conditions_.
+ ${ y = 10 } quad x := 12 quad { "?" }$ // { x = 12, y = 10 }
+ ${ 98 <= y } quad x := x + 1 quad { "?" }$ // { exists n. thin (98 <= y) and x = n + 1 } === { 98 <= y }
+ ${ 98 <= x } quad x := x + 1 quad { "?" }$ // { exists n. thin (98 <= x) and x = n + 1 }
+ ${ 98 <= y < x } quad x := 3 y + x quad { "?" }$ // { exists n. thin (98 <= y < x) and x = 3 y + n }

== $WPsym$ and $SPsym$

Let $P$ be a predicate on the _pre-state_ of a program $S$, and let $Q$ be a predicate on the _post-state_ of $S$.

$WP(S, Q)$ denotes the _weakest pre-condition_ of $S$ w.r.t. $Q$.
- $WP("var" x, Q) = forall x. thin Q$
- $WP(x := E, Q) = Q[x := E]$
- $WP((x_1, x_2 := E_1, E_2), Q) = Q[x_1 := E_1, x_2 := E_2]$

$SP(S, P)$ denotes the _strongest post-condition_ of $S$ w.r.t. $P$.
- $SP("var" x, P) = exists x. thin P$
- $SP(x := E, P) = exists n. thin P[x := n] and x = E[x := n]$

#exercise[
  Compute the following pre- and post-conditions:
  #columns(2)[
    - $WP(x := y, x + y <= 100)$
    - $WP(x := -x, x + y <= 100)$
    - $WP(x := x + y, x + y <= 100)$
    - $WP(z := x + y, x + y <= 100)$
    - $WP("var" x, x <= 100)$
    - $SP(x := 5, x + y <= 100)$
    - $SP(x := x + 1, x + y <= 100)$
    - $SP(x := 2 y, x + y <= 100)$
    - $SP(z := x + y, x + y <= 100)$
    - $SP("var" x, x <= 100)$
  ]
]

== Control Flow

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[Statement][Program],
  [Assignment], $x := E$,
  [Local variable], $"var" x$,
  [Composition], $S ; T$,
  [Condition], $ITE(B, S, T)$,
  [Assumption], $"assume" P$,
  [Assertion], $"assert" P$,
  [Method call], $r := M(E)$,
  [Loop], $WHILE(B, S)$,
)

== Sequential Composition

$
  S ; T \
  { P } thick S thick { Q } thick T thick { R } \
  { P } thick S thick { Q } quad "and" quad { Q } thick T thick { R }
$

Strongest post-condition:
- Let $Q = SP(S, P)$
- $SP((S ; T), P) = SP(T, Q) = SP(T, SP(S, P))$

Weakest pre-condition:
- Let $Q = WP(T, R)$
- $WP((S ; T), R) = WP(S, Q) = WP(S, WP(T, R))$

== Conditional Control Flow

#let condition-flow-diagram(P, B, nB, V, W, S, T, X, Y, Q) = {
  import fletcher: diagram, edge, node
  diagram(
    // debug: 3,
    node-corner-radius: 5pt,
    edge-stroke: 1pt,
    blob((0cm, 0cm), P, name: <p>, tint: green),
    blob((-1.5cm, -1.5cm), V, name: <v>, tint: green),
    blob((1.5cm, -1.5cm), W, name: <w>, tint: green),
    blob((-1.5cm, -3cm), S, name: <s>, tint: blue, shape: fletcher.shapes.circle),
    blob((1.5cm, -3cm), T, name: <t>, tint: blue, shape: fletcher.shapes.circle),
    blob((-1.5cm, -4.5cm), X, name: <x>, tint: green),
    blob((1.5cm, -4.5cm), Y, name: <y>, tint: green),
    blob((0cm, -6cm), Q, name: <q>, tint: green),
    edge(<p>, <v>, "-}>", $B$, label-pos: .8),
    edge(<p>, <w>, "-}>", $not B$, label-pos: .8),
    edge(<v>, <s>, "-"),
    edge(<w>, <t>, "-"),
    edge(<s>, <x>, "-}>"),
    edge(<t>, <y>, "-}>"),
    edge(<x>, <q>, "-}>"),
    edge(<y>, <q>, "-}>"),
  )
}

#grid(
  columns: (6cm, 1fr),
  align: (center, left),
  column-gutter: 2em,
  condition-flow-diagram(
    ${ P }$,
    $B$,
    $not B$,
    ${ V }$,
    ${ W }$,
    $S$,
    $T$,
    ${ X }$,
    ${ Y }$,
    ${ Q }$,
  ),
  [
    ${ P } quad ITE(B, S, T) quad { Q }$

    #v(1em)

    + $(P and B) imply V$
    + $(P and not B) imply W$
    + ${ V } thick S thick { X }$
    + ${ W } thick T thick { Y }$
    + $X imply Q$
    + $Y imply Q$
  ],
)

== Strongest Post-condition for Condition

#grid(
  columns: (6cm, 1fr),
  align: (center, left),
  column-gutter: 2em,
  condition-flow-diagram(
    ${ P }$,
    $B$,
    $not B$,
    ${ P and B }$, // V
    ${ P and not B }$, // W
    $S$,
    $T$,
    ${ X }$,
    ${ Y }$,
    ${ X or Y }$,
  ),
  [
    ${ P } quad ITE(B, S, T) quad { Q }$

    #v(1em)

    #place(
      dx: -2em,
      cetz.canvas({
        import cetz.draw: *
        line((0, 0), (0, -5), mark: (end: "stealth", scale: 2))
      }),
    )

    $V = P and B$ \
    $W = P and not B$

    #v(1em)

    $X = SP(S, P and B)$ \
    $Y = SP(T, P and not B)$

    #v(2em)

    $SP(ITE(B, S, T), P) = \
    = X or Y = \
    = SP(S, P and B) or SP(T, P and not B)$
  ],
)

== Weakest Pre-condition for Condition

#grid(
  columns: (6cm, 1fr),
  align: (center, left),
  column-gutter: 2em,
  condition-flow-diagram(
    ${ (B imply V) and (not B imply W) }$,
    $B$,
    $not B$,
    ${ V }$,
    ${ W }$,
    $S$,
    $T$,
    ${ Q }$, // X
    ${ Q }$, // Y
    ${ Q }$,
  ),
  [
    ${ P } quad ITE(B, S, T) quad { Q }$

    #v(1em)

    #place(
      dx: -2em,
      cetz.canvas({
        import cetz.draw: *
        line((0, 0), (0, -5), mark: (start: "stealth", scale: 2))
      }),
    )

    $WP(ITE(B, S, T), Q) = \
    = (B imply V) and (not B imply W) = \
    = (B imply WP(S, Q)) and (not B imply WP(T, Q))$

    #v(1em)

    $V = WP(S, Q)$ \
    $W = WP(T, Q)$

    #v(1em)

    $X = Q$ \
    $Y = Q$
  ],
)

== Example

#context [
  #let program = ```dafny
  // { x == 50 }
  // ... (see right)
  // { (x < 3 ==> x == 89) && (x >= 3 ==> x == 50) }
  if x < 3 {
    // { x == 89 }
    // { x + 1 + 10 == 100 }
    x, y := x + 1, 10;
    // { x + y == 100 }
  } else {
    // { x == 50 }
    // { x + x == 100 }
    y := x;
    // { x + y == 100 }
  }
  // { x + y == 100 }
  ```
  #place(dx: -1em)[
    #cetz.canvas({
      import cetz.draw: *
      line((0, 0), (0, measure(program).height + 2pt), mark: (end: "stealth"))
    })
  ]
  #program
]

#place(horizon + right)[
  $
          & ((x < 3) imply (x = 89)) and ((x >= 3) imply (x = 50)) equiv \
    equiv & ((x >= 3) or (x = 89)) and ((x < 3) or (x = 50)) equiv \
    equiv & ((x >= 3) and (x < 3)) or ((x >= 3) and (x = 50)) or \
          & or ((x = 89) and (x < 3)) or ((x = 89) and (x = 50)) equiv \
    equiv & (bot or (x = 50) or bot or bot) equiv \
    equiv & (x = 50)
  $
]

== Method Correctness

Given
```dafny
method M(x: Tx) returns (y: Ty)
  requires P
  ensures Q
{
  B
}
```
we need to prove $P imply WP(B, Q)$.

== Method Calls

Methods are _opaque_, i.e., we reason in terms of their _specifications_, not their implementations.

#example[
  Given the following definition (or rather, declaration):
  ```dafny
  method Triple(x: int) returns (y: int)
    ensures y == 3 * x
  ```
  we expect to be able to prove, for example, the following method call:
  $
    { #`true` } quad v := #`Triple`;(u + 4) quad { v = 3 dot (u + 4) }
  $
]

== Parameters

We need to _relate_ the _actual_ parameters (arguments of the method call) with the _formal_ parameters (of the method).

To avoid any name slashes, we first _rename_ the formal parameters to _fresh_ variables:

```dafny
method Triple(x1: int) returns (y1: int)
  ensures y1 == 3 * x1
```

Then, for a call ```dafny v := Triple(u + 1)``` we have:
```dafny
x1 := u + 1;
v := y1;
```

== Assumptions

The called can assume that the method's post-condition holds.

We introduce a new statement, ```dafny assume E```, to capture this:
$
  SP("assume" E, P) & = P and E \
  WP("assume" E, Q) & = E imply Q \
$

The semantics of ```dafny v := Triple(u + 1)``` is then given by
```dafny
var x1; var y1;
x1 := u + 1;
assume y1 == 3 * x1;
v := y1;
```

#place(right)[
  ```dafny
  method Triple(x1: int)
  returns (y1: int)
    ensures y1 == 3 * x1
  ```
]

== Weakest Pre-condition for Method Calls

```dafny
method M(x: X) returns (y: Y) ensures R[x, y]
```

#box[
  $
    & WP(r := M(E), Q) = \
    & = WP("var" x_E\; "var" y_E\; x_E := E\; "assume" R[x,y := x_E,y_r]\; r := y_r, Q) = \
    & = WP("var" x_E, WP("var" y_r, WP(x_E := E, WP("assume" R[x,y := x_E,y_r], WP(r := y_r, Q))))) = \
    & = WP("var" x_E, WP("var" y_r, WP(x_E := E, WP("assume" R[x,y := x_E,y_r], Q[r := y_r])))) = \
    & = WP("var" x_E, WP("var" y_r, WP(x_E := E, R[x,y := x_E,y_r] imply Q[r := y_r]))) = \
    & = WP("var" x_E, forall x_E. thin R[x,y := x_E,y_r] imply Q[r := y_r]) = \
    & = forall y_r. forall x_E. thin R[x,y := x_E,y_r] imply Q[r := y_r]
  $
]

Overall:
$
  WP(r := M(E), Q) = forall y_r. thin R[x,y := E,y_r] imply Q[r := y_r]
$
where $x$ is $M$'s input, $y$ is $M$'s output, and $R$ is $M$'s post-condition.

== Example

#example[
  ```dafny
  method Triple(x: int) returns (y: int)
    ensures y == 3 * x
  ```
  Consider calling this method with $Q = { v = 48 }$.
  Backward reasoning:
  #context [
    #let program = ```dafny
    // { u == 15 }
    // { 3 * (u + 1) == 48 }
    // { forall y1 :: y1 == 3 * (u + 1) ==> y1 == 48 }
    v := Triple(u + 1);
    // { v == 48 }
    ```
    #place(dx: -1em)[
      #cetz.canvas({
        import cetz.draw: *
        line((0, 0), (0, measure(program).height + 2pt), mark: (end: "stealth"))
      })
    ]
    #program
  ]
]

== Assertions

```dafny assert E``` does nothing when $E$ holds, otherwise it crashes the program.

```dafny
method Triple(x: int) returns (r: int)
{
  var y := 2 * x;
  r := x + y;
  assert r == 3 * x;
}
```

$
  SP("assert" E, P) & = P and E \
  WP("assert" E, Q) & = E and Q \
$

#note[
  Both $SPsym$ and $WPsym$ are conjunctions, contrary to ```dafny assume```!
]

== Method Calls with Pre-conditions

Given a method with a pre-condition:
```dafny
method M(x: X) returns (y: Y)
  requires P
  ensures R
```

The semantics of ```dafny r := M(E)``` is:
```dafny
var x_E; var y_r;
x_E := E;
assert P[x := x_E];
assume R[x,y := x_E,y_r];
r := y_r;
```

$
  WP(r := M(E), Q) = P[x := E] and forall y_r. thin R[x,y := E,y_r] imply Q[r := y_r]
$

== Function Calls

```dafny
function Average(a: int, b: int): int {
  (a + b) / 2
}
```

Differences from method calls:
- No output parameters, just a single output.
- The body is an _expression_, not a statement.
- Functions are _transparent_: we reason about them in terms of their definition by _unfolding_ it.

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    // debug: true,
    edge-stroke: 1pt,
    node-corner-radius: 3pt,
    spacing: 2em,
    blob((0, 0))[
      ```dafny
      method Triple(x: int) return (r: int)
        ensures r == 3 * x
      { r := Average(2*x, 4*x); }
      ```
    ],
    edge("-}>"),
    blob((.5, 1))[
      ```dafny
      method Triple(x: int) return (r: int)
        ensures r == 3 * x
      { r := (2*x + 4*x) / 2; }
      ```
    ],
  )
]

== Ghost Functions

In _Dafny_, functions are part of the _code_.

If you want to use a function in a _specification_, you need to use a _ghost function_.

```dafny
ghost function Average(a: int, b: int): int {
  (a + b) / 2
}
method Triple(x: int) returns (r: int)
  ensures r == Average(2*x, 4*x)
```

== Partial Expressions

An expression may be not always well-defined, e.g., $c slash d$ when $d$ evaluates to $0$.

Associated with such _partial expressions_ are _implicit assertions_.

#example[
  ```dafny
  assert d != 0 && v != 0;
  if c/d < u/v {
    assert 0 <= i < a.Length;
    x := a[i];
  }
  ```
]

Function may have pre-conditions, making calls to them _partial_.

#example[
  ```dafny
  function MinusOne(x: int): int
    requires 0 < x
  ```
  The call ```dafny z := MinusOne(y + 1)``` has an implicit assertion ```dafny assert 0 < y + 1```.
]

== Exercises

1. Suppose you want $x + y = 22$ to hold after the statement
  $
    "if" x < 20 "then" { y := 3 } "else" { y := 2 }
  $
  In which states can you start the statement?
  (Compute the weakest pre-condition.)

2. Compute the weakest pre-condition for the following statement with respect to $y < 10$. Simplify
  ```dafny
  if x < 8 {
    if x == 5 { y := 10; } else { y := 2; }
  } else {
    y := 0;
  }
  ```

#pagebreak()

3. Compute the weakest pre-condition for the following statement with respect to ```dafny y % 2 == 0```.

  ```dafny
  if x < 10 {
    if x < 20 { y := 1; } else { y := 2; }
  } else {
    y := 4;
  }
  ```

4. Compute the weakest pre-condition for the following statement with respect to ```dafny y % 2 == 0```.

  ```dafny
  if x < 8 {
    if x < 4 { x := x + 1; } else { y := 2; }
  } else {
    if x < 32 { y := 1; } else { }
  }
  ```

#pagebreak()

5. Determine under which circumstances the following program establishes $0 <= y < 100$.
  Try first to do that in your head.
  Write down the answer you come up with, and then write out the full computations to check that you got the right answer.

  ```dafny
  if x < 34 {
    if x == 2 { y := x + 1; } else { y := 233; }
  } else {
    if x < 55 { y := 21; } else { y := 144; }
  }
  ```

6. Which of the following Hoare-triple combinations are valid?
  + ${0 <= x} quad x := x + 1 quad { -2 <= x } quad y := 0 quad {-10 <= x}$
  + ${0 <= x} quad x := x + 1 quad { #`true` } quad x := x + 1 quad {2 <= x}$
  + ${0 <= x} quad x := x + 1; quad x := x + 1 quad {2 <= x}$
  + ${0 <= x} quad x := 3 x; quad x := x + 1 quad {3 <= x}$
  + ${x < 2} quad y := x + 5; quad x := 2 x quad {x < y}$

#pagebreak()

7. Compute the weakest pre-conditions with respect to the post-condition $x + y < 100$.
  + ```dafny x := 32; y := 40;```
  + ```dafny x := x + 2; y := y - 3 * x;```

8. Compute the weakest pre-conditions with respect to the post-condition $x < 10$.
  + ```dafny if x % 2 == 0 { y := y + 3; } else { y := 4; }```
  + ```dafny if y < 10 { y := x + y; } else { x := 8; }```

9. Compute the weakest pre-conditions with respect to the post-condition $x < 100$.
  + ```dafny assert y == 25;```
  + ```dafny assert 0 <= x;```
  + ```dafny assert x < 200;```
  + ```dafny assert x <= 100;```
  + ```dafny assert 0 <= x < 100;```

#pagebreak()

10. If $x_1$ does not appear in the desired post-condition Q$$, then prove that $x_1:= E; "assert" P[x := x_1]$ is the same as $P[x := E]$ by showing that the weakest pre-conditions of these two statements with respect to~$Q$ are the same.

11. What implicit assertions are associated with the following expressions?
  + ```dafny x / (y + z)```
  + ```dafny arr[2 * i]```
  + ```dafny MinusOne(MinusOne(y))```

12. What implicit assertions are associated with the following expressions?
  *Note:* the right-hand expression in a conjunction is only evaluated when the left-hand conjunction holds.
  + ```dafny a / b < c / d```
  + ```dafny a / b < 10 && c / d < 100```
  + ```dafny MinusOne(y) = 8 ==> arr[y] = 2```

= Recusion and Termination

== Recursive Methods

#text(size: 0.9em)[
  ```dafny
  method Double(x: int) returns (y: int)
    requires x >= 0
    ensures r == 2 * x
  {
    // { x != 0 ==> x > 0 }
    // { (x == 0) ==> (0 == 2 * x)  &&  (x != 0) ==> (x - 1 >= 0) }
    if x == 0 {
      // { 0 == 2 * x }
      y := 0;
      // { y == 2 * x }
    } else {
      // { forall t :: x - 1 >= 0 }
      var t;
      // { x - 1 >= 0  &&  forall r :: (r == 2 * (x - 1)) ==> (r + 2 == 2 * x) }
      t := Double(x - 1);
      // { t + 2 == 2 * x }
      y := t + 2;
      // { y == 2 * x }
    }
    // { y == 2 * x }
  }
  ```
]

#place(bottom + right, dy: -1em)[
  #fancy-box[
    #set align(left)
    _Recursive methods_ can be analyzed like any methods \ that call other methods... *if they terminate*.
  ]
]

== Problematic Recursion

```dafny
method BadDouble(x: int) returns (y: int)
  requires x >= 0
  ensures y == 2 * x
{
  var t := BadDouble(x - 1);  // Infinite recursion, does not terminate!
  y := t + 2;
}
```

#h(1em)

```dafny
method PartialIdentity(x: int) returns (y: int)
  ensures y == x
{
  if x % 2 == 2 {
    y := x;
  } else {
    y := PartialIdentity(x);  // Infinite recursion, does not terminate!
  }
}
```

== Avoiding Infinite Recursion

#box(stroke: 0.4pt, inset: 0.5em, radius: 3pt)[
  #set text(0.8em)
  ```dafny
  function Fib(n: nat): nat
    decreases n  // suggestion for Dafny
  {
    if n < 2 then n else Fib(n - 2) + Fib(n - 1)
  }
  ```
]
// TODO: fib tree

#h(3em)
#box(stroke: 0.4pt, inset: 0.5em, radius: 3pt)[
  #set text(0.8em)
  ```dafny
  function Ack(m: nat, n: nat): nat
    decreases m, n  // tuples can also be used
  {
    if m == 0 then n + 1
    else if n == 0 then Ack(m - 1, 1)
    else Ack(m - 1, Ack(m, n - 1))
  }
  ```
]

#h(6em)
#box(stroke: 0.4pt, inset: 0.5em, radius: 3pt)[
  #set text(0.8em)
  ```dafny
  function SeqSum(s: seq<int>, lo: nat, hi: nat): int
    requires 0 <= lo <= hi <= |s|
    decreases hi - lo  // complex expressions can be used!
  {
    if lo == hi then 0 else s[lo] + SeqSum(s, lo + 1, hi)
  }
  ```
]

== Exercises

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function F(x: int): int {
    if x < 10 then x else F(x - 1)
  }
  ```
]

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function G(x: int): int {
    if 0 <= x then G(x - 2) else x
  }
  ```
]

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function H(x: int): int {
    if x < -60 then x else H(x - 1)
  }
  ```
]

#pagebreak()

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function I(x: nat, y: nat): int {
    if x == 0 || y == 0 then 12
    else if x % 2 == y % 2 then I(x - 1, y)
  }
  ```
]

#box[
  #exercise[
    Write a ```dafny decreases``` clause that proves the termination of the following function:

    ```dafny
    function I(x: nat, y: nat): int {
      if x == 0 || y == 0 then 12
      else if x % 2 == y % 2 then I(x - 1, y)
    }
    ```
  ]
]

#pagebreak()

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function J(x: nat, y: nat): int {
    if x == 0 then y
    else if y == 0 then J(x - 1, 3)
    else J(x, y - 1)
  }
  ```
]

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function K(x: nat, y: nat, z: nat): int {
    if x < 10 || y < 5 then x + y
    else if z == 0 then K(x - 1, y, 5)
    else K(x, y - 1, z - 1)
  }
  ```
]

#pagebreak()

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function L(x: int): int {
    if x < 100 then L(x + 1) + 10 else x
  }
  ```
]

#exercise[
  The following function computes the _Hofstadter $G$ sequence_:

  ```dafny
  function G(n: nat): nat {
    if n == 0 then 0 else n - G(G(n - 1))
  }
  ```

  Find an appropriate ```dafny decreases``` clause to prove that $G$ terminates.
]

== Termination Metric

#definition[
  _Termination metrics_ in Dafny, which are declared by ```dafny decreases``` clauses, are lexicographic tuples of expressions.
  At each _recursive_ (or mutually recursive) call to a function or method, Dafny checks that the effective ```dafny decreases``` clause of the callee is _strictly smaller_ than the effective ```dafny decreases``` clause of the caller.
]

- _Termination metrics_ do not have to be natural numbers.
- Any set of values with a _well-founded order_ can be used.
- An order $succ$ is well-founded when:
  - $succ$ is _irreflexive_: $a succ a$ never holds
  - $succ$ is _transitive_: if $a succ b$ and $b succ c$ then $a succ c$
  - there is _no infinite descending chain_: $a_0 succ a_1 succ a_2 succ dots$

== Well-Founded Orders in Dafny

#align(center)[
  #table(
    columns: 2,
    align: (center, left),
    stroke: (x, y) => if y == 0 { (bottom: .8pt) },
    table.header[Type][$X succ y$ ("$X$ decreases to $y$") iff...],
    ```dafny bool```, [$X and not y$ \ (#true decreases to #false)],
    ```dafny int```, [$(y < X) and (0 <= X)$ \ (note: _negative_ integers are _not ordered_)],
    ```dafny real```, [$(y <= X - 1.0) and (0.0 <= X)$ \ (note: _negative_ reals are _not ordered_)],
    ```dafny set<T>```, [$y$ is a proper subset of $X$ \ (e.g. ```dafny {a,b,c} > {a,c}```)],
    ```dafny seq<T>```, [$y$ is a consecutive proper sub-sequence of $X$ \ (e.g., ```dafny [a,b,c] > [b,c]```)],
    [inductive \ datatypes], [$y$ is structurally included in $X$ \ (e.g. ```dafny Cons(42, Cons(5, Nil)) > 5```)],
  )
]

== Exercises

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function M(x: int, b: bool): int {
    if b then x else M(x + 25, true)
  }
  ```
]

#exercise[
  Write a ```dafny decreases``` clause that proves the termination of the following function:

  ```dafny
  function N(x: int, y: int, b: bool): int {
    if x <= 0 || y <= 0 then
      x + y
    else if b then
      N(x, y + 3, !b)
    else
      N(x - 1, y, true)
  }
  ```
]


== Lexicographic Tuples

#definition[
  The _lexicographic order_ on tuples is a component-wise comparison where earlier components are treated as more significant.
]

#examples[
  - ```dafny 4, 12 > 4, 2 > 3, 5256``` (first component is more significant)
  - ```dafny 4, 12 > 4, 12, 365, 0``` (_shorter_ tuples exceed, _if prefixes are equal_)
  - ```dafny 2, 5 > 1``` (prefix ```dafny 2``` exceeds ```dafny 1```)
  - ```dafny 12, true, 1.9 > 12, false, 57.3```
]

#exercise[
  Determine if the first tuple exceeds the second.
  #grid(
    columns: 2,
    column-gutter: 4em,
    [
      + ```dafny 2,5``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 1,7```
      + ```dafny 1,7``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 7,1```
      + ```dafny 5,0,8``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 4,93```
      + ```dafny 4,9,3``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 4,93```
      + ```dafny 4,93``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 4,9,3```
    ],
    [
      6. ```dafny 3``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 2,9```
      + ```dafny true,80``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny false,66```
      + ```dafny true,2``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 19,1```
      + ```dafny 4,true,50``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 4,false,800```
      + ```dafny 7.0,{3,4,9},false,10``` #box(stroke: .1pt, width: 1.2em, height: .8em, baseline: 1pt) ```dafny 7.0,{3,9},true,10```
    ],
  )
]

== Ackermanm Function

```dafny
function Ack(m: nat, n: nat): nat
  decreases m, n
{
  if m == 0 then
    n + 1
  else if n == 0 then
    Ack(m - 1, 1)
  else
    Ack(m - 1, Ack(m, n - 1))
}
```

On each recursive call, the ordered pair $(m, n)$ decreases.

== Mutually Recursive Functions

```dafny
method StudyPlan(n: nat)
  requires n <= 40
  decreases 40 - n
{
  if n == 40 { /* done */ }
  else {
    var hours := RequiredStudyTime(n);
    Learn(n, hours);
  }
}

method Learn(n: nat, h: nat)
  requires n < 40
  decreases 40 - n, h
{
  if h == 0 { StudyPlan(n + 1); }
  else { Learn(n, h - 1); }
}
```

#place(bottom + right, dy: -1em)[
  #set align(top)
  #table(
    columns: 2,
    align: (right, left),
    stroke: (x, y) => if y == 0 { (bottom: .8pt) },
    table.header[Call][Proof obligation for termination],
    [`StudyPlan` calls `Learn`], [$40 - n succ (40-n, h)$ \ ($40-n$ is a proper prefix of $(40-n, h)$)],
    [`Learn` calls `StudyPlan`], [$(40 - n, h) succ 40 - (n+1)$ \ (first component is decreased)],
    [`Learn` calls `Learn`], [$(40 - n, h) succ (40 - n, h - 1)$ \ (second component is decreased)],
  )
]

== Exercises

#exercise[
  Add ```dafny decreases``` clauses to prove termination of the following program.

  ```dafny
  method Outer(a: nat) {
    if a != 0 {
      var b := RequiredStudyTime(a - 1);
      Inner(a, b);
    }
  }

  method Inner(a: nat, b: nat)
    requires 1 <= a
  {
    if b == 0 {
      Outer(a - 1);
    } else {
      Inner(a, b - 1);
    }
  }
  ```
]

#pagebreak()

#exercise[
  Add ```dafny decreases``` clauses to prove termination of the following program.

  ```dafny
  method Outer(a: nat) {
    if a != 0 {
      var b := RequiredStudyTime(a - 1);
      Inner(a - 1, b);
    }
  }

  method Inner(a: nat, b: nat) {
    if b == 0 {
      Outer(a);
    } else {
      Inner(a, b - 1);
    }
  }
  ```
]

= Loops

== Loops in Dafny

```dafny
while G
  decreases M
  invariant J
{
  Body
}
```

- $G$ is the _loop guard_, a Boolean expression
- $M$ is the _termination measure_, an expression that _decreases_ in each iteration
- $J$ is the _loop invariant_, a condition that _holds_ in each iteration

#note[
  While loops are _opaque_, they are always abstracted by their invariant.

  ```dafny
  ...
  while G
    invariant J
    // Look ma, no body!
  ...
  ```
]

== Examples

```dafny
while x < 300
  invariant x % 2 == 0
```

```dafny
while x % 2 == 1
  invariant 0 <= x <= 100
```

```dafny
x := 2;
while x < 50
  invariant x % 2 == 0
// After the loop, the invariant and
// the negation of the guard hold:
assert x >= 50 && x % 2 == 0;
```

```dafny
x := 0;
while x % 2 == 0
  invariant 0 <= x <= 20
assert x == 19; // not provable!
```

== Attaining Equality

```dafny
i := 0;
while i != 100
  invariant 0 <= i <= 100
assert i == 100;
```

Assertion is provable from just the negation of the guard.

#v(1em)

```dafny
i := 0;
while i < 100
  invariant 0 <= i <= 100
assert i == 100;
```

Assertion requires the invariant _and_ the negation of the guard to hold.

#pagebreak()

```dafny
i := 0;
while i != 100
  invariant true  // note!
assert i == 100;
```

Assertion is provable from just the negation of the guard.

#v(1em)

```dafny
i := 0;
while i < 100
  invariant true  // note!
assert i == 100;  // not provable
```

Assertion requires the invariant _and_ the negation of the guard to hold.

== Relations Between Variables

```dafny
x, y := 0, 0;
while x < 300
  invariant 2 * x == 3 * y;
assert 200 <= y;
```

#v(1em)

```dafny
x, y := 0, 191;
while !(y < 7)
  invariant 0 <= y && 7 * x + y == 191
assert x == 191 / 7 && y == 191 % 7;
```

#v(1em)

```dafny
n, s := 0, 0;
while n != 33
  invariant s == n * (n - 1) / 2
assert s == 33 * 32 / 2;
```

== Hoare Triples for Loops

```dafny
// { J }
while G
  invariant J
// { J && !G }
```

#example[
  ```dafny
  r := 0;
  N := 104;
  while (r+1)*(r+1) <= N
    invariant 0 <= r && r*r <= N
  assert 0 <= r && r*r <= N < (r+1)*(r+1);
  ```
]

== Floyd-Hoare Logic for Loop Body

To prove the _partial_ correctness of a loop
```dafny
while G
  invariant J
{
  Body
}
```
we need to prove the validity of
```dafny
// { J && G }
Body
// { J }
```

== Example: Quotient Modulus

Let's write a program (using a loop) that computes the quotient and modulus of 191 and 7.

Here is the specification:

```dafny
  x, y := 0, 191;
  while !(y < 7)
    invariant 0 <= y && 7*x + y == 191
  {
    // { 0 <= y && 7*x + y == 191 && 7 <= y }
    // ... body?
    // { 0 <= y && 7*x + y == 191 }
  }
  assert x == 191 / 7 && y == 191 % 7;
```

#pagebreak()

```dafny
x, y := 0, 191;
while !(y < 7)
  invariant 0 <= y && 7*x + y == 191
{
  // { 0 <= y && 7*x + y == 191 && 7 <= y }
  // { 0 <= y - 7 && 7*x + 7 + (y - 7) == 191 }
  y := y - 7;
  // { 0 <= y && 7*x + 7 + y == 191 }
  // { 0 <= y && 7*(x + 1) + y == 191 }
  x := x + 1;
  // { 0 <= y && 7*x + y == 191 }
}
assert x == 191 / 7 && y == 191 % 7;
```

== Leap to the Answer

There's more than one way to implement the loop body for the quotient-modulus program.

```dafny
x, y := 0, 191;
while !(y < 7)
  invariant 0 <= y && 7*x + y == 191
{
  // { 0 <= y && 7*x + y == 191 && 7 <= y }
  // { true }
  // { 0 <= 2 && 7*27 + 2 == 191 }
  x, y := 27, 2;
  // { 0 <= y && 7*x + y == 191 }
}
assert x == 191 / 7 && y == 191 % 7;
```

== Going Twice as Fast

Let's dwell on this first program with a loop body some more, to consider something that _does not work_.
How about we try to combine two loop bodies into one?
Instead of incrementing $x$ by 1 and decrementing $y$ by 7, let's try incrementing $x$ by 2 and decrementing $y$ by 14.

```dafny
  // { 0 <= y && 7*x + y == 191 && 7 <= y }
  // { 14 <= y && 7 * x + 2 == 191 } -- error: does not follow from above!
  // { 0 <= 14 - y && 7*(x + 2) + (y - 14) == 191 }
  x, y := x + 2, y - 14;
  // { 0 <= y && 7*x + y == 191 }
```

Here, ```dafny 14 <= y``` does not follow from the top line, so this loop body is not correct.

#exercise[
  Introduce an ```dafny if``` statement in the body of the loop, where one branch is ```dafny x, y := x + 2, y - 14``` and the other is ```dafny x, y := x + 1, y - 7```.
  What guard condition do you need in the ```dafny if``` statement to make the loop correct?
]

== Loop Termination

To prove the _total_ correctness of a loop
```dafny
  while G
    invariant J
    decreases D
  {
    Body
  }
```
we also need to prove the validity of
```dafny
  // { J && G }
  ghost var d := D;
  Body
  // { d > D }
```

#note[
  ```dafny ghost``` variables are for reasoning only, they are not part of the compiled code.
]

== Termination of the Quotient-Modulus Program

```dafny
var x, y := 0, 191;
while 7 <= y
  invariant 0 <= y && 7 * x + y == 191
  decreases y
{
  y := y - 7;
  x := x + 1;
}
```

#v(1em)

```dafny
// { 0 <= y && 7 * x + y == 191 && 7 <= y }
ghost var d := y;
y := y - 7;
x := x + 1;
// { d > y && d >= 0 }
//   -- {d > y} follows from y := y - 7
//   -- {d >= 0} follows from 0 <= y in invariant
```

== Quick Body

```dafny
var x, y := 0, 191;
while 7 <= y
  invariant 0 <= y && 7 * x + y == 191
  decreases y
{
  y := 2;
  x := 27;
}

// { 0 <= y && 7 * x + y == 191 && 7 <= y }
ghost var d := y;
y := 2;
x := 27;
// { d > y && d >= 0 }
//   -- {d > y} follows from 7 <= y in invariant
//   -- {d >= 0} follows from 0 <= y in invariant
```

== Default ```dafny decreases``` Clauses for Loops in Dafny

If the loop guard is an arithmetic comparison of the form ```dafny E < F``` or ```dafny E <= F```, then the default is
```dafny
  decreases F – E
```

If the loop guard is an arithmetic comparison of the form ```dafny E != F```, then the default is the absolute difference between ```dafny E``` and ```dafny F```:
```dafny
  decreases if E < F then F - E else E - F
```

== Complete Loop Rule

```dafny
// { J }
while G
  invariant J
  decreases D
{
  Body
}
// { J && !G }
```

#v(1em)

```dafny
// { J && G }
ghost var d := D;
Body
// { J && d > D }
```

== Computing Sums

```dafny
while n != 33
  invariant s == n * (n - 1) / 2
{
  // { s == n * (n - 1) / 2 && n != 33 }
  // { s == n * (n - 1) / 2 }
  s := s + n;
  // { s = n * (n - 1) / 2 + n }
  // { s = (n*n – n) / 2 + 2*n / 2 }
  // { s == (n*n – n + 2*n) / 2 }
  // { s == (n*n + n) / 2 }
  // { s == (n + 1) * n / 2 }
  // { s == (n + 1) * (n + 1 - 1) / 2 }
  n := n + 1;
  // { s == n * (n - 1) / 2 }
}
assert s == 33 * 32 / 2;
```

== Full Program

Need to choose initial values of ```dafny n``` and ```dafny s``` to establish invariant.

```dafny
  n, s := 0, 0;
  while n != 33
    invariant s == n * (n - 1) / 2
  {
    s := s + n;
    n := n + 1;
  }
```

#exercise[
  Write a different (but still correct) initializing assignment for the loop above.
]

#exercise[
  Write an initializing assignment and a loop implementation for the following loop specifications:
  #grid(
    columns: 2,
    column-gutter: 1cm,
    ```dafny
      x := ???;
      while x < 300
        invariant x % 2 == 0
      { ??? }
    ```,
    ```dafny
      x := ???;
      while x % 2 == 1
        invariant 0 <= x <= 100
      { ??? }
    ```,
  )
]

#pagebreak()

#exercise[
  Consider the following program fragment:

  ```dafny
    x := 0;
    while x < 100
    {
      x := x + 3;
    }
    assert x == 102;
  ```

  Write a loop invariant that holds initially, is maintained by the loop body, and allows you to prove the assertion after the loop.
]

== Integer Square Root

#definition[Loop design technique 1 --- _"Omit a conjuct"_][
  For a post-condition ```dafny A && B```, use ```dafny A``` as the invariant and ```dafny !B``` as the guard.
  That is, use a loop specification:
  ```dafny
  while !B
    invariant A
  ```
]

```dafny
method SquareRoot(N: nat) returns (r: nat)
  ensures r*r <= N && N < (r+1)*(r+1)
{
  r := 0;
  while (r+1)*(r+1) <= N
    invariant r*r <= N
  { r := r + 1; }
}
```

== More Efficient Algorithm

Rather than calculate ```dafny (r + 1)*(r + 1)``` on each iteration, add a new variable ```dafny s``` and maintain the invariant
```dafny
s == (r + 1)*(r + 1)
```

Then we have ```dafny s``` initially 1, loop guard ```dafny s <= N``` and invariant ```dafny s == (r + 1)*(r + 1)```.

```dafny
// { s == (r + 1)*(r + 1) }
// { s + 2*r + 3 == (r + 1)*(r + 1) + 2*r + 3 }
s := s + 2*r + 3;
// { s == (r + 1)*(r + 1) + 2*r + 3}
// { s == r*r + 2*r + 1 + 2*r + 3 }
// { s == r*r + 4*r + 4}
// { s == (r + 1 + 1)*(r + 1 + 1)}
r := r + 1
// { s == (r + 1)*(r + 1) }
```

== Full Program

```dafny
method SquareRoot(N: nat) returns (r: nat)
  ensures r*r <= N < (r+1)*(r+1)
{
  r := 0;
  var s := 1;
  while s <= N
    invariant r*r <= N
    invariant s == (r+1)*(r+1)
  {
    s := s + 2*r + 3;
    r := r + 1;
  }
}
```


== TODO
#show: cheq.checklist
- [ ] ...

== Bibliography
#bibliography("refs.yml")
