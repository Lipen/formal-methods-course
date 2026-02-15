#import "theme2.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "First-Order Logic",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
)

#import "common-lec.typ": *

#show table.cell.where(y: 0): strong

// Packages
#import curryst: prooftree, rule
#import frederic: assume, fitch, premise, step, subproof

// Custom operators
#let FV = math.op("FV")
#let Vars = math.op("Vars")
#let dom = math.op("dom")


// ═══════════════════════════════════════════════════════════════════════
//  INTRODUCTION
// ═══════════════════════════════════════════════════════════════════════

= Introduction to FOL

== Motivation

#fancy-box(tint: yellow)[
  Propositional logic (PL) is not powerful enough for many applications.
]

- PL cannot reason about _natural numbers_ directly.
- PL cannot reason about _infinite_ domains.
- PL cannot express _abstract_ properties.
- PL cannot represent the _internal structure_ of propositions.
- PL lacks _quantifiers_ for generalization.

First-order logic (FOL) _extends_ propositional logic by adding _variables_, _predicates_, _functions_, and _quantifiers_, providing a structured way to reason about objects, their properties, and relationships.

Unlike propositional logic, which is limited to fixed truth values for statements, FOL allows complex expressions like "All humans are mortal" ($forall x. thin "Human"(x) imply "Mortal"(x)$) or "There exists a solution to the problem" ($exists x. thin "Solution"(x)$).

#example[
  Consider _"every even number greater than 2 is a sum of two primes"_ (Goldbach's conjecture).
  PL would need a separate proposition $G_4, G_6, G_8, dots$ for each even number.
  FOL expresses it as a single formula:
  $ forall n. thin (n > 2 and "Even"(n)) imply exists p, q. thin ("Prime"(p) and "Prime"(q) and n = p + q) $
]

== What is First-Order Logic?

Similar to PL, first-order logic is a formal system with a _syntax_ and _semantics_.

#fancy-box(tint: green)[
  First-order logic is an umbrella term for different _first-order languages_.
]

Syntax of a logic consists of _symbols_ and _rules_ for combining them into _well-formed formulas_ (WFFs).

Symbols of a first-order language are divided into _logical symbols_ and _non-logical parameters_.

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Logical symbols*:
    - Parentheses: $($, $)$
    - Logical connectives: $not$, $and$, $or$, $imply$, $iff$
    - Variables: $x$, $y$, $z$, $dots$
    - Quantifiers: $forall$ and $exists$
  ],
  [
    *Parameters*:
    - Equality: $=$
    - Constants: e.g. $bot$, $0$, $emptyset$, $dots$
    - Predicates: e.g. $P(x)$, $Q(x, y)$, $x > y$, $A subset B$
    - Functions: e.g. $f(x)$, $g(x, y)$, $x + y$
  ],
)

#note[
  For connectives, just $and$ and $not$ are enough.
  The others can be expressed in terms of them.
]
#note[
  For quantifiers, just $forall$ is enough, since $exists x. thin phi$ can be expressed as $not forall x. thin not phi$.
]

== Predicates and Functions

Predicates are used to express properties or relations among objects.

Functions are similar to predicates but return a value, not necessarily a truth value.

Each predicate and function symbol has a fixed _arity_ (number of arguments).
- Equality is a special predicate with arity 2.
- Constants can be seen as functions with arity 0.

== First-Order Languages

A first-order language is specified by its _parameters_.

#grid(
  columns: 3,
  column-gutter: 2em,
  [
    *Propositional logic*:
    - Equality: _no_
    - Constants: _none_
    - Predicates: $A_1$, $A_2$, $dots$
    - Functions: _none_
  ],
  [
    *Set theory*:
    - Equality: _yes_
    - Constants: $emptyset$
    - Predicates: $in$
    - Functions: _none_
  ],
  [
    *Number theory*:
    - Equality: _yes_
    - Constants: $0$
    - Predicates: $<$
    - Functions: $S$ (successor), $+$, $times$
  ],
)


// ═══════════════════════════════════════════════════════════════════════
//  SYNTAX
// ═══════════════════════════════════════════════════════════════════════

= FOL Syntax

== Signatures

