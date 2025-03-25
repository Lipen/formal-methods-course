#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Specification and Verification",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

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

#let WP = $cal(W P)$
#let SP = $cal(S P)$

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
- _Post-conditions_ define what is _guaranteed_ to return when the precondition is met.

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

The program variables `x`, `y`, `a`, and `b`, together the method's _state_.

#note[
  Not all program variables are in scope the whole time.
]

== Floyd Logic

Let's propagate the precondition _forward_:

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

The last constructed condition _implies_ the required postcondition:
$
  (x >= 10) and (a = x + 3) and (b = 12) and (y = a + b) imply (y >= 25)
$

#pagebreak()

Now, let's go _backward_ starting with a postcondition at the last statement:

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

The last calculated condition is _implied_ by the given precondition:
$
  (x + 3 + 12 >= 25) implied (x >= 10)
$

== Exercise \#1

Consider a method with the type signature below which returns in `s` the sum of `x` and `y`, and in `m` the maximum of `x` and `y`:

```dafny
method MaxSum(x: int, y: int)
  returns (s: int, m: int)
  ensures ...
```

Write the postcondition specification for this method.

== Exercise \#2

Consider a method that attempts to reconstruct the arguments `x` and `y` from the return values of `MaxSum`.
In~other words, in other words, consider a method with the following type signature and the same postcondition as in Exercise~1:

```dafny
method ReconstructFromMaxSum(s: int, m: int)
  returns (x: int, y: int)
  requires ...
  ensures ...
```

This method cannot be implemented as is. \
Write an appropriate precondition for the method that allows you to implement it.

= Floyd-Hoare Logic

== From Contracts to Floyd-Hoare Logic


#[
  #let fig = grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Robert_W._Floyd", image("assets/Robert_Floyd.jpg", height: 3cm)),
    link("https://en.wikipedia.org/wiki/Tony_Hoare", image("assets/Tony_Hoare.jpg", height: 3cm)),

    [Robert Floyd], [Tony Hoare],
  )
  #let body = [
    In the design-by-contract methodology, contracts are usually assigned to procedures or modules.

    In general, it is possible to assign contracts to each statement of a program.

    A formal framework for doing this was developed by Tony Hoare, formalizing a reasoning technique by Robert Floyd.

    It is based on the notion of a _Hoare triple_.

    _Dafny_ is based on Floyd-Hoare Logic.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

== Hoare Triples

#definition[
  For predicates $P$ and $Q$, and a problem $S$, the Hoare triple ${P} S {Q}$ describes how the execution of a piece of code changes the state of the computation.

  It can be read as "if $S$ is started in any state that satisfies $P$, then $S$ will terminate (and does not crash) in a state that satisfies $Q$".
]

#examples[
  #block(spacing: 1em)[
    $
      { x = 1 } &quad x := 20 &quad& {x = 2} \
      { x < 18 } &quad y := 18 - x &quad& { y >= 0 } \
      { x < 18 } &quad y := 5 &quad& { y >= 0 } \
    $
  ]
]

#example(title: "Non-examples")[
  #block(spacing: 1em)[
    $
      { x < 18 } &quad x := y &quad& { y >= 0 }
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
      { x = 0 } &quad y := x + 3 &quad& { y < 100 } \
      { x = 0 } &quad y := x + 3 &quad& { x = 0 } \
      { x = 0 } &quad y := x + 3 &quad& { 0 <= x, y = 3 } \
      { x = 0 } &quad y := x + 3 &quad& { 3 <= y } \
      { x = 0 } &quad y := x + 3 &quad& { #`true` } \
    $
  ]
]

== Strongest Postcondition

Forward reasoning constructs the _strongest_ (i.e., _the most specific_) postcondition.

$
  { x = 0 } &quad y := x + 3 &quad& { 0 <= x and y = 3 }
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
      { x <= 70 } &quad y := x + 3 &quad& { y <= 80 } \
      { x = 65, y < 21 } &quad y := x + 3 &quad& { y <= 80 } \
      { x <= 77 } &quad y := x + 3 &quad& { y <= 80 } \
      { x dot x + y dot y <= 2500 } &quad y := x + 3 &quad& { y <= 80 } \
      { #`false` } &quad y := x + 3 &quad& { y <= 80 } \
    $
  ]
]

