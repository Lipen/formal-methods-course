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
- _Preconditions_ define what is _required_ to get a meaningful result.
- _Postconditions_ define what is _guaranteed_ to return when the precondition is met.

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
  (x gt.eq 10) and (a = x + 3) and (b = 12) and (y = a + b) imply (y gt.eq 25)
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
  (x + 3 + 12 >= 25) implied (x gt.eq 10)
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

    It is based on the notion of a Hoare triple.

    Dafny is based on Floyd-Hoare Logic.
  ]
  #wrap-it.wrap-content(fig, body, align: top + right)
]

== Hoare Triples

#definition[
  For predicates $P$ and $Q$, and a problem $S$, the Hoare triple ${P} S {Q}$ describes how the execution of a piece of code changes the state of the computation.

  It can be read as "if $S$ is started in any state that satisfies $P$, then $S$ will terminate (and does not crash) in a state that satisfies $Q$".
]

#examples[
  $
    { x = 1 } &quad x := 20 &quad {x = 2} \
    { x < 18 } &quad y := 18 - x &quad { y gt.eq 0 } \
    { x < 18 } &quad y := 5 &quad { y gt.eq 0 } \
  $
]

*Non-example*: ${ x < 18 } quad x := y quad { y gt.eq 0 }$


== TODO
#show: cheq.checklist
- [ ] ...

== Bibliography
#bibliography("refs.yml")
