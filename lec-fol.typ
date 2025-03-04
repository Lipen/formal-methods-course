#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "First-Order Logic",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

#let True = $#`true`$
#let False = $#`false`$
// #let True = $"true"$
// #let False = $"false"$

// #let eqq = $scripts(eq.delta)$
#let eqq = $scripts(eq^.)$
#let rank = $op("rank")$

#let Sort(s) = $#raw(s)$
#let BoolSort = Sort("Bool")
#let NatSort = Sort("Nat")
#let SetSort = Sort("Set")
#let IntSort = Sort("Int")
#let RealSort = Sort("Real")
#let ArraySort = Sort("Array")
#let ElemSort = Sort("Elem")
#let ASort = Sort("A")
#let BSort = Sort("B")
#let XSort = Sort("X")
#let YSort = Sort("Y")
#let PersonSort = Sort("Person")

#let sexp(..args) = {
  let rec(expr) = {
    if type(expr) == array {
      let elements = expr.map(e => rec(e))
      [ \( #elements.join[#h(0.3em)] \) ]
    } else {
      expr
    }
  }
  rec(args.pos())
}

#let FreeVars = $cal(F V)$

#let YES = text(fill: green.darken(20%))[#sym.checkmark]
#let NO = text(fill: red.darken(20%))[#sym.crossmark]

#let pa = $op("pa")$
#let ma = $op("ma")$
#let sp = $op("sp")$

= Introduction to FOL

== Motivation

#fancy-box(tint: yellow)[
  Propositional logic (PL) is not powerful enough for many applications.
]

- PL cannot reason about _natural numbers_ directly.
- PL cannor reason about _infinite_ domains.
- PL cannot express _abstract_ properties.
- PL cannot respresent the _internal structure_ of propositions.
- PL lacks _quantifiers_ for generalization.

First-order logic (FOL) _extends_ propositional logic by adding _variables_, _predicates_, _functions_, and _quantifiers_, providing a structured way to reason about objects, their properties, and relationships.

Unlike propositional logic, which is limited to fixed truth values for statements, FOL allows complex expressions like "All humans are mortal" ($forall x. thin "Human"(x) imply "Mortal"(x)$) or "There exists a solution to the problem" ($exists x. thin "Solution"(x)$).

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
    - Parantheses: $($, $)$
    - Logical connectives: $not$, $and$, $or$, $imply$, $iff$
    - Variables: $x$, $y$, $z$, $dots$
    - Quantifiers: $forall$ and $exists$
  ],
  [
    *Parameters*:
    - Equiality: $=$
    - Constants: e.g. $bot$, $0$, $emptyset$, $dots$
    - Predicates: e.g. $P(x)$, $Q(x, y)$, $x > y$, $A subset B$, $"a" prec "ab"$
    - Functions: e.g. $f(x)$, $g(x, y)$, $x + y$, $x xor y$
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

== First-Order Language

First-order language is specified by its _parameters_.

#grid(
  columns: 3,
  column-gutter: 2em,
  [
    *Propositional logic*:
    - Equiality: _no_
    - Constants: _none_
    - Predicates: $A_1$, $A_2$, $dots$
    - Functions: _none_
  ],
  [
    *Set theory*:
    - Equiality: _yes_
    - Constants: $emptyset$
    - Predicates: $in$
    - Functions: _none_
  ],
  [
    *Number theory*:
    - Equiality: _yes_
    - Constants: $0$
    - Predicates: $<$
    - Functions: $S$ (successor), $+$, $times$, $"exp"$
  ],
)

= Formalizing FOL

== Syntax

#definition[Signature][
  A _vocabulary_ (also known as _signature_) of a language is a collection of symbols used to construct sentences in that language.
  A signature $Sigma = angle.l cal(V), cal(F), cal(R) angle.r$ consists of:
  - A set of _variables_ $cal(V)$, e.g., $x$, $y$, $z$, $dots$
  - A set of _function symbols_ $cal(F)$, e.g., $S$, $plus$, $times$, $dots$
  - A set of _relation symbols_ $cal(R)$, e.g., $eq$, $lt$, $in$, $dots$
]

Each function and relation symbol has an associated _arity_ (number of arguments).
- Functions of arity 0 are called _constants_.
- Relations of arity 1 are called _predicates_.

== Statements

#definition[Term][
  A _first-order term_ over $Sigma$ is defined inductively:
  - Each variable $x in cal(V)$ is a term.
  - If $t_1, dots, t_n$ are terms and $f$ is an $n$-ary function symbol from $cal(F)$, then $f(t_1, dots, t_n)$ is a term.
]

#definition[Atom][
  A _first-order atom_ over $Sigma$ is defined as follows:
  - If $t_1, dots, t_n$ are terms and $R$ is a relation symbol from $cal(R)$, then $R(t_1, dots, t_n)$ is an atom.
]

#definition[Formula][
  A _first-order formula_ over $Sigma$ is defined inductively:
  - Each atom is a formula.
  - If $alpha$ and $beta$ are formulas, then $not alpha$, $(alpha and beta)$, $(alpha or beta)$, $(alpha imply beta)$, and $(alpha iff beta)$ are formulas.
  - If $alpha$ is a formula and $x in cal(V)$ is a variable, then $forall x. thin alpha$ and $exists x. thin alpha$ are formulas.
]

== Free and Bound Variables

- A variable $x$ is _bound_ in $forall x. thin alpha$ and $exists x. thin alpha$.
- A variable $x$ is _free_ in $alpha$ if it is not bound in $alpha$.
- A formula is _closed_ (also called a _sentence_) if it contains no free variables.

== Grammar

#let term(x) = $angle.l #x angle.r$
$
  term("Form") &::= term("Atom") | not term("Form") | term("Form") and term("Form") | dots | ("'"forall"'" | "'"exists"'") cal(V). thin term("Form") \
  term("Atom") &::= cal(R) "'('" term("Term")^* "')'" \
  term("Term") &::= cal(V) | term("Function") "'('" term("Term")^* "')'" \
$

// TODO: CASL language example, see Roggenback (2022)

== Semantics

