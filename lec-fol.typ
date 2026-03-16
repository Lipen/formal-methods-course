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


= Introduction to FOL

== Motivation: The Limits of Propositional Logic

Propositional logic was the first widely used formal calculus of reasoning (Boole, 1847; Frege, 1879).

But it has fundamental _limitations_:

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *What PL cannot express:*
    - "All humans are mortal" (quantification)
    - "Every even number > 2 is a sum of two primes" (Goldbach)
    - "For all $epsilon > 0$, there exists $delta > 0$..." ($epsilon$--$delta$ proofs)
    - "The array has no out-of-bounds access" (program verification)
  ],
  [
    *Why this matters:*
    - Mathematics _needs_ universal statements
    - Program specifications quantify over inputs
    - Database queries select objects satisfying properties
    - Scientific theories make generalizations
  ],
)

== What is First-Order Logic? The Historical Context

_First-order logic_ emerged from three converging streams in late 19th/early 20th century:

#grid(
  columns: 3,
  column-gutter: 1.5em,
  [
    *Frege (1879):*
    _Begriffsschrift_ --- the first formal system with quantifiers.
    Goal: foundations for arithmetic.
    Notation was 2D and hard to use.
  ],
  [
    *Russell (1903):*
    _Principia Mathematica_ (with Whitehead, 1910-1913).
    Derived mathematics from logic.
    Discovered Russell's paradox: naive set theory is inconsistent.
  ],
  [
    *Hilbert (1920s):*
    Hilbert's program: prove consistency of mathematics via finitary methods.
    Pushed for formal axiomatization.
    Goal shattered by Gödel (1931).
  ],
)

#Block(color: teal)[
  *Why "first-order"?* The quantifiers $forall x, exists x$ range over _individuals_ (elements of the domain). \
  In _second-order_ logic, we could quantify over _sets_ or _predicates_: $forall P. exists x. thin P(x)$. \
  In _higher-order_ logic (used in Coq, Lean, Isabelle), we quantify over functions of functions, etc.

  First-order logic is expressive and has strong metatheory (soundness, completeness, compactness).
]

== Syntax: The Language of FOL

Similar to PL, first-order logic is a formal system with a _syntax_ and _semantics_.

#Block(color: green)[
  First-order logic is an umbrella term for different _first-order languages_. \
  Each language is specified by its _signature_ $Sigma$ --- the vocabulary of function and relation symbols.
]

Symbols of a first-order language are divided into _logical symbols_ (fixed) and _non-logical parameters_ (signature-dependent):

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Logical symbols (universal):*
    - Parentheses: $($, $)$
    - Logical connectives: $not$, $and$, $or$, $imply$, $iff$
    - Variables: $x$, $y$, $z$, $dots$ (infinite supply)
    - Quantifiers: $forall$ ("for all") and $exists$ ("there exists")
    - Equality: $=$
  ],
  [
    *Non-logical parameters (signature $Sigma$):*
    - Constants: e.g., $0$, $emptyset$, $e$ (arity 0 functions)
    - Functions: e.g., $S$ (successor), $+$, $times$, $f(x, y)$
    - Predicates: e.g., $<$, $in$, $"Prime"(x)$, $P(x, y)$

    Each symbol has a fixed _arity_ (number of arguments).
  ],
)

#note[
  The pair $and$, $not$ is functionally complete for Boolean connectives.
  Also, $forall$ alone is sufficient for quantification since $exists x. phi equiv not forall x. not phi$.
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


= FOL Syntax

== Signatures

#definition[Signature][
  A _first-order signature_ $Sigma = angle.l cal(F), cal(R) angle.r$ consists of:
  - A set of _function symbols_ $cal(F)$, each with an arity $n gt.eq 0$.
  - A set of _relation symbols_ (predicates) $cal(R)$, each with an arity $n gt.eq 1$.

  Functions of arity 0 are _constants_.

  We assume a countably infinite set of _variables_ $cal(V) = {x, y, z, x_1, x_2, dots}$.
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
  - The sentence $exists m. thin forall x. thin m <= x$ is true in $frak(N)$ (least element exists: $m = 0$) but _false_ in $frak(Z)$ (integers have no least element).

  The same sentence may be true in one structure and false in another. \
  _Validity_ means truth in _all_ structures.
]