#definition[Signature][
  A _first-order signature_ $Sigma = angle.l cal(F), cal(R) angle.r$ consists of:
  - A set of _function symbols_ $cal(F)$, each with an arity $n gt.eq 0$.
  - A set of _relation symbols_ (predicates) $cal(R)$, each with an arity $n gt.eq 1$.

  Functions of arity 0 are _constants_. We assume a countably infinite set of _variables_ $cal(V) = {x, y, z, x_1, x_2, dots}$.
]

#example[
  *Arithmetic:* $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$ \
  where $0$ is a constant, $S$ is unary, $+, times$ are binary functions; $<, =$ are binary relations.
]
#example[
  *Graph theory:* $Sigma = angle.l emptyset, {"Edge", "Path"} angle.r$ \
  where $"Edge"$ and $"Path"$ are binary predicates (no function symbols).
]

== Terms and Formulas

#definition[Term][
  _Terms_ over signature $Sigma$ are defined inductively:
  - Every variable $x in cal(V)$ is a term.
  - If $f in cal(F)$ has arity $n$ and $t_1, dots, t_n$ are terms, then $f(t_1, dots, t_n)$ is a term.
]

#definition[Formula][
  _Formulas_ over $Sigma$ are defined inductively:
  - If $R in cal(R)$ has arity $n$ and $t_1, dots, t_n$ are terms, then $R(t_1, dots, t_n)$ is an _atomic formula_ (atom).
  - If $phi, psi$ are formulas: $not phi$, $(phi and psi)$, $(phi or psi)$, $(phi imply psi)$, $(phi iff psi)$ are formulas.
  - If $phi$ is a formula and $x in cal(V)$: $forall x. thin phi$ and $exists x. thin phi$ are formulas.
]

#example[
  $forall x. thin (x = 0 or exists y. thin S(y) = x)$ --- "every natural number is $0$ or a successor."
]

== Free and Bound Variables

The _scope_ of $forall x$ (or $exists x$) is the immediately following subformula.

#definition[Free Variables][
  The set $FV(phi)$ of _free variables_ of $phi$ is defined inductively:
  - $FV(R(t_1, dots, t_n)) = Vars(t_1) union dots union Vars(t_n)$
  - $FV(not phi) = FV(phi)$; #h(1em) $FV(phi circle.small psi) = FV(phi) union FV(psi)$ for $circle.small in {and, or, imply, iff}$
  - $FV(forall x. thin phi) = FV(exists x. thin phi) = FV(phi) setminus {x}$
]

A formula with no free variables is a _sentence_ (closed formula).

#example[
  In $forall x. thin P(x, y)$: $x$ is _bound_ (in scope of $forall x$), $y$ is _free_. Not a sentence.
]

#note[
  Only _sentences_ have a definite truth value in a structure.
  Formulas with free variables are like "open predicates" --- they become true/false once you fix values for the free variables.
]

== Substitution

#definition[Substitution][
  $phi[t \/ x]$ denotes the formula obtained by replacing every _free_ occurrence of $x$ with term $t$.

  A substitution $[t \/ x]$ is _capture-free_ in $phi$ if no free variable in $t$ becomes bound.
]

#example[
  $forall y. thin (x < y) thin [S(0) \/ x] = forall y. thin (S(0) < y)$ --- correct substitution.

  $exists y. thin (x < y) thin [y + 1 \/ x] = exists y. thin (y + 1 < y)$ --- *variable capture!* \
  The free $y$ in the substituted term becomes bound.
  Fix: rename bound variable first: $exists z. thin (y + 1 < z)$.
]

#Block(color: orange)[
  *Variable capture:* Always check for name clashes before substituting.
  Rename bound variables if necessary.
]


// ═══════════════════════════════════════════════════════════════════════
//  SEMANTICS
// ═══════════════════════════════════════════════════════════════════════

= FOL Semantics

== Structures (Models)

#definition[Structure (Model)][
  A _structure_ $frak(A)$ for signature $Sigma = angle.l cal(F), cal(R) angle.r$ consists of:
  - A non-empty _domain_ (universe) $A$ --- the set of objects we reason about.
  - For each $n$-ary function symbol $f in cal(F)$: a function $f^frak(A) : A^n to A$.
  - For each $n$-ary relation symbol $R in cal(R)$: a relation $R^frak(A) subset.eq A^n$.

  A _variable assignment_ $sigma : cal(V) to A$ maps each variable to a domain element.
]