#definition[Model][
  A _possible world_ (also known as _model_, or _structure_, or _interpretation_) is a mathematical object that gives meaning to the symbols of a language.

  A _first-order model_ $cal(M) = angle.l cal(U), nu, cal(I) angle.r$ for $Sigma = angle.l cal(V), cal(F), cal(R) angle.r$ consists of:
  - A _domain_ $cal(U)$ is a non-empty set of objects (_universe of disclosure_).
  - A _variable valuation_ $nu : cal(V) to cal(U)$ assigning to each variable $x in cal(V)$ an element of $cal(U)$.
  - An _interpretation_ of an $n$-ary function symbol $f in cal(F)$ is an $n$-ary total function $cal(I)(f) : cal(U)^n to cal(U)$.
  - An _interpretation_ of an $n$-ary relation symbol $R in cal(R)$ is an $n$-ary relation $cal(I)(R) subset.eq cal(U)^n$.
]

#definition[
  The _term valuation_ induced by a model $cal(M) = angle.l cal(U), nu, cal(I) angle.r$ is defined as follows:
  - $nu(t) = nu(x)$ if $t$ is a variable $x$.
  - $nu(t) = (cal(I)(f))(nu(t_1), dots, nu(t_n))$ if $t$ is a term $f(t_1, dots, t_n)$.
]

#definition[Semantics of FOL][
  The _validation relation_ $models$ between a model $cal(M)$ and a first-order formula $phi$ is defined inductively:
  - $cal(M) models R(t_1, dots, t_n)$ iff $cal(I)(R)$ contains $(nu(t_1), dots, nu(t_n))$.
  - $cal(M) models.not bot$.
  - $cal(M) models not phi$ iff $cal(M) models.not phi$.
  - $cal(M) models (alpha and beta)$ iff $cal(M) models alpha$ and $cal(M) models beta$. Similar for $or$, $imply$, and $iff$.
  - $cal(M) models exists x. thin phi$ iff $cal(M') models phi$ for some $cal(M') = angle.l cal(U), cal(I), nu' angle.r$ with $nu'(y) = nu(y)$ for all $y neq x$.
  - $cal(M) models forall x. thin phi$ iff $cal(M') models phi$ for all $cal(M')$ which differ from $cal(M)$ at most in the valuation of $x$.
]


= Many-Sorted FOL

== Syntax

The _syntax_ of a logic consists of _symbols_ and _rules_ for combining them.

The _symbols_ of a first-order language include:
+ Logical symbols: $($, $)$, $not$, $and$, $or$, $imply$, $iff$, $forall$, $exists$
+ Infinite set of variables: $x$, $y$, $z$, $dots$
+ Signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$, where:
  - $Sigma^S$ is a set of _sorts_ (also called _types_), e.g. $BoolSort$, $"Int"$, $"Real"$, $SetSort$.
  - $Sigma^F$ is a set of _function symbols_, e.g. $=$, $+$, $<$, $dots$

== Signatures

#definition[
  Signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$ consists of:
  - $Sigma^S$ is a set of _sorts_ #strike[(also called _types_)], e.g. $BoolSort$, $IntSort$, $RealSort$, $SetSort$
  - $Sigma^F$ is a set of _function symbols_, e.g. $=$, $+$, $<$
]

#definition[
  Each _function symbol_ $f in Sigma^F$ is associated with an _arity_ $n$ (number of arguments) and a _rank_, $(n+1)$-tuple of sorts: $rank(f) = angle.l sigma_1, sigma_2, dots, sigma_(n+1) angle.r$.
  Intuitively, $f$ denotes a function that takes $n$ values of sorts $sigma_1, dots, sigma_n$ and returns an output of sort $sigma_(n+1)$.
  - Functions of arity 0 are called _constants_, which are said to have sort $sigma$ if $rank(f) = angle.l sigma angle.r$.
  - Functions that _return_ sort $BoolSort$ are called _predicates_.
]

For every signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$, we assume that:
- $Sigma^S$ includes a distinguished sort $BoolSort$.
- $Sigma^F$ contains distinguished constants $top$ and $bot$ of sort $BoolSort$, and distinguished predicate symbol $eqq$ with #box[$rank(eqq) = angle.l sigma, sigma, BoolSort angle.r$] for every sort $sigma in Sigma^S$.

== Equality

TODO: axioms of equality
- reflexivity
- substitution for functions
- substitution for formulas

== First-Order Languages

A first-order language is defined w.r.t. a signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$.

#columns(2)[
  *Number Theory*:
  - $Sigma^S = {NatSort} union {BoolSort}$
  - $Sigma^F = {0, S, <, +, times} union {top, bot, eqq_BoolSort, eqq_NatSort}$
    - $rank(0) = angle.l NatSort angle.r$
    - $rank(S) = angle.l NatSort, NatSort angle.r$
    - $rank(<) = angle.l NatSort, NatSort, BoolSort angle.r$
    - $rank(+) = rank(times) = angle.l NatSort, NatSort, NatSort angle.r$

  *Set Theory*:
  - $Sigma^S = {SetSort} union {BoolSort}$
  - $Sigma^F = {emptyset, in, union, inter} union {top, bot, eqq_BoolSort, eqq_SetSort}$
    - $rank(emptyset) = angle.l SetSort angle.r$
    - $rank(in) = angle.l SetSort, SetSort, BoolSort angle.r$
    - $rank(union) = rank(inter) = angle.l SetSort, SetSort, SetSort angle.r$

  #colbreak()

  *Propositional Logic*:
  - $Sigma^S = {BoolSort}$
  - $Sigma^F = {not, and, or, dots, p_1, p_2, dots} union {top, bot, eqq_BoolSort}$
    - $rank(p_i) = angle.l BoolSort angle.r$
    - $rank(not) = angle.l BoolSort, BoolSort angle.r$
    - $rank(and) = rank(or) = angle.l BoolSort, BoolSort, BoolSort angle.r$

  *Arrays Theory*:
  - $Sigma^S = {ArraySort_(angle.l XSort,YSort angle.r)} union {BoolSort}$
    - $XSort$ is a sort of _indices_.
    - $YSort$ is a sort of _values_.
  - $Sigma^F = {"read", "write"} union {top, bot, eqq_BoolSort, eqq_ArraySort}$
    - $rank("read") = angle.l ArraySort_(angle.l XSort,YSort angle.r), XSort, YSort angle.r$
    - $rank("write") = angle.l ArraySort_(angle.l XSort,YSort angle.r), XSort, YSort, ArraySort_(angle.l XSort,YSort angle.r) angle.r$
]

== Expressions

#definition[
  An _expression_ is a finite sequence of symbols.
]

