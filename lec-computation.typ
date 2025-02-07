#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Theory of Computation",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

= Computability

== Computable functions

#definition([Church--Turing thesis])[
  _Computable functions_ are exactly the functions that can be calculated using a mechanical (that is, automatic) calculation device given unlimited amounts of time and storage space.
]

#quote[
  _Every model of computation that has ever been imagined can compute _only_ computable functions, and _all_ computable functions can be computed by any of several _models of computation_ that are apparently very different, such as Turing machines, register machines, lambda calculus and general recursive functions._
]

For example, a partial function $f : NN^k arrow.hook NN$ is _computable_ ("can be calculated") if there exists a computer program with the following properties:
- If $f(x)$ is defined, then the program terminates on the input $x$ with the value $f(x)$ stored in the computer memory.
- If $f(x)$ is undefined, then the program never terminates on the input $x$.

== Effective procedures

#definition[
  An *effective procedure* is a finite, deterministic, mechanical algorithm that guarantees to terminate and produce the correct answer in a finite number of steps.
]

= Decidability

== Decidable sets

#definition([Decidable set])[
  Given a universal set $cal(U)$, a set $S subset.eq cal(U)$ is *decidable* (or *computable*) if there exists a computable function $f : cal(U) to {0,1}$ such that $f(x) = 1$ iff $x in S$.
]

#example(title: [Examples])[
  - The set of all WFFs is decidable.
    - _We can check if a given string is well-formed by recursively verifying the syntax rules._

  - For a given finite set $Gamma$ of WFFs, the set ${alpha | Gamma models alpha}$ of all tautological consequences of $Gamma$ is decidable.
    - _We can decide $Gamma models alpha$ using a truth table algorithm by enumerating all possible interpretations (at~most~$2^abs(Gamma)$) and checking if each satisfies all formulas in $Gamma$._

  - The set of all tautologies is decidable. \
    - _It is the set of all tautological consequences of the empty set._
]

TODO: undecidable sets (existence proof)

== Semi-decidability

Suppose we want to determine $Gamma models alpha$ where $Gamma$ is infinite.
In general, it is undecidable.

However, it is possible to obtain a weaker result.

#definition([Semi-decidable set])[
  A set $S$ is *computably enumerable* if there is an _enumeration procedure_ which lists, in some order, every member of $S$: $s_1, s_2, s_3 dots$

  Equivalently, a set $S$ is *semi-decidable* if there is an algorithm such that the set of inputs for which the algorithm halts is exactly $S$.
]

Note that if $S$ is infinite, the enumeration procedure will _never_ finish, but every member of $S$ will be listed _eventually_, after some finite amount of time.

*Some properties:*
- Decidable sets are closed under union, intersection, Cartesian product, and complement.
- Semi-decidable sets are closed under union, intersection, and Cartesian product.

#pagebreak()

#theorem[
  A set $S$ is computably enumerable iff it is semi-decidable.
] <enumerable>

#proof([(*$arrow.double.r$*)])[
  If $S$ is computably enumerable, we can check if $alpha in S$ by enumerating all members of $S$ and checking if $alpha$ is among them.
  If it is, we answer "yes"; otherwise, we continue enumerating.
  Thus, if $alpha in S$, the procedure produces "yes".
  If $alpha notin S$, the procedure runs forever.
]
#proof([(*$arrow.double.l$*)])[
  On the other hand, suppose we have a procedure $P$ which, given $alpha$, terminates and produces "yes" iff $alpha in S$.
  To show that $S$ is computably enumerable, we can proceed as follows.
  + Construct a systematic enumeration of *all* expressions (for example, by listing all strings over the alphabet in length-lexicographical order): $beta_1, beta_2, beta_3, dots$
  + Break the procedure $P$ into a finite number of "steps" (for example, by program instructions).
  + Run the procedure on each expression in turn, for an increasing number of steps (see #link("https://en.wikipedia.org/wiki/Dovetailing_(computer_science)")[dovetailing]):
    - Run $P$ on $beta_1$ for 1 step.
    - Run $P$ on $beta_1$ for 2 steps, then on $beta_2$ for 2 steps.
    - ...
    - Run $P$ on each of $beta_1, dots, beta_n$ for $n$ steps each.
    - ...
  + If $P$ produces "yes" for some $beta_i$, output (yield) $beta_i$ and continue enumerating.

  This procedure will eventually list all members of $S$.
]

#pagebreak()

#theorem[
  A set is decidable iff both it and its complement are semi-decidable.
]

#proof[
  Alternate between running the procedure for the set and the procedure for its completement.
  One of them will eventually produce "yes".
]

#pagebreak()

#theorem[
  If $Sigma$ is an effectively enumerable set of WFFs, then the set ${alpha | Sigma models alpha}$ of tautological consequences of $Sigma$ is effectively enumerable.
]

#proof[
  Consider an enumeration of the elements of $Sigma$: $sigma_1, sigma_2, sigma_3, dots$

  By the compactness theorem, $Sigma models alpha$ iff ${sigma_1, dots, sigma_n} models alpha$ for some $n$.

  Hence, it is sufficient to successively test:
  - $emptyset models alpha$
  - ${sigma_1} models alpha$
  - ${sigma_1, sigma_2} models alpha$
  - $dots$

  If any of these tests succeeds (each is decidable), then $Sigma models alpha$.

  This demonstrates that there is an effective procedure that, given any WFF $alpha$, will output "yes" iff $alpha$ is a tautological consequence of $Sigma$.
  Thus, the set of tautological consequences of $Sigma$ is effectively enumerable.
]

== Complexity

TODO

== TODO

#show: cheq.checklist

- [x] Computability
- [x] Decidability
- [ ] Undecidable sets
- [x] Semi-decidability
- [ ] Complexity classes
- [ ] NP-completeness
- [ ] Polytime reductions
- [ ] Cook theorem
