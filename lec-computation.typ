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

== Computable Functions

#definition([Church--Turing thesis])[
  _Computable functions_ are exactly the functions that can be calculated using a mechanical (that is, automatic) calculation device given unlimited amounts of time and storage space.
]

#quote[
  _Every model of computation that has ever been imagined can compute _only_ computable functions, and _all_ computable functions can be computed by any of several _models of computation_ that are apparently very different, such as Turing machines, register machines, lambda calculus and general recursive functions._
]

#example[
  A partial function $f : NN^k arrow.hook NN$ is _computable_ ("can be calculated") if there exists a computer program with the following properties:
  - If $f(x)$ is defined, then the program terminates on the input $x$ with the value $f(x)$ stored in the computer memory.
  - If $f(x)$ is undefined, then the program never terminates on the input $x$.
]

== Effective Procedures

#definition[
  An *effective procedure* is a finite, deterministic, mechanical algorithm that guarantees to terminate and produce the correct answer in a finite number of steps.
]

= Decidability

== Decidable Sets

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

== Undecidable Sets

#definition([Undecidable set])[
  A set $S$ is *undecidable* if it is not decidable.
]

#example[
  The existence of undecidable sets of expressions can be shown as follows.

  An algorithm is completely determined by its _finite_ description.
  Thus, there are only _countably many_ effective procedures.
  But there are uncountably many sets of expressions.
  (Why? The set of expressions is countably infinite. Therefore, its power set is uncountable.)
  Hence, there are _more_ sets of expressions than there are possible effective procedures.
]

= Semi-decidability

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

== Enumerability and Semi-decidability

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

== Dual Enumerability and Decidability

#theorem([Kleene])[
  A set is decidable iff both it and its complement are semi-decidable.
]

#proof([(*$arrow.double.r$*)])[
  _If $A$ is decidable, then both $A$ and its complement $overline(A)$ are effectively enumerable._

  Since $A$ is decidable, there exists an effective procedure $P$ that halts on all inputs and returs "yes" if $alpha in A$ and "no" otherwise.

  To enumerate $A$:
  - Systematically generate all expressions $alpha_1, alpha_2, alpha_3, dots$
  - For each $alpha_i$, run $P$. If $P$ outputs "yes", yield $alpha_i$. Otherwise, continue.

  Similarly, enumerate $overline(A)$ by yielding $alpha_i$ when $P$ outputs "no".

  Both enumerations are effective, since $P$ always halts, so $A$ and its complement are semi-decidable.
]

#pagebreak()

#proof([(*$arrow.double.l$*)])[
  _If $A$ and $overline(A)$ are effectively enumerable, then $A$ is decidable._

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

= Complexity Zoo

== Complexity Classes

TODO

See also: https://complexityzoo.net/Petting_Zoo

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