_Examples_:
- $forall x_1 (sexp(<, 0, x_1) imply not forall x_2 sexp(<, x_1, x_2))$
- $x_1 < forall x_2 ))$
- $x_1 < x_2 imply forall x : NatSort. thin x > 0$

#note[
  Most expressions are *not* _well-formed_.
]

== Terms (simple)

#definition[Variables][
  A set $X$ of $Sigma$-variables, or simply _variables_, is a countable set of variable names, each associated with a sort from $Sigma^S$.
]

Based on variables, we can build _terms_.
Intuitevely, terms are expressions that evaluate to values.

#definition[Terms][
  The $Sigma$-terms over $X$, or simply _terms_, are defined inductively:
  - Each variable $x$ in $X$ is a term of sort $sigma$.
  - If $c in Sigma^F$ is a constant symbol of sort $sigma$, then $c$ is a term of sort $sigma$.
  - If $t_1, dots, t_n$ are terms of sorts $sigma_1, dots, sigma_n$, and $f$ is a function symbol with $rank(f) = angle.l sigma_1, dots, sigma_n, sigma angle.r$, then $sexp(f, t_1, dots.c, t_n)$ is a term of sort $sigma$.
  - _(Nothing else is a term.)_
]

== Formulas (simple)

Based on terms, we can build _atoms_.
Intuitevely, atoms are expressions that evaluate Boolean values.

#definition[Atoms][
  The $Sigma$-atoms over $X$, or simply _atoms_, are terms of the form $sexp(p, t_1, dots.c, t_n)$, where $t_1, dots, t_n$ are terms of sorts $sigma_1, dots, sigma_n$, and $p$ is a predicate symbol with $rank(p) = angle.l sigma_1, dots, sigma_n, BoolSort angle.r$.
]

In addition to sorted $Sigma$-variables $X$, also consider _propositional variables_ $cal(B)$.

#definition[Formulas][
  The $Sigma$-formulas over $X$ and $cal(B)$, or simply _formulas_, are defined inductively:
  - Each propositional variable $p$ in $cal(B)$ is a formula.
  - Each $Sigma$-atom over $X$ is a formula.
  - If $alpha$ and $beta$ are formulas, then so are $not alpha$, $(alpha or beta)$, $(alpha and beta)$, $(alpha imply beta)$, and $(alpha iff beta)$.
  - For each variable $x in X$ and sort $sigma in Sigma^S$, if $alpha$ is a formula, then so are $forall x : sigma. thin alpha$ and $exists x : sigma. thin alpha$.
]

== Terms

A _term_ is a _well-formed_ S-expression built from function symbols, variables, and parentheses.

#definition[Term][
  Let $cal(B)$ be the set of all variables and all constant symbols in some signature $Sigma$.

  For each function symbol $f$ in $Sigma^F$ of arity $n$, define _term-building operation_ $cal(T)_f$:
  $ cal(T)_f (epsilon_1, dots, epsilon_n) := sexp(f, epsilon_1, dots.c, epsilon_1) $

  _Well-formed terms_ are expressions generated from $cal(B)$ by $cal(T) = {cal(T)_f | f in Sigma^F}$.
]

_Examples_:
#[
  #show: cheq.checklist.with(
    marker-map: (
      "+": text(fill: green.darken(20%))[#sym.checkmark],
      "-": text(fill: red.darken(20%))[#sym.crossmark],
    ),
  )
  #grid(
    columns: 4,
    column-gutter: 1fr,
    [
      - $sexp(+, x_2, sexp(S, 0))$ #YES
      - $sexp(S, sexp(S, sexp(S, sexp(S, 0))))$ #YES
      - $sexp(S, sexp(0, 0))$ #NO
    ],
    [
      - $sexp(x_2, +, 0)$ #NO
      - $sexp(S, 0, 0)$ #NO
      - $sexp(S, sexp(<, 0, 0))$ #YES
    ],
    [
      - $sexp(+, x_2, bot)$ #YES
      - $sexp(S, bot)$ #YES
      - $sexp(eqq, 0, bot)$ #YES
    ],
    [
      - $sexp("select", a)$ #NO
      - $sexp("select", a, i)$ #YES
      - $sexp("select", sexp("store", a, i, x), j)$ #YES
    ],
  )
]

== Well-sortedness

#note[
  Not all well-formed terms are are meaningful.
  For this, we need to take into account _sorts_.
]

// The notion of _well-sortedness_ w.r.t. $Sigma$ is formulated via a _sort system_.

#definition[
  _Sort system_ is a proof system over sequents of the form $Gamma entails t : sigma$.
  - $Gamma = x_1 : sigma_1, dots, x_n : sigma_n$ is a _sort context_, a set of sorted variables.
  - $t$ is a well-formed term.
  - $sigma$ is a sort from $Sigma^S$.

  #align(center)[
    #grid(
      columns: 2,
      column-gutter: 2em,
      curryst.prooftree(
        curryst.rule(
          label: smallcaps[Var],
          $Gamma entails x : sigma$,
          $x : sigma in Gamma$,
        ),
      ),
      curryst.prooftree(
        curryst.rule(
          label: smallcaps[Const],
          $Gamma entails c : sigma$,
          $c in Sigma^F$,
          $rank(c) = angle.l sigma angle.r$,
        ),
      ),
    )
    #curryst.prooftree(
      curryst.rule(
        label: smallcaps[Fun],
        $Gamma entails sexp(f, t_1, dots.c, t_n) : sigma$,
        $f in Sigma^F$,
        $rank(f) = angle.l sigma_1, dots, sigma_n, sigma angle.r$,
        $Gamma entails t_1 : sigma_1$,
        $dots.c$,
        $Gamma entails t_n : sigma_n$,
      ),
    )
  ]
]

#definition[$Sigma$-term][
  A term $t$ is _well-sorted_ w.r.t. $Sigma$ and _has sort $sigma$_ in a sort context $Gamma$ if $Gamma entails t : sigma$ is derivable in the sort system.
  Term $t$ is called $Sigma$-term.
]

== Examples of Well-sorted Terms

Let $Sigma^S = {NatSort} union {BoolSort}$ and $Sigma^F = {0, S, <, +, times, eqq_NatSort} union {top, bot, eqq_BoolSort}$.
- $rank(0) = angle.l NatSort angle.r$
- $rank(S) = angle.l NatSort, NatSort angle.r$
- $rank(<) = rank(eqq_NatSort) = angle.l NatSort, NatSort, BoolSort angle.r$
- $rank(+) = rank(times) = angle.l NatSort, NatSort, NatSort angle.r$