#example[
  For the arithmetic signature $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$:
  - $frak(N) = (NN, 0, S, +, times, <, =)$ --- the _standard_ (intended) model.
  - $frak(Z) = (ZZ, 0, S, +, times, <, =)$ --- a different, equally valid structure.
  - The sentence $forall x. thin exists y. thin x = S(y) or x = 0$ is true in $frak(N)$ (every natural number is 0 or a successor) but _false_ in $frak(Z)$ (take $x = -1$: it is not $0$ and not a successor of any integer under the standard successor).

  This illustrates a key point: the same sentence can be true in one structure and false in another.
  _Validity_ means truth in _all_ structures.
]

== Evaluating FOL Formulas

Given a structure $frak(A)$ and a variable assignment $sigma$, truth is defined inductively.
The key ingredient compared to PL: quantifiers range over domain elements.

#definition[Satisfaction Relation][
  The relation $frak(A), sigma models phi$ is defined inductively:
  - $frak(A), sigma models R(t_1, dots, t_n)$ iff $(t_1^(frak(A),sigma), dots, t_n^(frak(A),sigma)) in R^frak(A)$
  - Boolean connectives: as in PL.
  - $frak(A), sigma models forall x. thin phi$ iff $frak(A), sigma[x |-> a] models phi$ for _every_ $a in A$.
  - $frak(A), sigma models exists x. thin phi$ iff $frak(A), sigma[x |-> a] models phi$ for _some_ $a in A$.

  Here $sigma[x |-> a]$ maps $x$ to $a$ and agrees with $sigma$ on all other variables.
]

For _sentences_ (no free variables), the truth value depends only on the structure: we write $frak(A) models phi$.

#example[
  Let $frak(A) = ({1, 2, 3}, scripts(<)^frak(A) = {(1,2),(1,3),(2,3)})$ be a structure for signature ${<}$.

  Evaluate $forall x. thin exists y. thin x < y$ in $frak(A)$:
  - $x = 1$: need $y$ with $1 < y$.  Take $y = 2$. #YES
  - $x = 2$: need $y$ with $2 < y$.  Take $y = 3$. #YES
  - $x = 3$: need $y$ with $3 < y$.  No such $y$ in ${1, 2, 3}$. #NO

  Result: $frak(A) models.not forall x. thin exists y. thin x < y$. The formula is _falsified_ by the element $3$.

  But $forall x. thin exists y. thin x < y$ _is_ satisfied in $frak(N) = (NN, <)$ --- for every $n$, take $y = n + 1$.
]

== Validity and Satisfiability in FOL

#definition[
  Let $phi$ be an FOL sentence.
  - $phi$ is _valid_ ($models phi$) if $frak(A) models phi$ for _every_ structure $frak(A)$.
  - $phi$ is _satisfiable_ if $frak(A) models phi$ for _some_ structure $frak(A)$.
  - $phi$ is _unsatisfiable_ if no structure satisfies it.
]

#Block(color: orange)[
  *Critical difference from PL:*
  - In PL, the space of interpretations is _finite_ ($2^n$ truth assignments).
  - In FOL, structures can have _infinite_ domains of _any_ cardinality --- decision procedures are fundamentally harder, sometimes even impossible (undecidable).
]

#example[
  - $forall x. thin (P(x) or not P(x))$ --- valid (instance of LEM, holds in every structure).
  - $forall x. thin P(x) and exists x. thin not P(x)$ --- unsatisfiable.
  - $exists x. thin P(x)$ --- satisfiable (in any non-empty structure with $P$ non-empty) but not valid.
]

== Quantifier Equivalences

Many useful equivalences govern quantifiers:

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 0.5em,
  [
    *De Morgan duality for quantifiers:*
    - $not forall x. thin phi equiv exists x. thin not phi$
    - $not exists x. thin phi equiv forall x. thin not phi$

    *Distribution:*
    - $forall x. thin (phi and psi) equiv (forall x. thin phi) and (forall x. thin psi)$
    - $exists x. thin (phi or psi) equiv (exists x. thin phi) or (exists x. thin psi)$
  ],
  [
    *Vacuous quantification* (if $x$ not free in $psi$):
    - $forall x. thin psi equiv psi$, #h(1em) $exists x. thin psi equiv psi$

    *Commutativity of like quantifiers:*
    - $forall x. thin forall y. thin phi equiv forall y. thin forall x. thin phi$
    - $exists x. thin exists y. thin phi equiv exists y. thin exists x. thin phi$

    *Prenex pulling* (if $x$ not free in $psi$):
    - $psi and forall x. thin phi equiv forall x. thin (psi and phi)$
    - $psi or exists x. thin phi equiv exists x. thin (psi or phi)$
  ],
)