== Evaluating FOL Formulas

Given a structure $frak(A)$ and a variable assignment $sigma$, truth is defined inductively.
The main semantic difference from PL is that quantifiers range over domain elements.

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
  *Difference from PL:*
  - In PL, the space of interpretations is _finite_ ($2^n$ truth assignments).
  - In FOL, structures may be infinite and of arbitrary cardinality --- this is the source of undecidability in general validity/satisfiability problems.
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
  In general, $exists x. thin forall y. thin R(x, y)$ is _stronger_ than $forall y. thin exists x. thin R(x, y)$: \
  the first requires one uniform witness for all $y$.
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
  $(forall x. thin P(x)) imply (exists y. thin Q(y))$ \
  $equiv not forall x. thin P(x) or exists y. thin Q(y)$ #h(1em) _(eliminate $imply$)_ \
  $equiv exists x. thin not P(x) or exists y. thin Q(y)$ #h(1em) _(quantifier duality)_
]

PNF separates the _quantifier prefix_ (alternation structure) from the _propositional skeleton_ (matrix). \
The alternation depth ($forall exists forall dots$) determines complexity.


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

The rules below are the propositional tableau core. \
Full FOL tableaux add quantifier rules (instantiation and witness introduction):

#align(horizon + center)[
  #grid(
    columns: 3,
    column-gutter: 4em,
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


= Metatheorems and \ the Limits of Logic

== Metatheory Roadmap: From Syntax to Models

Up to now, we used FOL _inside_ proofs and specifications.
Now we step back and analyze FOL _itself_.

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Syntactic side:*
    - Derivability: $T entails phi$
    - Consistency: $T entails.not bot$
    - Proof rules and finite derivations
  ],
  [
    *Semantic side:*
    - Satisfaction: $frak(M) models phi$
    - Satisfiability: some model exists
    - Consequence: $T models phi$
  ],
)

#Block(color: yellow)[
  Lindenbaum extension $=>$ Henkin witnesses $=>$ term model $=>$ Truth Lemma $=>$ Completeness.

  Then we get Compactness and Löwenheim--Skolem almost for free.
]

== Consequence, Consistency, Satisfiability

#definition[
  Let $T$ be a set of FOL sentences and $phi$ a sentence.
  - $T models phi$ means: every model of $T$ is a model of $phi$.
  - $T entails phi$ means: $phi$ is derivable from $T$.
  - $T$ is _consistent_ iff $T entails.not bot$.
  - $T$ is _satisfiable_ iff some structure $frak(M)$ satisfies every sentence in $T$.
]

#Block[
  Soundness gives $T entails phi imply T models phi$.

  Completeness will prove the converse: $T models phi imply T entails phi$.
]

== Step 1: Lindenbaum Extension

#theorem[Lindenbaum Lemma][
  If $T$ is consistent, then there exists a _maximally consistent_ theory~$T^*$ with $T subset.eq T^*$.
  Maximal means: for every sentence $psi$, either $psi in T^*$ or $not psi in T^*$.
]

#proof[(idea)][
  Enumerate sentences as $psi_0, psi_1, psi_2, dots$ and build $T_0 subset.eq T_1 subset.eq dots$ with $T_0 = T$.

  At stage $n$:
  - if $T_n union {psi_n}$ is consistent, set $T_(n+1) = T_n union {psi_n}$;
  - otherwise set $T_(n+1) = T_n union {not psi_n}$.

  Let $T^* = T_0 union T_1 union dots$.

  Any proof uses finitely many premises, so any contradiction would already appear at some finite stage.
  Hence consistency is preserved, and every sentence is decided.
]

== Step 2: Henkinization (Adding Witnesses)

Maximal consistency alone does _not_ guarantee explicit witnesses for existential sentences.