Are these well-formed terms also well-sorted in the context $Gamma = {x_1 : BoolSort, x_2 : NatSort, x_3 : NatSort}$?
+ $sexp(+, 0, x_2)$ #YES
+ $sexp(+, sexp(+, 0, x_1), x_2)$ #NO
+ $sexp(S, sexp(+, 0, x_5))$ #YES
+ $sexp(<, sexp(S, x_3), sexp(+, sexp(S, 0), x_1))$ #YES
+ $sexp(eqq_NatSort, sexp(S, x_3), sexp(+, sexp(S, 0), x_1))$ #YES

== Formulas

#definition[$Sigma$-atom][
  Given a signature $Sigma$, an _atomic $Sigma$-formula_, or simply _atom_, is a $Sigma$-term of sort $BoolSort$ under _some_ sort context $Gamma$.
]

#definition[Formula][
  _Well-formed formulas_ are expressions generated from atoms by the _formula-building operations_, denoted $cal(F) = {cal(F)_or, cal(F)_and, cal(F)_not, cal(F)_imply, cal(F)_iff, cal(E)_(x,sigma), cal(A)_(x,sigma)}$.
  - $cal(F)_or (alpha, beta) := (alpha or beta)$
  - $cal(F)_and (alpha, beta) := (alpha and beta)$
  - $cal(F)_not (alpha) := (not alpha)$
  - $cal(F)_imply (alpha, beta) := (alpha imply beta)$
  - $cal(F)_iff (alpha, beta) := (alpha iff beta)$
  - $cal(E)_(x,sigma) (alpha) := (exists x : sigma. thin alpha)$ for each variable $x$ and sort $sigma$ in $Sigma^S$
  - $cal(A)_(x,sigma) (alpha) := (forall x : sigma. thin alpha)$ for each variable $x$ and sort $sigma$ in $Sigma^S$
]

== Examples of Formulas

Let $Sigma^S = {NatSort}$, $Sigma^F = {0, S, <, +, times, eqq_NatSort}$, and let $x_i$ be variables.

Which of the following formulas are well-formed?
+ $sexp(eqq_NatSort, 0, sexp(S, 0))$ #YES
+ $sexp(<, sexp(S, x_3), sexp(+, sexp(S, 0), x_1))$ #YES
+ $sexp(eqq_NatSort, sexp(+, x_1, 0), x_2)$ #YES
+ $sexp(eqq_NatSort, sexp(+, x_1, 0), x_2) imply bot$ #YES
+ $sexp(+, 0, x_3) and sexp(<, 0, sexp(S, 0))$ #NO
+ $forall x_3 : NatSort. thin sexp(+, sexp(+, 0, x_3), x_2)$ #NO
+ $forall x_3 : BoolSort. thin sexp(eqq_NatSort, sexp(+, 0, x_3), x_2)$ #YES _(Note: not well-sorted)_
+ $not exists x_0 : NatSort. thin sexp(<, 0, x_0, sexp(S, 0))$ #NO

== Well-sorted Formulas

We _extend_ the sort system for terms with rules for the _logical connectives_ and _quantifiers_.

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 3em,
    curryst.prooftree(
      curryst.rule(
        label: smallcaps[Bconst],
        $Gamma entails c : BoolSort$,
        $c in {top, bot}$,
      ),
    ),
    curryst.prooftree(
      curryst.rule(
        label: smallcaps[Not],
        $Gamma entails (not alpha) : BoolSort$,
        $Gamma entails alpha : BoolSort$,
      ),
    ),
  )
  #curryst.prooftree(
    curryst.rule(
      label: smallcaps[Conn],
      $Gamma entails (alpha ast beta) : BoolSort$,
      $Gamma entails alpha : BoolSort$,
      $Gamma entails beta : BoolSort$,
      $ast in {and, or, imply, iff}$,
    ),
  )
  #curryst.prooftree(
    curryst.rule(
      label: smallcaps[Quant],
      $Gamma entails (op(Q) x : sigma. thin alpha) : BoolSort$,
      $Gamma[x : sigma] entails alpha : BoolSort$,
      $sigma in Sigma^S$,
      $op(Q) in {forall, exists}$,
    ),
  )
]

Here, $Gamma[x : sigma] = Gamma union {x : sigma}$.

#definition[$Sigma$-formula][
  A formula $phi$ is a _well-sorted_ w.r.t. $Sigma$ in a sort context $Gamma$ if #box[$Gamma entails phi : BoolSort$] is derivable in the extended sort system.
  Formula $phi$ is called $Sigma$-formula.
]

== Free and Bound Variables

A variable $x$ may occur _free_ or _bound_ in a $Sigma$-formula.

#example[
  In $forall x. thin A(x, y)$, the variable $x$ is said to be _bound_ and $y$ is _free_.
]

#definition[Free and bound variables][
  Recursive definition of _free_ variables in a $Sigma$-formula:
  - $x$ occurs free in a $Sigma$-atom $sexp(A, t_1, dots.c, t_n)$ if some $t_i$ contains $x$.
  - $x$ occurs free in $not A$ if $x$ occurs free in $A$.
  - $x$ occurs free in $A ast B$ if $x$ occurs free in $A$ or in $B$.
  - $x$ occurs free in $op(Q) y : sigma. thin A$ if $x$ occurs free in $A$ and $x$ is not $y$.

  If $alpha$ contains $op(Q) x$, then $x$ is said to be _bound_ in $alpha$.
]

#note[
  A variable can be simultaneously free and bound in a formula.
  For example, $x imply forall x. thin P(x)$.
]

#definition[Sentence][
  A formula $alpha$ is _closed_, or a _sentence_, if it contains no free variables.
]

#definition[
  The set $FreeVars$ of _free variables_ of a $Sigma$-formula $alpha$ is defined as follows:
  $
    FreeVars(alpha) := cases(
      gap: #0.5em,
      {x | x "is a var in" alpha} & "if" alpha "is atomic",
      FreeVars(beta) & "if" alpha equiv not beta,
      FreeVars(beta) union FreeVars(gamma) & "if" alpha equiv (alpha ast beta) "with" ast in {and, or, imply, iff},
      FreeVars(beta) setminus {v} & "if" alpha equiv op(Q) v : sigma. thin beta "with" op(Q) in {forall, exists},
    )
  $
]