#pagebreak()

#Block(color: orange)[
  $exists x. thin forall y$ is generally _stronger_ than $forall y. thin exists x$ --- the former asserts a _single_ $x$ for _all_ $y$.
]

#example[
  Let $R(x, y) equiv$ "$x$ is the parent of $y$". Then:
  - $exists x. thin forall y. thin R(x, y)$ = "someone is the parent of _everyone_" --- false.
  - $forall y. thin exists x. thin R(x, y)$ = "everyone _has_ a parent" --- true.

  In general: $exists forall models forall exists$, but $forall exists models.not exists forall$.
]

== Prenex Normal Form

#definition[Prenex Normal Form (PNF)][
  A formula is in _prenex normal form_ if it has the shape:
  $ Q_1 x_1. thin Q_2 x_2. thin dots thin Q_n x_n. thin psi $
  where each $Q_i in {forall, exists}$ and $psi$ is _quantifier-free_ (the _matrix_).
]

#theorem[
  Every FOL formula can be converted to an equivalent formula in PNF (after renaming bound variables to avoid capture if necessary).
]

#example[
  $forall x. thin P(x) imply exists y. thin Q(x, y)$ \
  $equiv forall x. thin (not P(x) or exists y. thin Q(x, y))$ #h(1em) _(eliminate $imply$)_ \
  $equiv forall x. thin exists y. thin (not P(x) or Q(x, y))$ #h(1em) _(pull $exists y$ out)_
]

PNF separates the _quantifier prefix_ (alternation structure) from the _propositional skeleton_ (matrix). \
The alternation depth ($forall exists forall dots$) determines complexity.


// ═══════════════════════════════════════════════════════════════════════
//  PROOFS
// ═══════════════════════════════════════════════════════════════════════

= FOL Proofs

== FOL Proof Rules: Quantifiers

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *$forall$-introduction* ($forall$i): \
    Derive $phi(y)$ for an _arbitrary_ $y$. \
    Conclude $forall x. thin phi(x)$.

    #fitch(
      step(1, $phi(y)$, rule: [$dots.v$ ($y$ arbitrary)]),
      step(2, $forall x. thin phi(x)$, rule: [$forall$i 1]),
    )

    *$exists$-introduction* ($exists$i): \
    From $phi(t)$ for some term $t$, conclude $exists x. thin phi(x)$.

    #fitch(
      premise(1, $phi(t)$),
      step(2, $exists x. thin phi(x)$, rule: [$exists$i 1]),
    )
  ],
  [
    *$forall$-elimination* ($forall$e): \
    From $forall x. thin phi(x)$, conclude $phi(t)$ for _any_ term $t$.

    #v(-0.5em)
    #fitch(
      premise(1, $forall x. thin phi(x)$),
      step(2, $phi(t)$, rule: [$forall$e 1]),
    )

    *$exists$-elimination* ($exists$e): \
    From $exists x. thin phi(x)$, open a subproof assuming $phi(y)$ for _fresh_~$y$, derive $psi$. Conclude $psi$.

    #place[
      #v(1em)
      #fitch(
        premise(1, $exists x. thin phi(x)$),
        subproof(
          assume(2, $phi(y)$, rule: [$y$ fresh]),
          step(3, $dots.v$),
          step(4, $psi$, rule: [$dots.v$]),
        ),
        step(5, $psi$, rule: [$exists$e 1, 2--4]),
      )
    ]
  ],
)

#pagebreak()

*Side conditions:*
- $forall$i: $y$ must be _arbitrary_ --- not free in any undischarged assumption.
- $forall$e: $t$ can be any term (universal _instantiation_).
- $exists$i: give a _witness_ term $t$.
- $exists$e: $y$ must be _fresh_ --- not free in $psi$ or any undischarged assumption besides $phi(y)$.

== FOL Proof: A Complete Fitch Example