#definition[Henkin Property][
  A theory $T^*$ is _Henkin_ if whenever $exists x. thin psi(x) in T^*$,
  there is a constant $c_psi$ such that $psi(c_psi) in T^*$.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Construction idea:*
    For each existential sentence $exists x. thin psi(x)$,
    introduce a fresh constant $c_psi$ and add a witness condition.
  ],
  [
    *Consistency argument:*
    Add witness only when the existential branch is consistent.
    Freshness of $c_psi$ ensures the new name does not interact with earlier formulas.
  ],
)

#Block(color: orange)[
  If $T_n union {exists x. thin psi(x)}$ is consistent, then
  $T_n union {exists x. thin psi(x), psi(c)}$ is consistent for fresh $c$.
]

== Step 3: Canonical Term Model

Assume $T^*$ is maximally consistent and Henkin.

#definition[Term Model][
  Work in the extended language $L_H$ with Henkin constants.

  Domain: equivalence classes $[t]$ of closed terms under
  $t sim s iff T^* entails t = s$.

  Interpret symbols by syntax:
  - constants: $c^frak(M) = [c]$;
  - functions: $f^frak(M)([t_1], dots, [t_n]) = [f(t_1, dots, t_n)]$;
  - relations: $frak(M) models R([t_1], dots, [t_n])$ iff $R(t_1, dots, t_n) in T^*$.
]

#note[
  Equality axioms/substitutivity ensure these interpretations are well-defined.
]

== Step 4: Truth Lemma

#theorem[Truth Lemma][
  For every formula $phi(x_1, dots, x_k)$ and closed terms $t_1, dots, t_k$:
  $ frak(M) models phi([t_1], dots, [t_k]) quad iff quad phi(t_1, dots, t_k) in T^* $.

  In particular, for every sentence $phi$: $frak(M) models phi iff phi in T^*$.
]

#proof[(sketch)][
  By structural induction on $phi$:
  - atomic case by definition of the term model;
  - Boolean connectives by maximal consistency;
  - existential case uses the Henkin witness;
  - universal case follows by duality: $forall x. thin psi equiv not exists x. thin not psi$.
]

== Completeness Theorem (Gödel, 1930)

#theorem[Completeness][
  For every theory $T$ and sentence $phi$:
  $ T models phi quad imply quad T entails phi $
]

#proof[(contrapositive argument)][
  Assume $T entails.not phi$.
  Then $T union {not phi}$ is consistent.
  Extend it to a maximally consistent Henkin theory $T^*$.
  Build the term model $frak(M)$ of $T^*$.
  By the Truth Lemma, $frak(M) models T^*$, hence $frak(M) models T$ and $frak(M) models not phi$.
  Therefore $T models.not phi$, proving the contrapositive.
]

#Block(color: yellow)[
  Completeness (logic-level) is different from incompleteness (theory-level arithmetic).
]

== Compactness Theorem

#theorem[Compactness][
  A theory $T$ is satisfiable iff every finite subset $T_0 subset.eq T$ is satisfiable.
]

#proof[(from completeness)][
  The forward direction is immediate.
  For the converse, if $T$ were unsatisfiable then $T models bot$.
  By completeness, $T entails bot$.
  Any derivation is finite, so only finitely many premises are used; thus some finite $T_0 subset.eq T$ already proves $bot$ --- contradiction.
]

#example[
  Let $T = op("Th")(NN) union {c > 0, c > 1, c > 2, dots}$ with fresh constant $c$.
  Every finite subset is satisfiable in $NN$ by choosing $c$ large enough.
  By compactness, $T$ has a model, yielding a non-standard element larger than every standard numeral.
]

== Downward Löwenheim--Skolem

#theorem[
  Let $L$ be a language and let $T$ be an $L$-theory with an infinite model.
  If $L$ is countable, then $T$ has a _countable_ model.

  More generally, if $T$ has a model of size at least $max(aleph_0, |L|)$,
  then it has models of every infinite size $kappa$ with
  $max(aleph_0, |L|) <= kappa <= |M|$.
]

#proof[(idea)][
  Start with a set $A$ of parameters of the desired size.
  Close $A$ under witness-producing operations for existential formulas.
  The closure stays small, but is rich enough to satisfy the Tarski--Vaught test.
  Hence it forms an elementary submodel.
]

