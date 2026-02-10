#import "../common.typ": *
#show: template.with()

#set text(12pt)

#set page(header: {
  place(bottom, dy: 0.4em)[#line(length: 100%, stroke: 0.6pt)]
  [*Homework \#1: Formal Logic*]
  h(1fr)
  link("https://github.com/Lipen/formal-methods-course")[*FMSE 2026*]
})

#show heading.where(level: 2): set block(above: 1.5em)

#let Items(body) = {
  set enum(numbering: "(a)")
  show enum.item: it => {
    let (number, body, ..fields) = it.fields()
    if body.func() == block { return it }

    body = block(breakable: false, body)
    enum.item(number, body, ..fields)
  }
  body
}

#let Block(
  color: blue,
  body,
  ..args,
) = block(
  body,
  fill: color.lighten(90%),
  stroke: 1pt + color.darken(20%),
  radius: 5pt,
  inset: 1em,
  ..args,
)

#Block(width: 100%)[
  *Submission guidelines:*
  - Present complete, self-contained solutions.
  - For proofs: use Fitch notation (numbered steps, subproofs, rule citations).
  - For tableaux/resolution: show the full derivation tree.
  - For semantic arguments: provide explicit interpretations and show evaluations.
  - For counterexamples: give a concrete model and demonstrate the failure.
  - For transformations: show all intermediate steps.
]

== Problem 1: Natural deduction (Fitch proofs)

Construct a natural deduction proof for each sequent below.
Use Fitch notation: numbered steps, proper subproof indentation, explicit rule citations.

*Strategy hints:*
- To prove $alpha imply beta$, use $imply$i: assume $alpha$, derive $beta$, discharge.
- To prove $not alpha$, use $not$i: assume $alpha$, derive $bot$, discharge.
- To use $alpha or beta$, apply $or$e: derive the goal from each disjunct separately.
- For contradictions, $bot$e lets you derive anything; RAA lets you derive $alpha$ from $not alpha tack bot$.

#Items[
  + $A imply C, thin B imply C, thin A or B tack C$ #h(1fr) _(disjunction elimination)_

  + $A imply B, thin A imply not B tack not A$ #h(1fr) _(reductio ad absurdum)_

  + $tack (A imply B) imply ((not A imply bot) imply B)$ #h(1fr) _(nested implications)_

  + $tack P or not P$ #h(1fr) _(law of excluded middle --- derive it, don't assume it)_

  + $tack ((A imply B) imply A) imply A$ #h(1fr) _(Peirce's law)_

  + $not A imply not B tack B imply A$ #h(1fr) _(contrapositive, classical)_

  + $tack (A imply (B imply C)) imply ((A imply B) imply (A imply C))$ #h(1fr) _(distributivity of $imply$)_

  + $(A imply B), thin (not A imply B) tack B$ #h(1fr) _(case analysis)_

  + $A or (B imply A) tack not A imply not B$ #h(1fr) _(combining disjunction and negation)_

  + $tack (not not A imply A) imply ((A imply not not A) imply (A iff not not A))$ #h(1fr) _(double negation equivalence)_
]

== Problem 2: Semantics: validity, entailment, and countermodels

For each claim below, determine whether it holds.
- If *valid/entails*, justify with a brief semantic argument or a truth table.
- If *invalid*, give a concrete counterexample: an interpretation $nu$ (specifying $nu(p), nu(q), dots$) and show the evaluation that falsifies the claim.

#Items[
  + $A imply B, thin B imply C models A imply C$ #h(1fr) _(transitivity)_

  + $A or B, thin not A models B$ #h(1fr) _(disjunctive syllogism)_

  + $A imply B models not B imply not A$ #h(1fr) _(contraposition)_

  + $A imply B models B imply A$ #h(1fr) _(converse --- suspicious!)_

  + $models (A and B) imply A$ #h(1fr) _(conjunction elimination)_

  + $models ((A imply B) and (A imply not B)) imply not A$ #h(1fr) _(proof by contradiction)_

  + $A iff B, thin B iff C models A iff C$ #h(1fr) _(equivalence transitivity)_

  + $models (A imply B) or (B imply A)$ #h(1fr) _(linearity of implication --- tricky!)_
]

== Problem 3: Normal forms and Tseitin transformation

SAT solvers operate on CNF. This problem practices the two main conversion strategies: direct transformation (via distributivity) and Tseitin encoding (equisatisfiability with fresh variables).

#Items[
  + *Direct CNF conversion.*
    Convert $(not A or B) and (not B or C) imply (not A or C)$ to CNF by:
    - Eliminating $imply$ (rewrite using $not$, $or$).
    - Pushing negations to atoms (De Morgan, double negation).
    - Distributing $or$ over $and$ to obtain CNF.
    - State whether the result is satisfiable (give a model or show unsatisfiability).

  + *Tseitin transformation.*
    Convert $(P_1 iff P_2) iff (P_3 iff P_4)$ to _equisatisfiable_ CNF.
    - Introduce fresh variable $N_i$ for each complex subformula $alpha$.
    - Write definitional clauses $N_i iff alpha$.
    - Convert each $iff$ definition to CNF.
    - Write the final clausal form.
    - *Compare:* How many clauses does your Tseitin encoding have?
      How many would the _direct_ distributive CNF have?

  + *NNF without CNF.*
    Convert $not ((A imply B) and (C or not D))$ to Negation Normal Form (NNF) --- negations only on atoms, but _no_ requirement for CNF, i.e. do not distribute.
]