#example[
  *Prove:* $forall x. thin (P(x) imply Q(x)), thin exists x. thin P(x) entails exists x. thin Q(x)$

  _"If every $P$ is a $Q$, and some $P$ exists, then some $Q$ exists."_

  #align(center)[
    #grid(
      columns: 2,
      align: left,
      column-gutter: 2em,
      [
        #fitch(
          premise(1, $forall x. thin (P(x) imply Q(x))$),
          premise(2, $exists x. thin P(x)$),
          subproof(
            assume(3, $P(a)$, rule: [$a$ fresh]),
            step(4, $P(a) imply Q(a)$, rule: [$forall$e 1]),
            step(5, $Q(a)$, rule: [$imply$e 3, 4]),
            step(6, $exists x. thin Q(x)$, rule: [$exists$i 5]),
          ),
          step(7, $exists x. thin Q(x)$, rule: [$exists$e 2, 3--6]),
        )
      ],
      [
        Line 3: open $exists$e subproof --- name the witness $a$ (fresh). \
        Line 4: instantiate $forall x. thin (P(x) imply Q(x))$ with $a$ ($forall$e). \
        Line 5: modus ponens on lines 3 and 4. \
        Line 6: from $Q(a)$, existentially generalize ($exists$i). \
        Line 7: close $exists$e --- the conclusion $exists x. thin Q(x)$ does not mention~$a$, so it survives.
      ],
    )
  ]
]

== Semantic Arguments for FOL

Semantic tableaux rules extend to FOL with rules for quantifiers:

#align(horizon)[
  #grid(
    columns: 3,
    column-gutter: 1fr,
    [
      #prooftree(
        rule(
          label: [(a)],
          $cal(I) models.not alpha$,
          $cal(I) models not alpha$,
        ),
      )
      #prooftree(
        rule(
          label: [(b)],
          $cal(I) models alpha$,
          $cal(I) models.not not alpha$,
        ),
      )
      #prooftree(
        rule(
          label: [(c)],
          [$cal(I) models alpha$, $cal(I) models beta$],
          $cal(I) models alpha and beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(d)],
          [$cal(I) models.not alpha$ | $cal(I) models.not beta$],
          $cal(I) models.not alpha and beta$,
        ),
      )
    ],
    [
      #prooftree(
        rule(
          label: [(e)],
          [$cal(I) models alpha$ | $cal(I) models beta$],
          $cal(I) models alpha or beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(f)],
          [$cal(I) models.not alpha$, $cal(I) models.not beta$],
          $cal(I) models.not alpha or beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(i)],
          $cal(I) models bot$,
          $cal(I) models alpha$,
          $cal(I) models.not alpha$,
        ),
      )
    ],
    [
      #prooftree(
        rule(
          label: [(g)],
          [$cal(I) models.not alpha$ | $cal(I) models beta$],
          $cal(I) models alpha imply beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(h)],
          [$cal(I) models alpha$, $cal(I) models.not beta$],
          $cal(I) models.not alpha imply beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(j)],
          [$cal(I) models alpha$, $cal(I) models beta$ | $cal(I) models.not alpha$, $cal(I) models.not beta$],
          $cal(I) models alpha iff beta$,
        ),
      )
      #prooftree(
        rule(
          label: [(k)],
          [$cal(I) models.not alpha$, $cal(I) models beta$ | $cal(I) models alpha$, $cal(I) models.not beta$],
          $cal(I) models.not alpha iff beta$,
        ),
      )
    ],
  )
]


// ═══════════════════════════════════════════════════════════════════════
//  METATHEOREMS
// ═══════════════════════════════════════════════════════════════════════

= Metatheorems and \ the Limits of Logic

== FOL Soundness and Completeness

#theorem[Gödel's Completeness Theorem (1930)][
  FOL with standard proof rules is both _sound_ and _complete_:
  $ Gamma entails phi quad iff quad Gamma models phi $
]

#proof[
  _(Soundness.)_
  Each rule preserves truth: if premises hold in $frak(A)$, so does the conclusion.

  _(Completeness, sketch.)_
  If $Gamma entails.not phi$, then $Gamma union {not phi}$ is consistent.
  Extend to a maximally consistent set $Gamma^*$ (Lindenbaum's lemma).
  Add Henkin witnesses for existential formulas.
  Build a canonical model from equivalence classes of closed terms.
  This model satisfies $Gamma union {not phi}$, so $Gamma models.not phi$.
  Contrapositive gives the result.
]

#Block(color: yellow)[
  _Not_ the "incompleteness theorem" --- here "complete" means the proof system derives everything semantically true in _all_ structures.
]

== FOL Validity is Undecidable

Despite completeness, there is _no algorithm_ that always terminates and correctly decides FOL validity.