#Block(color: blue)[
  In the countable-language case, an infinite model always has a countable elementary submodel.
  So~first-order logic cannot force an infinite model to be uncountable.
]

== Upward Löwenheim--Skolem

#theorem[
  If an $L$-theory $T$ has an infinite model, then for every infinite cardinal $kappa >= max(aleph_0, |L|)$,
  the theory $T$ has a model of size at least $kappa$.
]

#proof[(compactness argument)][
  Add fresh constants $c_i$ for $i < kappa$ and add sentences $c_i != c_j$ for all distinct $i, j$.
  Every finite subset of this expanded theory is satisfiable in the original infinite model,
  because only finitely many distinct constants need interpretation.
  By compactness, the whole expanded theory has a model with at least $kappa$ distinct elements.
]

#note[
  With a standard cardinality argument, one can refine this to obtain a model of size exactly $kappa$.
]

== Skolem's Paradox and What LS Means

#Block(color: teal)[
  *Skolem's paradox (1922):* ZFC proves that uncountable sets exist, yet by Löwenheim--Skolem,
  if ZFC has any model at all, then it has a countable model.

  Resolution: "uncountable" is relative to the model's membership relation.
  Inside that countable model, there is no _internal_ bijection between the set and $NN$,
  even though from the outside the whole model is countable.
]

Consequences for first-order expressiveness:
- no first-order theory with an infinite model can force a unique infinite cardinality;
- pure first-order arithmetic cannot characterize $NN$ up to isomorphism;
- properties such as "the domain is finite" or "the domain is countable" are not first-order axiomatizable in the intended absolute sense.

== What Is the Decision Problem?

Given a sentence $phi$, we can ask three different questions:

+ *Satisfiable?* Is there some structure $frak(M)$ with $frak(M) models phi$?
+ *Valid?* Does every structure satisfy $phi$? Equivalently, $models phi$.
+ *Provable?* Can we derive $phi$ in a proof system? Equivalently, $tack phi$ or $T tack phi$.

#definition[Decidable][
  A problem is _decidable_ if there is an algorithm that halts on every input and always returns the correct yes/no answer.
]

== FOL Validity Is Undecidable

#theorem[Church--Turing, 1936][
  The _validity problem_ for first-order logic is undecidable:
  there is no algorithm that decides, for every FOL sentence $phi$, whether $models phi$.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Why PL is decidable:*
    - finitely many propositional variables
    - finitely many truth assignments
    - brute force always terminates
  ],
  [
    *Why FOL is not:*
    - structures may be infinite
    - domains may have arbitrary size
    - quantifiers range over unbounded domains
  ],
)

#Block(color: orange)[
  Completeness does _not_ imply decidability.
  It only says: if $phi$ is valid, then some proof exists.
  It does not say how long proof search will take, or whether search terminates on invalid input.
]

== Semi-Decidability: What Completeness Gives

*Validity is semi-decidable.*
Enumerate all formal proofs. If $phi$ is valid, then by completeness some proof of $phi$ exists, so the search will eventually find it.

*Unsatisfiability is semi-decidable.*
$phi$ is unsatisfiable iff $not phi$ is valid. So a search for a proof of $not phi$ will eventually succeed when $phi$ has no model.

*Satisfiability is therefore co-semi-decidable.*
If $phi$ is satisfiable, there need not be any finite certificate that a blind proof search will eventually find.
Search may run forever even on satisfiable input.

#Block(color: yellow)[
  For general FOL:
  - validity is r.e. but undecidable;
  - unsatisfiability is r.e.;
  - satisfiability is co-r.e. and undecidable.
]

== Gödel Incompleteness

Completeness and incompleteness concern different objects.

+ *Completeness theorem (logic-level):* for first-order logic, semantic consequence and derivability coincide:
  $T models phi imply T entails phi$.
+ *Incompleteness theorems (theory-level):* for specific arithmetic theories,
  not every sentence true in the intended model $NN$ is provable inside the theory.

#Block(color: orange)[
  Completeness is about the proof system of first-order logic.
  Incompleteness is about the limitations of particular arithmetic axiomatizations.
]

== First Incompleteness Theorem