#example[
  Let $x$, $y$, and $z$ be variables.
  - $FreeVars(x) = {x}$ (if $x$ has sort $BoolSort$)
  - $FreeVars(x < S(0) + y)$ = ${x, y}$
  - $FreeVars((x < S(0) + y) and (x eqq z)) = FreeVars(x < S(0) + y) union FreeVars(x eqq z) = {x,y} union {x,z} = {x,z,y}$
  - $FreeVars(forall x : NatSort. thin x < S(0) + y) = FreeVars(x < S(0) + y) setminus {x} = {x,y} setminus {x} = {y}$
]

== Scope

// see ML 7.2.2
- TODO: scope of variables
- TODO: free/bound variable
- TODO: open/closed formula
- TODO: universal closure
- TODO: existential closure

== FOL Semantics

*Recall:* The _syntax_ of a first-order language is defined w.r.t. a signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$, where:
- $Sigma^S$ is a set of _sorts_.
- $Sigma^F$ is a set of _function symbols_.

In PL, the truth of a formula depends on the meaning of its variables.

In FOL, the truth of a $Sigma$-formula depends on:
+ The meaning of each sort $sigma in Sigma^S$ in the formula.
+ The meaning of each function symbol $f in Sigma^F$ in the formula.
+ The meaning of each free variable $x$ in the formula.

== Semantics

Let $alpha$ be a $Sigma$-formula and let $Gamma$ be a sort context that includes all free variables of $alpha$.

The truth of $alpha$ is determined by _interpretations_ $cal(I)$ of $Sigma$ and $Gamma$ consisting of:
- An interpretation $sigma^cal(I)$ of each $sigma in Sigma^S$, as a non-empty set, the _domain_ of $sigma$.
- An interpretation $f^cal(I)$ of each $f in Sigma^F$ of rank $angle.l sigma_1, dots, sigma_n, sigma_(n+1) angle.r$, as an $n$-ary total function from~#box[$sigma_1^cal(I) times dots.c times sigma_n^cal(I)$] to $sigma_(n+1)^cal(I)$.
- An interpretation $x^cal(I)$ of each $x : sigma in Gamma$, as an element of $sigma^cal(I)$.

#note[
  We consider only interpretations $cal(I)$ such that
  - $BoolSort^cal(I) = {True, False}$, #h(1em) $bot^cal(I) = False$, #h(1em) $top^cal(I) = True$,
  - for all $sigma in Sigma^S$, $eqq_sigma^cal(I)$ maps its two arguments to $True$ iff they are identical.
]

== Semantics: Example

Consider a signature $Sigma = angle.l Sigma^S, Sigma^F angle.r$ for a fragment of a set theory with non-set elements (ur-elements):
- $Sigma^S = {ElemSort, SetSort}$,
- $Sigma^F = {emptyset, epsilon}$ with $rank(emptyset) = angle.l SetSort angle.r$, $rank(epsilon) = angle.l ElemSort, SetSort, BoolSort angle.r$,
- $Gamma = {e_i : ElemSort | i gt.eq 0} union {s_i : SetSort | i gt.eq 0}$

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    A possible _interpretation_ $cal(I)$ of $Sigma$ and $Gamma$:
    - $ElemSort^cal(I) = NN$, the natural numbers.
    - $SetSort^cal(I) = 2^NN$, all sets of natural numbers.
    - $emptyset^cal(I) = emptyset$, the empty set.
    - For all $n in NN$ and $S subset.eq NN$, $epsilon^cal(I)(n, S) iff n in S$.
    - For $i gt.eq 0$, $e_i^cal(I) = i$ and $s_i^cal(I) = [0; i] = {0, 1, dots, i}$.
  ],
  [
    Another _interpretation_ $cal(I)$ of $Sigma$ and $Gamma$:
    - $ElemSort^cal(I) = SetSort^cal(I) = NN$.
    - $emptyset^cal(I) = 0$.
    - For all $m,n in NN$, $epsilon^cal(I)(m, n) iff m | n$.
    - For $i gt.eq 0$, $e_i^cal(I) = i$ and $s_i^cal(I) = 2$.
  ],
)

#h(1em)
#align(center)[
  #fancy-box[
    There is a _infinity_ of interpretations of $Sigma, Gamma$.
  ]
]

== Term and Formula Semantics

// TODO: similar to PL interpretation under variable assignment $nu$

First, extend $cal(I)$ to an interpretation $overline(cal(I))$ for _well-sorted $Sigma$-terms_ by structural induction:

$
  t^overline(cal(I)) = cases(
    t^cal(I) & "if" t "is a constant or a variable",
    f^cal(I)(t_1^overline(cal(I)), dots, t_n^overline(cal(I))) & "if" t "is a term" sexp(f, t_1, dots, t_n),
  )
$

#example[
  Let $Sigma^S = {PersonSort}$, $Sigma^F = {pa, ma, sp}$, $Gamma = {x:PersonSort, y:PersonSort}$, #box[$rank(pa) = rank(ma) = angle.l PersonSort, PersonSort angle.r$], $rank(sp) = angle.l PersonSort, PersonSort, BoolSort angle.r$.

  Let $cal(I)$ be an interpretation of $Sigma$ and $Gamma$ such that:
  - $ma^cal(I) = {"Jim" maps "Jill", "Joe" maps "Jen", dots}$
  - $pa^cal(I) = {"Jim" maps "Joe", "Jill" maps "Jay", dots}$
  - $sp^cal(I) = {("Jill", "Joe") maps True, ("Joe", "Jill") maps True, ("Jill", "Jill") maps False, dots}$
  - $x^cal(I) = "Jim"$ and $y^cal(I) = "Joe"$

  Then:
  - $sexp(pa, sexp(ma, x))^overline(cal(I)) &= pa^cal(I)\(sexp(ma, x)^overline(cal(I))\) = pa^cal(I)\(ma^cal(I)\(x^overline(cal(I))\)\) = pa^cal(I)\(x^cal(I)\) \ &= pa^cal(I)\(ma^cal(I)("Jim")\) = pa^cal(I)\("Jill"\) = "Jay"$
  - $sexp(sp, sexp(ma, x), y)^overline(cal(I)) &= sp^cal(I)\(sexp(ma, x)^overline(cal(I)), y^overline(cal(I))\) = sp^cal(I)\(ma^cal(I)\(x^overline(cal(I))\), y^cal(I)) = sp^cal(I)\(ma^cal(I)(x^cal(I)), y^cal(I)\) \ &= sp^cal(I)\(ma^cal(I)\("Jim"\), "Joe"\) = sp^cal(I)\("Jill", "Joe"\) = True$
]