#theorem[Church--Turing Theorem (1936)][
  The validity problem for FOL is _undecidable_:
  no Turing machine can decide, given an arbitrary FOL sentence $phi$, whether $models phi$.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Decidable (PL):*
    - Finite search space ($2^n$ interpretations)
    - Truth tables always terminate
    - SAT is NP-complete, VALID is co-NP-complete
  ],
  [
    *Undecidable (FOL):*
    - Infinite/unbounded structures
    - Proof search may not terminate
    - Valid = semi-decidable (r.e.)
    - Satisfiable = semi-decidable (co-r.e.)
  ],
)

#Block(color: green)[
  FOL validity is *semi-decidable*: if $phi$ is valid, proof search _will_ find a proof (by completeness).
  If $phi$ is not valid, search may run forever.
]

SMT solvers restrict to _decidable fragments_ of FOL --- theories where satisfiability _can_ be decided.

== The Compactness Theorem

#theorem[Compactness Theorem][
  A (possibly infinite) set of FOL sentences $Gamma$ is satisfiable if and only if every _finite_ subset of $Gamma$ is satisfiable.
]

#proof[(sketch)][
  ($arrow.double.r$) Trivial: any model of $Gamma$ satisfies every finite subset.

  ($arrow.double.l$) If $Gamma$ is unsatisfiable, then by completeness there is a proof of $bot$ from $Gamma$.
  Every proof uses only _finitely many_ premises, so some finite $Gamma_0 subset.eq Gamma$ is already unsatisfiable.
]

#example[
  *Non-standard models of arithmetic:*
  Let $Gamma = op("Th")(NN) union {c > 0, c > 1, c > 2, dots}$ where $c$ is a fresh constant.
  Every finite subset is satisfiable (interpret $c$ as a large enough number).
  By compactness, $Gamma$ is satisfiable --- in a model with an "infinite" element $c$ larger than all standard naturals. This is a _non-standard model_ of arithmetic.
]

#Block(color: blue)[
  If a specification has a bug (is unsatisfiable), some _finite_ subset of constraints already witnesses it --- this is why _bounded model checking_ works: check finitely many constraints at a time.
]

== The Löwenheim--Skolem Theorem

#theorem[Löwenheim--Skolem Theorem][
  If an FOL sentence (or countable set of sentences) has an _infinite_ model, then it has a model of _every_ infinite cardinality.
]

#v(-0.5em)
#Block(color: teal)[
  *Skolem's paradox (1922):* ZFC proves uncountable sets exist, yet by Löwenheim--Skolem, ZFC has a _countable_ model.
  Resolution: "uncountable" is _relative_ to the model's membership relation.
]
#v(-0.5em)

Expressive limitations of FOL (compactness + Löwenheim--Skolem):
- Cannot define "exactly the natural numbers" (up to isomorphism).
- Cannot express "the domain is finite" or "the domain is countable."
- Cannot distinguish between structures of different infinite cardinalities.

These limitations motivate _stronger_ logics (second-order, infinitary) and _decidable_ fragments (monadic FOL, EPR, SMT theories).

#place[
  #v(0.5em)
  #Block(color: orange)[
    You cannot write an FOL spec that pins down "exactly the integers." \
    SMT solvers work around this by _fixing_ the interpretation of theory symbols ($+$, $times$, $<$) --- they reason about a _specific_ structure, not all possible models.
  ]
]

== Gödel's Incompleteness Theorems

_Completeness_ (above): "if $phi$ is true in _all_ structures, it is provable."
_Incompleteness_ (below): "if we fix _one_ structure ($NN$), some true sentences are unprovable."
These concern different questions.

#v(-0.5em)
#theorem[First Incompleteness Theorem][
  Any _consistent_ formal system $cal(T)$ capable of expressing elementary arithmetic contains sentences that are _true_ (in the standard model $NN$) but _unprovable_ in $cal(T)$.
]

#v(-0.5em)
#theorem[Second Incompleteness Theorem][
  If $cal(T)$ is consistent and sufficiently powerful, then $cal(T)$ _cannot prove its own consistency_:
  $ cal(T) tack.r.not op("Con")(cal(T)) $
]
#v(-0.5em)

#note(title: "Sufficiently powerful")[
  $cal(T)$ must be capable of representing all computable functions --- essentially, $cal(T)$ must contain Robinson arithmetic ($Q$) or stronger.
]

