#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Specification and Verification",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

= Dafny

== Dafny

Dafny is a programming language with a program verifier.

== Verifying the Imperative Procedure

Below is the Dafny program for computing the maximum segment sum of an array.
Source:~@leino2017

#columns(2)[
  #set text(size: 0.8em)
#block(stroke: 0.4pt, inset: 1em, radius: 5pt)[
  ```dafny
  // find the index range [k..m) that gives the largest sum of any index range
  method MaxSegSum(a: array<int>) returns (k: int, m: int)
    ensures 0 ≤ k ≤ m ≤ a.Length
    ensures forall p, q :: 0 ≤ p ≤ q ≤ a.Length ==> Sum(a, p, q) ≤ Sum(a, k, m)
  {
    k, m := 0, 0;
    var s, n, c, t := 0, 0, 0, 0;
    while n < a.Length
      invariant 0 ≤ k ≤ m ≤ n ≤ a.Length &&
                s == Sum(a, k, m)
      invariant forall p, q :: 0 ≤ p ≤ q ≤ n ==>
                               Sum(a, p, q) ≤ s
      invariant 0 ≤ c ≤ n && t == Sum(a, c, n)
      invariant forall b :: 0 ≤ b ≤ n ==>
                            Sum(a, b, n) ≤ t
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
    if m == n then 0 else Sum(a, m, n-1) + a[n-1]
  }
  ```
]]

== TODO

- [ ] Syntax
- [ ] ...

== Bibliography
#bibliography("refs.yml")