Further extend $overline(cal(I))$ to _well-sorted non-atomic $Sigma$-formulas_ by structural induction:
- $(not alpha)^overline(cal(I)) = True$ iff $alpha^overline(cal(I)) = False$
- $(alpha and beta)^overline(cal(I)) = True$ iff $alpha^overline(cal(I)) = True$ and $beta^overline(cal(I)) = True$
- $(alpha or beta)^overline(cal(I)) = True$ iff $alpha^overline(cal(I)) = True$ or $beta^overline(cal(I)) = True$
- $(alpha imply beta)^overline(cal(I)) = True$ iff $alpha^overline(cal(I)) = False$ or $beta^overline(cal(I)) = True$
- $(alpha iff beta)^overline(cal(I)) = True$ iff $alpha^overline(cal(I)) = beta^overline(cal(I))$
- $(exists x : sigma. thin alpha)^overline(cal(I)) = True$ iff $alpha^(overline(cal(I))[x maps c]) = True$ for some $c in sigma^cal(I)$
- $(forall x : sigma. thin alpha)^overline(cal(I)) = True$ iff $alpha^(overline(cal(I))[x maps c]) = True$ for all $c in sigma^cal(I)$

Here, $overline(cal(I))[x maps c]$ denotes the interpretation that maps $x$ to $c$ and is otherwise identical to $overline(cal(I))$.

== Satisfiability, Entailment, Validity

// TODO: compress
// TODO: reogranize
// TODO: move satisfiability on a separate slide

We write $cal(I) models alpha$ to denote "$cal(I)$ _satisfies_ $alpha$" and mean $alpha^overline(cal(I)) = True$.

We write $cal(I) models.not alpha$ to denote "$cal(I)$ _falsifies_ $alpha$" and mean $alpha^overline(cal(I)) = False$.

Let $Phi$ be a set of $Sigma$-formulas.
We write $cal(I) models Phi$ to mean that $cal(I) models alpha$ for every $alpha in Phi$.

If $Phi$ is a set of $Sigma$-formulas and $alpha$ is a $Sigma$-formula, then $Phi$ _entails_ or _logically implies_ $alpha$, denoted $Phi models alpha$, if #box[$cal(I) models alpha$] for every interpretation $cal(I)$ of $Sigma$ such that $cal(I) models Phi$.

We write $alpha models beta$ as an abbreviation for ${alpha} models beta$.

$alpha$ and $beta$ are _logically equivalent_, denoted $alpha equiv beta$, iff $alpha models beta$ and $beta models alpha$.

A $Sigma$-formula $alpha$ is _valid_, denoted $models alpha$, if $emptyset models alpha$ iff $cal(I) models alpha$ for every interpretation $cal(I)$ of $Sigma$.

#example[
  Let $Sigma^S = {ASort}$, $Sigma^F = {p, q}$, $rank(p) = angle.l ASort, BoolSort angle.r$, $rank(q) = angle.l ASort, ASort, BoolSort angle.r$, and all variables $v_i$ have sort $ASort$.
  Do the following entailments hold?
  + $forall v_1. thin p(v_1) models p(v_2)$ #YES
  + $p(v_1) models forall v_1. thin p(v_1)$ #NO
  + $forall p(v_1) models exists v_2. thin p(v_2)$ #YES
  + $exists v_2 thin forall v_1. thin q(v_1, v_2) models forall v_1 thin exists v_2. thin q(v_1, v_2)$ #YES
  + $forall v_1 thin exists v_2. thin q(v_1, v_2) models exists v_2 thin forall v_1. thin q(v_1, v_2)$ #NO
  + $models exists v_1. thin (p(v_1) imply forall v_2. thin p(v_2))$ #YES
]

== Exercise

Let $alpha$ be a $Sigma$-formula and let $Gamma$ be a sort context that includes all free variables of $alpha$.

Consider the signature where $Sigma^S = {sigma}$, $Sigma^F = {Q, eqq_sigma}$, $Gamma = {x:sigma, y:sigma}$, $rank(Q) = angle.l sigma, sigma, BoolSort angle.r$.

For each of the following $Sigma$-formulas, describe an interpretation that satisfies it.
+ $forall x:sigma. thin forall y:sigma. thin x eqq y$
+ $forall x:sigma. thin forall y:sigma. thin Q(x,y)$
+ $forall x:sigma. thin exists y:sigma. thin Q(x,y)$

== From English to FOL

+ There is a natural number that is smaller than any _other_ natural number. \
  $exists x : NatSort. thin forall y : NatSort. thin (x eqq y) or (x < y)$
+ For every natural number there is a greater one. \
  $forall x : NatSort. thin exists y : NatSort. thin (x < y)$
+ Two natural numbers are equal only if their respective successors are equal. \
  $forall x : NatSort. thin forall y : NatSort. thin (x eqq y) imply (S(x) eqq S(y))$
+ Two natural numbers are equal if their respective successors are equal. \
  $forall x : NatSort. thin forall y : NatSort. thin (S(x) eqq S(y)) imply (x eqq y)$
+ No two distinct natural number have the same successor. \
  $forall x : NatSort. thin forall y : NatSort. thin not (x eqq y) imply not (S(x) eqq S(y))$
+ There are at least two natural number smaller than 3. \
  $exists x : NatSort. thin exists y : NatSort. thin not (x eqq y) and (x < S(S(S(0)))) and (y < S(S(S(0))))$
+ There is no largest natural number. \
  $not exists x : NatSort. thin forall y : NatSort. thin (y eqq x) or (y < x)$ \

#pagebreak()

+ Everyone has a father and a mother. \
  $forall x : PersonSort. thin exists y : PersonSort. thin exists z : PersonSort. thin (y eqq pa(x)) and (z eqq ma(x))$
+ The marriage relation is symmetric. \
  $forall x : PersonSort. thin forall y : PersonSort. thin sp(x,y) imply sp(y,x)$
+ No one can be married to themselves. \
  $forall x : PersonSort. thin not sp(x,x)$
+ Not all people are married. \
  $not forall x : PersonSort. thin exists y : PersonSort. thin sp(x,y)$