#place[
  #v(1em)
  #Block(color: orange)[
    Gödel's _completeness_ theorem: FOL proof systems are complete w.r.t. semantic consequence.
    His _incompleteness_ theorems: specific _theories_ (like arithmetic) have true-but-unprovable sentences.
    Different notions of "completeness"!
  ]
]

== Incompleteness: The Key Idea

The proof relies on _self-reference_, made mathematically precise via Gödel numbering.

Every formula, proof, and syntactic operation is encoded as a natural number.
There is an arithmetic formula $"Prov"(n)$ saying "$n$ is the Gödel number of a provable sentence."
Construct a sentence $G$:

$ G quad equiv quad #[$quote.l$I am not provable in $cal(T)$$quote.r$] $

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *If $G$ is provable in $cal(T)$:*
    - $cal(T)$ proves $G$
    - $G$ says "$G$ is not provable"
    - So $cal(T)$ proves something false
    - Contradicts _consistency_ of $cal(T)$
  ],
  [
    *If $G$ is not provable:*
    - $G$'s assertion is _true_
    - So $G$ is true but unprovable
    - $cal(T)$ is _incomplete_
  ],
)

#Block(color: blue)[
  Incompleteness means _no_ verification system can prove _all_ true program properties.
  In practice, automated tools are remarkably effective for _specific_ programs.
]

== The Landscape of Logics

Classical PL and FOL are two points in a rich space of formal systems.
Different verification tasks need different logics:

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, color, ..args) = blob(
    pos,
    label,
    shape: rect,
    tint: color,
    ..args.named(),
  )
  #diagram(
    spacing: (4em, 1.5em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 2pt,

    vertex((0, 0), [Propositional\ Logic], green, name: <pl>),
    vertex((2, 0), [First-Order\ Logic], blue, name: <fol>),
    vertex((4, 0), [Higher-Order\ Logic], purple, name: <hol>),

    vertex((0, 2), [Modal\ Logic], orange, name: <modal>),
    vertex((2, 2), [Temporal\ Logic], orange, name: <temporal>),
    vertex((4, 2), [Separation\ Logic], red, name: <sep>),

    edge(<pl>, <fol>, "-}>", label: [\+ quantifiers]),
    edge(<fol>, <hol>, "-}>", label: [\+ higher types]),
    edge(<pl>, <modal>, "-}>", label: [\+ $square, diamond$]),
    edge(<modal>, <temporal>, "-}>", label: [\+ time]),
    edge(<fol>, <sep>, "-}>", label: [\+ heap], label-angle: auto),
  )
]

#grid(
  columns: 3,
  column-gutter: 1em,
  [
    *Modal Logic:*
    $square phi$ ("necessarily") and $diamond phi$ ("possibly").
    Kripke semantics: worlds + accessibility.
  ],
  [
    *Temporal Logic:*
    LTL ($square$, $diamond$, $cal(U)$), CTL, CTL\*.
    Model checking: $square diamond "response"$.
  ],
  [
    *Separation Logic:*
    Spatial connectives ($ast$, $ast.op$) for heap memory.
    Powers Meta Infer, VeriFast.
  ],
)

== Decidability Landscape

Computational complexity of logical decision problems:

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Logic / Fragment*][*SAT*][*Validity*][*Complexity*],
    [Propositional], [Decidable], [Decidable], [NP-c / co-NP-c],
    [Modal (K, S4, S5)], [Decidable], [Decidable], [PSPACE-complete],
    [FOL (general)], [Undecidable], [Undecidable], [Semi-decidable],
    [FOL monadic], [Decidable], [Decidable], [NEXPTIME-complete],
    [Presburger ($NN, +$)], [Decidable], [Decidable], [2-EXPTIME],
    [Arithmetic ($NN, +, times$)], [Undecidable], [Undecidable], [Not even semi-dec.],
  )
]

#Block(color: yellow)[
  *The sweet spot:* SMT logics (QF_LIA, QF_LRA, QF_BV, QF_AX, ...) --- expressive enough for verification conditions, with terminating decision procedures.
]


// ═══════════════════════════════════════════════════════════════════════
//  BRIDGE
// ═══════════════════════════════════════════════════════════════════════

= From FOL to SMT

== Why Theories?

FOL validity is _undecidable_ in general.
But verification does not need _all_ of FOL --- it needs to reason about _specific_ domains: integers, arrays, bit-vectors, etc.