#theorem[Gödel I][
  Let $cal(T)$ be a recursively axiomatized, consistent theory that can represent elementary arithmetic
  (for example, $cal(T)$ extends Robinson arithmetic $Q$).
  Then there exists a sentence $G_cal(T)$ such that:
  - $cal(T) tack.not G_cal(T)$, and
  - if $cal(T)$ is sound for arithmetic truth, then $NN models G_cal(T)$.
]

#note[
  There are arithmetic sentences true in the intended model $NN$ that are not provable in $cal(T)$.
  Hence no single effective axiomatization captures all arithmetic truths.
]

#Block(color: blue)[
  Terminology checkpoint:
  - "true" here means true in the standard naturals $NN$;
  - "provable" means derivable inside the formal calculus of $cal(T)$.
]

== Second Incompleteness Theorem

#theorem[Gödel II][
  Under similar assumptions (in particular, sufficient arithmetic strength),
  if $cal(T)$ is consistent then $cal(T) tack.not op("Con")(cal(T))$.
]

#note[
  Here $op("Con")(cal(T))$ is an arithmetized sentence expressing "there is no code of a contradiction-proof in $cal(T)$."
  So a sufficiently strong consistent arithmetic theory cannot prove its own consistency by its own internal methods.
]

#Block(color: yellow)[
  *FM consequence:* no fixed sufficiently expressive sound system can prove every true arithmetic/program property.
  Practical verification combines automated solvers with user-guided invariants, lemmas, and decomposition.
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

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header[*Logic / Fragment*][*SAT*][*VALID*][*Complexity*],
    [Propositional], [Decidable], [Decidable], [NP-c / co-NP-c],
    [Modal (K, S4, S5)], [Decidable], [Decidable], [PSPACE-c],
    [FOL (general)], [Undecidable], [Undecidable], [r.e. / co-r.e.],
    [Monadic FOL], [Decidable], [Decidable], [NEXPTIME-c],
    [Presburger $(NN, +)$], [Decidable], [Decidable], [2-EXPTIME],
    [Arithmetic $(NN, +, times)$], [Undecidable], [Undecidable], [Not decidable],
  )
]

#Block(color: blue)[
  Distinguish two failure modes:
  high complexity (decidable but expensive) versus undecidability (no terminating general procedure).
]

== Why Theories?

Unrestricted FOL is too expressive for fully general algorithmic solving.

#definition[
  A _first-order theory_ $cal(T)$ fixes a signature and intended class of models.
  - _$cal(T)$-model_: structure satisfying all axioms of $cal(T)$.
  - _$cal(T)$-satisfiability_: whether a formula has a model _inside_ that class.
]

#Block(color: yellow)[
  Verification tools therefore work in fragments/theories with known decision procedures,
  rather than arbitrary FOL over arbitrary structures.
]

== SMT = SAT + Theories

Two components work together:
- *SAT layer:* handles Boolean structure ($and$, $or$, $not$, case splitting, learning).
- *Theory layer:* handles domain constraints (arithmetic, arrays, bit-vectors, uninterpreted functions, ...).

Common SMT theories in verification:
- _LIA_ (linear integer arithmetic): $0, 1, +, <, =$ over integers.
- _EUF_ (equality with uninterpreted functions): congruence reasoning over symbolic functions.
- _Arrays_: read/write operators with array axioms.

#Block(color: green)[
  SMT combines Boolean search with theory reasoning.
  Termination is guaranteed on the decidable fragments implemented by the solver.
]

== From English to FOL

Translating natural language statements into FOL formulas is a core formalization task. \
Here are examples over the signature of arithmetic: $Sigma = angle.l {0, S, +, times}, {<, =} angle.r$.

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
  Formalization checklist:
  (1) specify the domain,
  (2) fix quantifier order,
  (3) choose predicates/functions,
  (4) verify implication direction under quantifiers.
]


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

+ Explain precisely why $exists x. thin forall y. thin R(x, y) thin models thin forall y. thin exists x. thin R(x, y)$ holds, but $forall y. thin exists x. thin R(x, y) thin models.not thin exists x. thin forall y. thin R(x, y)$.
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