+ Some people have a farther and a mother who are not married to each other. \
  $exists x : PersonSort. thin not sp(ma(x), pa(x))$
+ You cannot marry more than one person. \
  $forall x : PersonSort. thin forall y : PersonSort. thin forall z : PersonSort. thin (sp(x,y) and sp(x,z)) imply (y eqq z)$
+ Some people are not mothers. \
  $exists x : PersonSort. thin forall y : PersonSort. thin not (x eqq ma(y))$
+ Nobody can be both a farther and a mother. \
  $forall x : PersonSort. thin not exists y : PersonSort. thin not exists z : PersonSort. thin (x eqq pa(y)) and (x eqq ma(z))$
+ Nobody can be their own or farther's farther. \
  $forall x : PersonSort. thin not ((x eqq pa(x)) or (x eqq pa(pa(x))))$
+ Some people do not have children. \
  $exists x : PersonSort. thin forall y : PersonSort. thin not (y eqq pa(x)) and not (y eqq ma(y))$

== Invariance of Term Values

Consider a signature $Sigma$, a sort context $Gamma$, and two interpretations $cal(I)$ and $cal(J)$ that agree on the sorts and symbols of $Sigma$.

#theorem[
  If $cal(I)$ and $cal(J)$ also agree on the variables of a $Sigma$-term $t$, then $t^overline(cal(I)) = t^overline(cal(J))$.
  // Note: variables must be in Gamma
]

#proof[
  By structural induction on $t$.
  - If $t$ is a variable or a constant, then $t^overline(cal(I)) = t^cal(I)$ and $t^cal(J) = t^overline(cal(J))$.
    Since $t^cal(I) = t^cal(J)$ by assumption, we have $t^overline(cal(I)) = t^overline(cal(J))$.
  - If $t$ is a term $sexp(f, t_1, dots.c, t_n)$ with $n > 1$, then $f^cal(I) = f^cal(J)$ by assumption and $t_i^overline(cal(I)) = t_i^overline(cal(J))$ for $j gt.eq 1$ by induction hypothesis.
    It follows, $t^overline(cal(I)) = f^cal(I)\(t_1^overline(cal(I)), dots, t_n^overline(cal(I))\) = f^cal(J)\(t_1^overline(cal(J)), dots, t_n^overline(cal(J))\) = t^overline(cal(J))$.
]

== Invariance of Truth Values

#theorem[
  If $cal(I)$ and $cal(J)$ also agree on the _free_ variables of a $Sigma$-formula $alpha$, then $alpha^overline(cal(I)) = alpha^overline(cal(J))$.
  // Note: free variables must be in Gamma
] <thm:invariance>

#proof[
  By induction on $alpha$.
  - If $alpha$ is an atomic formula, the result follows from the previous lemma, since $alpha$ is a term and all of its variables are free in it.
  - If $alpha$ is $not beta$ or $alpha_1 ast alpha_2$ with $ast in {and, or, imply, iff}$, the result follows from the induction hypothesis.
  - If $alpha$ is $op(Q) x : sigma. thin beta$ with $op(Q) in {forall, exists}$, then $FreeVars(beta) = FreeVars(alpha) union {x}$.
    For any $c$ in $sigma^cal(I)$, $cal(I)[x maps c]$ and $cal(J)[x maps c]$ agree on $x$ by construction and on $FreeVars(alpha)$ by assumption.
    The result follows from the induction hypothesis and the semantics of $forall$ and $exists$.
]

#corollary[
  The truth value of _$Sigma$-sentences_ is independent from how the variables are interpreted.
]

== Deduction Theorem of FOL

#theorem[
  For all $Sigma$-formulas $alpha$ and $beta$, we have $alpha models beta$ iff $alpha imply beta$ is valid.
]

#proof[($arrow.double.r$)][
  _If $alpha models beta$ then $alpha imply beta$ is valid_.

  Let $cal(I)$ be an interpretation and let $gamma := alpha imply beta$.
  - If $cal(I)$ falsifies $alpha$, then it trivially satisfies $gamma$.
  - If $cal(I)$ satisfies $alpha$, then, since $alpha models beta$, it must also satisfy $beta$. Hence, it satisfies $gamma$.
  In both cases, $cal(I)$ satisfies $gamma$, thus $cal(I) models alpha imply beta$ for every interpretation $cal(I)$.
]

#proof[($arrow.double.l$)][
  _If $alpha imply beta$ is valid then $alpha models beta$._

  Let $cal(I)$ be an interpretation that satisfies $alpha$.
  If $cal(I)$ falsifies $beta$, then it must also falsify $alpha imply beta$, contradicting the assumption that $alpha imply beta$ is valid.
  Thus, every interpretation $cal(I)$ that satisfies $alpha$ also satisfies $beta$.
]

#corollary[
  For all $Sigma$-formulas $alpha$ and $beta$, we have $models alpha imply beta$ iff $alpha imply beta$ is valid.
]

== Free Variables Theorem 1

#theorem[
  Consider a signature $Sigma$ and a sort context $Gamma$.
  Let $Phi$ be a set of $Sigma$-formulas, let $alpha$ be a #box[$Sigma$-formula] with free variables from $Gamma$, and let $x in FreeVars(alpha)$ be a free variable of sort $sigma$ in $Gamma$.

  Suppose $x$ occurs free in no formulas of $Phi$.
  Then, $Phi models alpha$ iff $Phi models forall x : sigma. thin alpha$.
]

#proof[($arrow.double.r$)][
  _If $Phi models alpha$ then $Phi models forall x : sigma. thin alpha$._

  Let $cal(I)$ be an interpretation that satisfies $Phi$.
  Since $x$ does not occur free in any formulas of $Phi$, $cal(I)$ satisfies all formulas in $Phi$ regardless of how it interprets $x$.
  Then, for any element $c in sigma^cal(I)$, the interpretation $cal(I)[x maps c]$ satisfies all formulas in $Phi$, including $alpha$ (because $Phi models alpha$).
  Thus, it also satisfies the formula $forall x : sigma. thin alpha$, by the semantics of $forall$.
  Hence, every interpretation that satisfies $Phi$ also satisfies $forall x : sigma. thin alpha$, that is, $Phi models forall x : sigma. thin alpha$.
]