#definition[First-Order Theory][
  A _first-order theory_ $cal(T)$ is a set of FOL sentences (axioms) over a fixed signature $Sigma$.
  A _$cal(T)$-model_ is a structure satisfying all axioms in $cal(T)$.
  $cal(T)$-satisfiability asks: is there a _$cal(T)$-model_ satisfying a given formula?
]

#example[
  - _Theory of linear integer arithmetic_ (LIA): $Sigma = {0, 1, +, <, =}$. Only structures isomorphic to $ZZ$ considered.
  - _Theory of arrays_: $Sigma = {"read", "write"}$ with McCarthy axioms.
  - _Theory of equality with uninterpreted functions_ (EUF): $Sigma = {=, f_1, f_2, dots}$, congruence axioms only.
]

By _fixing_ the theory, we restrict to structures where decision procedures _can_ terminate.

#Block(color: yellow)[
  *The key insight:* FOL + fixed theory axioms = decidable fragments. \
  _Satisfiability Modulo Theories_ (SMT) solvers exploit this. \
  *Next (Week 6):* Many-sorted FOL, SMT theories, CDCL($cal(T)$), and Z3.
]

== From English to FOL

Translating natural language to FOL formulas is a key skill.
Here are worked examples over the signature of arithmetic: $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$.

+ _There is no largest natural number._ \
  $not exists x. thin forall y. thin y lt.eq x$ #h(2em) (equivalently: $forall x. thin exists y. thin x < y$)

+ _Every prime greater than 2 is odd._ \
  $forall p. thin ("Prime"(p) and p > 2) imply "Odd"(p)$

+ _For every natural number there is a greater one._ \
  $forall x. thin exists y. thin x < y$

+ _Two distinct natural numbers cannot have the same successor._ \
  $forall x. thin forall y. thin not (x = y) imply not (S(x) = S(y))$

+ _There are at least two natural numbers smaller than 3._ \
  $exists x. thin exists y. thin not (x = y) and x < S(S(S(0))) and y < S(S(S(0)))$

#Block(color: blue)[
  *Tip:* When formalizing, identify (1) the domain, (2) the quantifier structure, and (3) the predicate/function symbols needed.
  Common pitfall: confusing the direction of implication after $forall$.
]


// ═══════════════════════════════════════════════════════════════════════
//  EXERCISES
// ═══════════════════════════════════════════════════════════════════════

= Exercises

== Exercises: FOL Syntax and Semantics

+ Formalize the following in FOL:
  - "Every prime number greater than 2 is odd."
  - "There is no largest natural number."
  - "If $f$ is injective and $A subset.eq B$, then $f(A) subset.eq f(B)$."

+ Determine free and bound variables, and whether each formula is a sentence:
  - $forall x. thin (P(x) imply exists y. thin Q(x, y))$
  - $exists x. thin (x = y + 1)$
  - $forall x. thin forall y. thin (R(x, y) imply R(y, x))$

+ Convert to prenex normal form:
  $(forall x. thin P(x)) imply (exists y. thin Q(y))$

+ Explain informally: why does $exists x. thin forall y. thin R(x, y) thin models thin forall y. thin exists x. thin R(x, y)$ hold, but $forall y. thin exists x. thin R(x, y) thin models.not thin exists x. thin forall y. thin R(x, y)$?
  Give a concrete counterexample for the latter.

== Exercises: FOL Proofs and Metatheorems

+ Prove the following using natural deduction (Fitch notation):
  - $forall x. thin (P(x) imply Q(x)), thin exists x. thin P(x) thin entails thin exists x. thin Q(x)$
  - $forall x. thin (P(x) imply Q(x)) thin entails thin (exists x. thin P(x)) imply (exists x. thin Q(x))$
  - $forall x. thin P(x), thin forall x. thin (P(x) imply Q(x)) thin entails thin forall x. thin Q(x)$

+ Construct a countermodel to show that $exists x. thin P(x) and exists x. thin Q(x) thin models.not thin exists x. thin (P(x) and Q(x))$.

+ $star$ Using compactness, show that "the domain is finite" cannot be expressed by any _single_ FOL sentence (or even by any _set_ of FOL sentences).
  _Hint_: Consider the set of sentences $phi_n$ asserting "there exist at least $n$ distinct elements."

+ $star$ The compactness theorem fails for _second-order_ logic. Explain why, and give an example of a property SOL can express but FOL cannot.