== Problem 4: Proof system comparison: Tableaux and Resolution

Both semantic tableaux and resolution are _refutation systems_: to prove $Gamma models alpha$, they attempt to derive a contradiction from $Gamma union {not alpha}$.

#Items[
  + *Tableaux.*
    Use the semantic tableaux method to prove:
    $ models (P imply Q) imply (not Q imply not P) $
    Negate the formula, apply decomposition rules ($alpha$-rules extend, $beta$-rules branch), and show that all branches close. If you find an open branch, give the countermodel it represents.

  + *Resolution.*
    Use resolution refutation to prove:
    $ {P or Q, thin not P or R, thin not Q or R} models R $
    Convert $Gamma union {not r}$ to CNF (one clause per formula), then derive the empty clause $square$ by repeated resolution steps.
    Annotate each resolvent with the parent clauses and the pivot literal.

  + *Comparison.*
    For the formula $(A imply B) and (B imply C) and A and not C$:
    - Show it is _unsatisfiable_ using tableaux (exhibit the closed tree).
    - Show it is _unsatisfiable_ using resolution (derive $square$).
    - Which method required fewer steps? Briefly explain why.
]

== Problem 5: Modeling with propositional logic

Consider a simplified access control system with four propositional atoms:
- $P$: production mode is active
- $D$: debug mode is active
- $L$: verbose logging is enabled
- $S$: strict security checks are enforced

The system specification states:
+ Production mode requires strict security.
+ Debug mode requires verbose logging.
+ Strict security is incompatible with debug mode.
+ The system is always in exactly one mode: production or debug.
+ If logging is disabled, the system cannot be in debug mode.

#Items[
  + Express the specification as a single formula $Phi_"spec"$ (a conjunction of the five constraints).

  + Determine whether $Phi_"spec" models (P imply not D)$.
    Justify or provide a countermodel.

  + Determine whether $Phi_"spec" models (not L imply not P)$.
    Justify or provide a countermodel.

  + Show that $Phi_"spec"$ is satisfiable by giving _two_ distinct models (interpretations satisfying all constraints).
    What are the only two valid system configurations?
]

== Problem 6: First-order logic and metatheory

This problem explores quantifiers, structures, and fundamental limitations of FOL.

#Items[
  + *Formalization.*
    Express the following statements in first-order logic over the signature ${E(dot.c, dot.c), dot.c lt.eq dot.c}$ (where $E(X, Y)$ means "$X$ is an edge to $Y$" and $lt.eq$ is a partial order on vertices):
    - Every vertex has at most one outgoing edge.
    - There exists a vertex from which all other vertices are reachable (directly or transitively).
    - The graph is acyclic.

  + *Quantifier equivalences.*
    Determine whether the following are _logically valid_ (true in all structures).
    If valid, justify; if not, give a countermodel.
    - $exists X. thin forall Y. thin R(X, Y) quad tack quad forall Y. thin exists X. thin R(X, Y)$
    - $forall Y. thin exists X. thin R(X, Y) quad tack quad exists X. thin forall Y. thin R(X, Y)$

  + *Prenex Normal Form.*
    Convert to prenex normal form (all quantifiers at the front):
    $ (forall x. thin P(x)) imply (exists y. thin Q(y)) $

    _Hint:_ Rename bound variables to avoid capture (note: variables $x, y$ are bound), then move quantifiers outward.

  + *Natural deduction in FOL.*
    Prove:
    $ forall x. thin (P(x) imply Q(x)), thin forall x. thin P(x) quad tack quad forall x. thin Q(x) $
    Use Fitch notation with quantifier rules.
    Recall: $forall$e instantiates to any term; $forall$i requires an arbitrary (fresh) variable.

  + *Compactness and infinity.*
    Let $Gamma = {exists x. thin x != c} union {exists x exists y. thin (x != y and x != c and #box[$y != c$])} union dots$
    (i.e., "there are at least $n$ elements distinct from $c$" for every $n in NN$).
    - Show that every _finite_ subset $Gamma_0 subset.eq Gamma$ is satisfiable.
    - By compactness, what does this imply about $Gamma$ itself?
    - Conclude: "the domain is infinite" can be expressed by an infinite set of FOL sentences, but not by a _single_ sentence (or any finite set). Why?
]

= Notation Reference

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 1em,
  [
    *Semantic relations:*
    - $Gamma models phi$ --- semantic entailment
    - $nu models phi$ --- interpretation $nu$ satisfies $phi$
    - $models phi$ --- $phi$ is valid (tautology)
  ],
  [
    *Syntactic relations:*
    - $Gamma tack phi$ --- syntactic derivability
    - Fitch rules: $and$i/e, $or$i/e, $imply$i/e, $not$i/e, $bot$e, RAA, LEM
    - FOL rules: $forall$i/e, $exists$i/e
  ],
)