== Weakest Precondition

Backward reasoning constructs the _weakest_ (i.e., _the most general_) pre-condition.

$
  { x <= 77 } &quad y := x + 3 &quad& { y <= 80 }
$

#definition[
  $A$ is _weaker_ than $B$ if $B imply A$ is a valid formula.
]

== Weakest Precondition for Assignment

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
      { 25 <= x + 3 + 12 } &quad y := x + 3 &quad& { 25 <= a + 12 } \
      { x + 1 <= y } &quad y := x + 1 &quad& { x <= y } \
      { 3 dot 2 dot x + 5 y < 100 } &quad y := 2 dot x &quad& { 3 x + 5 y < 100 } \
    $
  ]
]

== Simultaneous Assignment

Dafny allows simultaneous assignment of multiple variables in a single statement.

#examples[
  #grid(
    columns: 2,
    gutter: 1em,
    [`x, y := 3, 10;`], [sets $x$ to $3$ and $y$ to $10$],
    [`x, y = x + y, x - y;`], [sets $x$ to the sum of $x$ and $y$ and $y$ to their difference],
  )
]

All right-hand sides are evaluated _before_ any variables are assigned.

#note[
  The last example is _different_ from the two statements `x = x + y; y = x - y;`
]

== Weakest Precondition for Simultaneous Assignment

#definition[
  The weakest pre-condition for a _simultaneous assignment_ $x_1, x_2 := E_1, E_2$ is constructed by replacing each $x_1$ with $E_1$ and each $x_2$ with $E_2$ in post-condition $Q$.
  $
    Q[x_1 := E_1, x_2 := E_2] &quad x_1, x_2 := E_1, E_2 quad { Q }
  $
]

#example[
  ```dafny
  // { x == X, y == Y }
  // { y == Y, x == X }
  x, y = y, x
  // { x == Y, y == X }
  ```
]

== Weakest Precondition for Variable Introduction

#note[
  The statement `var x := tmp;` is actually _two_ statements: `var x; x := tmp;`
]

What is true about $x$ in the post-condition, must have been true for all $x$ before the variable introduction.

$
  { forall x. thin Q } &quad #`var` x quad& { Q }
$

#examples[
  - ${ forall x. thin 0 <= x } quad #`var` x quad { 0 <= x }$
  - ${ forall x : #`int`. thin 0 <= x dot x } quad #`var` x quad { 0 <= x dot x }$
]

== Strongest Postcondition for Variable Introduction

Consider the Hoare triple ${ w < x, x < y } thick x := 100 thick { "?" }$.

Obviously, $x = 100$ is a post-condition, however it is _not the strongest_.

Something _more_ is implied by the pre-condition: there exists an $n$ such that $(w < n) and (n < y)$, which is equivalent to $w + 1 < y$.

In general:
$
  { P } quad x := E quad { exists n. thin P[x := n] and x = E[x := n] }
$

== $WP$ and $SP$

Let $P$ be a predicate on the pre-state of a program $S$ and let $Q$ be a predicate on the post-state of $S$.

$WP[S, Q]$ denotes the weakest precondition of $S$ w.r.t. $Q$.
- $WP[x := E, Q] = Q[x := E]$

$SP[S, P]$ denotes the strongest postcondition of $S$ w.r.t. $P$.
- $SP[x := E, P] = exists n. thin P[x := n] and x = E[x := n]$

== Control Flow

- Assignment: `x := E`
- Variable introduction: `var x`
- Sequential composition: `S ; T`
- Conditions: `if B { S } else { T }`
- Method calls: `r := M(E)`
- Loops: `while B { S }`

== Sequential Composition

$
  S ; T \
  { P } S { Q } T { R } \
  { P } S { Q } quad "and" quad { Q } T { R }
$

Strongest post-condition:
- Let $Q = SP[S, P]$
- $SP[#`S;T`, P] = SP[T, Q] = SP[T, SP[S, P]]$

Weakest pre-condition:
- Let $Q = WP[T, R]$
- $WP[#`S;T`, R] = WP[S, Q] = WP[S, WP[T, R]]$


== TODO
#show: cheq.checklist
- [ ] ...

== Bibliography
#bibliography("refs.yml")