#proof[($arrow.double.l$)][
  _If $Phi models forall x : sigma. thin alpha$ then $Phi models alpha$._

  Let $cal(I)$ be an interpretation that satisfies $Phi$.
  By assumption, $cal(I) models forall x : sigma. thin alpha$.
  This implies that $cal(I) models alpha$ regardless of how $cal(I)$ interprets $x$.
  Hence, $Phi models alpha$.
]

== Free Variables Theorem 2

#theorem[
  Consider a signature $Sigma$ and a sort context $Gamma$.
  Let $beta$ be a $Sigma$-formula, let $alpha$ be a $Sigma$-formula with free variables from $Gamma$, and let $x in FreeVars(alpha)$ be a free variable of sort $sigma$ in $Gamma$.

  Suppose $x$ does not occur free in $beta$.
  Then, $alpha models beta$ iff $exists x : sigma. thin alpha models beta$.
]

#proof[($arrow.double.r$)][
  _If $alpha models beta$ then $exists x : sigma. thin alpha models beta$._

  Let $cal(I)$ be an interpretation that satisfies $exists x : sigma. alpha$.
  This means that $cal(I)[x maps c]$ satisfies $alpha$ for some $c in sigma^cal(I)$.
  By assumption, $cal(I)[x maps c]$ satisfies $beta$ as well.
  Since $x$ does not occur free in $beta$, changing the value assigned to $x$ does not matter.
  It follows that $cal(I)$ satisfies $beta$.
  Since $cal(I)$ was arbitrary, this shows that $exists x : sigma. alpha models beta$.
]

#proof[($arrow.double.l$)][
  _If $exists x : sigma. thin alpha models beta$ then $alpha models beta$._

  Let $cal(I)$ be an interpretation that satisfies $alpha$.
  Then, trivially#footnote[Recall that any _domain_ $sigma^cal(I)$ is _non-empty_.], $cal(I)$ satisfies $exists x : sigma. thin alpha$.
  By assumption, $cal(I) models beta$.
  Since~$cal(I)$ was arbitrary, $alpha models beta$.
]

= Model Checking

== Semantics in FOL

#definition[Vocabulary][
  A _vocabulary_ (also known as _signature_) of a language is a collection of symbols used to construct sentences in that language.
  A vocabulary $cal(V) = angle.l cal(C), cal(F), cal(P) angle.r$ consists of:
  - A set of _constant symbols_ $cal(C)$, e.g., $0$, $bot$, $emptyset$, $dots$
  - A set of _function symbols_ $cal(F)$, e.g., $S$, $plus$, $times$, $dots$
  - A set of _predicate symbols_ $cal(P)$, e.g., $eq$, $lt$, $in$, $dots$
]

#definition[Model][
  A _possible world_ (also known as _model_, or _structure_, or _interpretation_) is a mathematical object that gives meaning to the symbols in a vocabulary.
  A model $cal(M)$ for $cal(V)$ consists of:
  - A _domain_ $cal(D) = dom(cal(M))$, which is a non-empty set of objects (_universe_).
  - For each constant symbol $c$ in $cal(C)$, its interpretation $c^cal(M)$ is an element of $cal(D)$.
  - For each $k$-ary function symbol $f$ in $cal(F)$, its interpretation $f^cal(M)$ is a $k$-ary total function on $cal(D)$.
  - For each $k$-ary predicate symbol $p$ in $cal(P)$, its interpretation $p^cal(M)$ is a $k$-ary relation on $cal(D)$.
]

== Semantics Example

#example[
  Let $cal(V)_"field"$ consist of 2-ary functions $plus$ and $times$, constants $0$ and $1$, and 2-ary predicates $eq$ and $lt$.

  One possible interpretation $cal(M)$ is:
  - $cal(D) = ZZ$, the integer numbers. $0^cal(M)$ and $1^cal(M)$ are the usual integers zero and one.
  - $scripts(plus)^cal(M)$, $scripts(times)^cal(M)$, $scripts(eq)^cal(M)$, $scripts(lt)^cal(M)$ are the usual arithmetic operators on integers.

  Alternatively, $cal(D) = RR$, $0^cal(M) := 3.14159$, $1^cal(M) := 42$.
  There are infinitely many possible interpretations!
]

== Predicate Logic Statements

#definition[Formula][
  A _formula_ is a statement about the objects in a world.

  #example[
    $x$ is a even number.
  ]
]

#definition[Sentence][
  A _sentence_ is a statement about a world.

  #example[
    Every even natural number greater than 2 is a sum of two prime numbers.
  ]
]

== Some Computational Challenges

#table(
  columns: 3,
  stroke: none,
  table.header[Decision problem][Formalization][Description],
  [Validity], [$models phi$], [Is $phi$ true in every world?],
  [Satisfiability], [$exists cal(M). thin cal(M) models phi$], [Is $phi$ true in some world?],
  [Model checking], [$cal(M) models phi$], [Is $phi$ true in a given world?],
)

== FOL and Computation

First basic computational problem in predicate logic is _Model Checking_.

#definition[
  Model checking problem for first-order logic is the problem of determining whether a given first-order formula $phi$ is satisfied by a given structure $cal(M)$, formally, $cal(M) models phi$.

  $ "MCFO" = { angle.l cal(M), phi angle.r | cal(M) models phi } $
]

#note[
  MCFO is decidable in $abs(cal(M))^abs(phi)$ time.
]

#pagebreak()

#theorem[
  MCFO is NP-hard.
]
#proof[
  SAT can be reduced to MCFO.

  Let $phi$ be a propositional formula.
  For example, $phi := (p_1 or not p_2 or p_3) and dots$

  Construct a model $cal(M)$ with interpretations for $True$ and $False$, and a first-order formula $phi'$:
  $ phi' := exists x_1, dots, x_n. thin ((x_1 = True) or (not x_2 = True) or (x_3 = True)) and dots $

  Then, $phi$ is satisfiable iff $cal(M) models phi'$.
]

== FOL and Computation

Second basic computational problem in predicate logic is _Finite Satisfiability Problem_.

Given a sentence $phi$, is it finitely satisfiable?
That is, does there exist a _finite_ model $cal(M)$ such that $cal(M) models phi$?

FSP is semi-decidable, undecidable.

Corollary: Finite Validity is not RE, but in co-RE.

More:
- set of validities in FOL is in RE
- FOL satisfiability is undecidable

// == Bibliography
// #bibliography("refs.yml")

== TODO: Exercises
- Parse tree of a FOL formula
- Describe Euclidean geometry as a FOL theory
