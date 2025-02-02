#import "common.typ": *
#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "Propositional Logic",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: false,
)

#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge

#import "@preview/curryst:0.4.0": rule, proof-tree

#import "@preview/cheq:0.2.2": checklist
#show: checklist

#import "@preview/colorful-boxes:1.4.2": *

#show heading.where(level: 3): set block(above: 1em, below: 0.6em)

= Propositional Logic

== Motivation

- Boolean functions are at the core of logic-based reasoning.
- A Boolean function $F(X_1, ..., X_n)$ describes the output of a system based on its inputs.
- Boolean gates (AND, OR, NOT) form the building blocks of digital circuits.
- Propositional logic formalizes reasoning about Boolean functions and circuits.
- *Applications*:
  - Digital circuit design.
  - Verification and synthesis of hardware and software.
  - Expressing logical constraints in AI and optimization problems.
  - Automated reasoning and theorem proving.

== Boolean Circuits and Propositional Logic

*Boolean circuit* is a directed acyclic graph (DAG) of Boolean gates.
- Inputs: Propositional variables.
- Outputs: Logical expressions describing the circuit's behavior.

_"Can the output of a circuit ever be true?"_
- Propositional logic provides a formal framework to answer such questions.

*Real-world examples*:
- Error detection circuits.
- Arithmetic logic units (ALUs) in processors.
- Routing logic in network devices.

== What is Logic?

A formal logic is defined by its *syntax* and *semantics*.

=== Syntax
- An *alphabet* $Sigma$ is a set of symbols.
- A finite sequence of symbols (from $Sigma$) is called an *expression* or *string* (over $Sigma$).
- A set of rules defines the *well-formed* expressions.

=== Semantics
- Gives meaning to (well-formed) expressions.

== Syntax of Propositional Logic

=== Alphabet
+ Logical connectives: $not$, $and$, $or$, $imply$, $iff$.
+ Propositional variables: $A_1, A_2, dots, A_n$.
+ Parentheses for grouping: $($, $)$.

=== Well-Formed Formulas (WFFs)

// Valid (*well-formed*) expressions are defined *inductively*:
+ A single propositional symbol (e.g. $A$) is a WFF.
+ If $alpha$ and $beta$ are WFFs, so are:~ $not alpha$,~ $(alpha and beta)$,~ $(alpha or beta)$,~ $(alpha imply beta)$,~ $(alpha iff beta)$.
+ No other expressions are WFFs.

=== Conventions

- Large variety of propositional variables: $A, B, C, dots, p, q, r, dots$.
- Outer parentheses can be omitted: $A and B$ instead of $(A and B)$.
- Operator precedence: $not thick > thick and thick > thick or thick > thick imply thick > thick iff$.
// - Left-to-right associativity for $and$ and $or$: #h(1em) $A and B and C = (A and B) and C$.
// - Right-to-left associativity for $imply$: #h(1em) $A imply B imply C = A imply (B imply C)$.

== Semantics of Propositional Logic

#let Eval(x) = $bracket.l.double #x bracket.r.double$

- Each propositional variable is assigned a truth value: $T$ (true) or $F$ (false).

- More formally, _interpretation_ $nu: V arrow {0, 1}$ assigns truth values to all variables (atoms).

- Truth values of complex formulas are computed (evaluated) recursively:
  + $#Eval($p$) eq.delta nu(p)$, where $p in V$ is a propositional variable
  + $#Eval($not alpha$) eq.delta 1 - #Eval($alpha$)$
  + $#Eval($alpha and beta$) eq.delta min(#Eval($alpha$), #Eval($beta$))$
  + $#Eval($alpha or beta$) eq.delta max(#Eval($alpha$), #Eval($beta$))$
  + $#Eval($alpha imply beta$) eq.delta #Eval($alpha$) leq #Eval($beta$)$
  + $#Eval($alpha iff beta$) eq.delta #Eval($alpha$) = #Eval($beta$)$

== Truth Tables

#table(
  columns: 4,
  align: center,
  table.header($alpha$, $beta$, $gamma$, $alpha and (beta or not gamma)$),
  ..(
    for alpha in (false, true) {
      for beta in (false, true) {
        for gamma in (false, true) {
          (alpha, beta, gamma, alpha and (beta or not gamma)).map(b => if b {
            text(fill: green.darken(20%))[1]
          } else {
            text(fill: red.darken(20%))[0]
          })
        }
      }
    }
  )
)

== Validity, Satisfiability, Entailment

=== Validity
- $alpha$ is a *tautology* if $alpha$ is true under all truth assignments. \
  Formally, $alpha$ is *valid*, denoted "$models alpha$", iff $nu(alpha) = 1$ for all interpretations $nu in {0,1}^V$.
- $alpha$ is a *contradiction* if $alpha$ is false under all truth assignments. \
  Formally, $alpha$ is *unsatisfiable* if $nu(alpha) = 0$ for all interpretations $nu in {0,1}^V$.

=== Satisfiability
- $alpha$ is *satisfiable* (*consistent*) if there exists an interpretation $nu in {0,1}^V$ where $nu(alpha) = 1$. \
  When $alpha$ is satisfiable by $nu$, denoted $nu models alpha$, this interpretation is called a *model* of $alpha$.
- $alpha$ is *falsifiable* (*invalid*) if there exists an interpretation $nu in {0,1}^V$ where $nu(alpha) = 0$.

=== Entailment
- Let $Gamma$ be a set of WFFs. Then $Gamma$ *tautologically implies* (*semantically entails*) $alpha$, denoted $Gamma models alpha$, if~every truth assignment that satisfies all formulas in $Gamma$ also satisfies $alpha$.
- Formally, $Gamma models alpha$ iff for all interpretations $nu in {0,1}^V$ and formulas $beta in Gamma$, if $nu models beta$, then $nu models alpha$.
- Note: $alpha models beta$, where $alpha$ and $beta$ are WFFs, is just a shorthand for ${alpha} models beta$.

== Examples

- $A or B and (not A and not B)$ is satisfiable, but not valid.
- $A or B and (not A and not B) and (A iff B)$ is unsatisfiable.
- ${A, A imply B} models B$
- ${A, not A} models A and not A$
- $not (A and B)$ is tautologically equivalent to $not A or not B$.

== Duality of SAT vs VALID

- *SAT*: Given a formula $alpha$, determine if it is satisfiable.
  $ exists nu . nu(alpha) $

- *VALID*: Given a formula $alpha$, determine if it is valid.
  $ forall nu . nu(alpha) $

- *Duality*: $alpha$ is valid iff $not alpha$ is unsatisfiable.

- Note: SAT is NP, but VALID is co-NP.

== Solving SAT using Truth Tables

=== Algorithm for satisfiability

To check whether $alpha$ is satisfiable, construct a truth table for $alpha$.
If there is a row where $alpha$ evaluates to true, then $alpha$ is satisfiable.
Otherwise, $alpha$ is unsatisfiable.

=== Algorithm for semantical entailment (tautological implication)

The check whether ${alpha_1, dots, alpha_k} models beta$, check the satisfiability of $(alpha_1 and dots and alpha_k) and (not beta)$.
If it is unsatisfiable, then ${alpha_1, dots, alpha_k} models beta$.
Otherwise, ${alpha_1, dots, alpha_k} not models beta$.

== Logical Laws and Tautologies

- *Associative* and *Commutative* laws for $and$, $or$, $iff$:
  - $A compose (B compose C) equiv (A compose B) compose C$
  - $A compose B equiv B compose A$

- *Distributive laws*:
  - $A and (B or C) equiv (A and B) or (A and C)$
  - $A or (B and C) equiv (A or B) and (A or C)$
- *Negation*:
  - $not not A equiv A$
- *De Morgan's laws*:
  - $not(A and B) equiv not A or not B$
  - $not(A or B) equiv not A and not B$

#pagebreak()

- *Implication*:
  - $(A imply B) equiv (not A or B)$

- *Contraposition*:
  - $(A imply B) equiv (not B imply not A)$
- *Law of Excluded Middle*:
  - $(A or not A) equiv top$
- *Contradiction*:
  - $(A and not A) equiv bot$
- *Exportation*:
  - $((A and B) imply C) equiv (A imply (B imply C))$

== Example Problems

- Given $alpha = (A or B) and not A$, determine:
  + Is $alpha$ consistent (satisfiable)?
  + Is $alpha$ valid (a tautology)?
  + Compute the truth table for $alpha$.

== Completeness of Connectives

- All Boolean functions can be expressed using ${not, and, or}$ (so called _"standard Boolean basis"_~).

- Even smaller sets are sufficient:
  - ${not, and}$ --- AIG (And-Inverter Graph), see also: #link("http://github.com/arminbiere/aiger")[AIGER format].
  - ${not, or}$
  - ${overline(and)}$ --- NAND
  - ${overline(or)}$ --- NOR

== Incompleteness of Connectives

TODO

== Compactness

Recall:
- A WFF $alpha$ is *satisfiable* if there exists an interpretation $nu$ such that $nu models alpha$.
- A set of WFFs $Sigma$ is *satisfiable* if there exists an interpretation $nu$ that satisfies all formulas in $Sigma$.
- A set of WFFs $Sigma$ is *finitely satisfiable* if every finite subset of $Sigma$ is satisfiable.

#theorem(title: [Compactness Theorem])[
  A set of WFFs $Sigma$ is satisfiable iff it is finitely satisfiable.
]

_Proof._

*(`=>`)* Suppose $Sigma$ is satisfiable, i.e. there exists an interpretation $nu$ that satisfies all formulas in $Sigma$.

This direction is trivial: any subset of a satisfiable set is clearly satisfiable.
- For each finite subset $Sigma' subset.eq Sigma$, $nu$ also satisfies all formulas in $Sigma'$.
- Thus, every finite subset of $Sigma$ is satisfiable.

#pagebreak()

*(`<=`)* Suppose $Sigma$ is finitely satisfiable, i.e. every finite subset of $Sigma$ is satisfiable.

Construct a _maximal_ finitely satisfiable set $Delta$ as follows:

- Let $alpha_1, dots, alpha_n, dots$ be a fixed enumeration of all WFFs.
  - _This is possible since the set of all sequences of a countable set is countable._

- Then, let:
  $
    Delta_0 &= Sigma, \
    Delta_(n+1) &= cases(
      Delta_n union {alpha_(n+1)} "if this is finitely satisfiable,",
      Delta_n union {not alpha_(n+1)} "otherwise.",
    )
  $
  - _Note that each $Delta_n$ is finitely satisfiable by construction._

- Let $Delta = union.big_(n in NN) Delta_n$. Note:
  + $Sigma subset.eq Delta$
  + $alpha in Delta$ or $not alpha in Delta$ for any WFF $alpha$
  + $Delta$ is finitely satisfiable by construction.

Now we need to show that $Delta$ is satisfiable (and thus $Sigma subset.eq Delta$ is also satisfiable).

Define an interpretation $nu$ as follows: for each propositional variable $p$, let $nu(p) = 1$ iff $p in Delta$.

We claim that $nu$ satisfies all formulas in $Delta$.
The proof is by induction on well-formed formulas.
- Base case: $p in Delta$ for some propositional variable $p$.
  - By definition, $nu(p) = 1$.
// - Inductive step: $alpha$ is a WFF and $nu$ satisfies all formulas in $Delta$.
//   - If $alpha in Delta$, then $nu(alpha) = 1$.
//   - If $not alpha in Delta$, then $nu(not alpha) = 1 - nu(alpha) = 0$.
//   - In either case, $nu(alpha) = 1$.
- TODO: inductive step

== Normal Forms

- *Conjunctive Normal Form (CNF)*:
  - A formula is in CNF if it is a conjunction of _clauses_ (disjunctions of literals).
  - Example: $(A or B) and (not A or C) and (B or not C)$ --- CNF with 3 clauses.

- *Disjunctive Normal Form (DNF)*:
  - A formula is in DNF if it is a disjunction of _cubes_ (conjunctions of literals).
  - Example: $(not A and B) or (B and C) or (not A and B and not C)$ --- DNF with 3 cubes.

- *Algebraic Normal Form (ANF)*:
  - A formula is in ANF if it is a sum of _products_ of variables (or a constant 1).
  - Example: $B xor A B xor A B C$ --- ANF with 3 terms.

== Natural Deduction

- *Natural deduction* is a proof system for propositional logic.

- *Axioms*:
  - *No axioms*.

- *Rules*:
  - *Introduction*: $and$-introduction, $or$-introduction, $imply$-introduction, $not$-introduction.
  - *Elimination*: $and$-elimination, $or$-elimination, $imply$-elimination, $not$-elimination.
  - *Reduction ad Absurdum*
  - *Law of Excluded Middle* (note: forbidden in _intuitionistic_ logic)

- *Proofs* are constructed by applying rules to assumptions and previously derived formulas.

#align(center)[
  #proof-tree(
    title-inset: 0.5em,
    horizontal-spacing: 2pt,
    rule(
      name: "rule name",
      [$Gamma$ (_assumptions_) $entails$ (_conclusion_)],
      [$Gamma_1$ $entails$ (_premise 1_)],
      [$Gamma_2$ $entails$ (_premise 2_)],
      [$dots$],
    ),
  )
]

== Inference Rules

#let rules-grid = (..args) => {
  // Note: each 'arg' in 'args' is a 'rule(...)'
  set align(center)
  grid(
    columns: args.pos().len(),
    column-gutter: 1em,
    ..args
      .pos()
      .map(arg => diagram(
        node(
          (0, 0),
          proof-tree(arg),
          shape: fletcher.shapes.rect,
          corner-radius: 5pt,
          fill: green.lighten(80%),
          stroke: 1pt + green.darken(20%),
        ),
      ))
  )
  v(-0.5em)
}

#rules-grid(
  rule(
    name: [law of excluded middle],
    $Gamma entails phi or not phi$,
    [~],
  ),
  rule(
    name: [assumption],
    $Gamma, phi entails phi$,
    [~],
  ),
)

#rules-grid(
  rule(
    name: [reduction ad absurdum],
    $Gamma entails beta$,
    $Gamma entails alpha$,
    $Gamma entails not alpha$,
  ),
)

#rules-grid(
  rule(
    name: [$and$-elimination],
    $Gamma entails alpha$,
    $Gamma entails alpha and beta$,
  ),
  rule(
    name: [$and$-elimination],
    $Gamma entails beta$,
    $Gamma entails alpha and beta$,
  ),
  rule(
    name: [$and$-introduction],
    $Gamma entails alpha and beta$,
    $Gamma entails alpha$,
    $Gamma entails beta$,
  ),
)

#rules-grid(
  rule(
    name: [$or$-elim],
    $Gamma entails beta$,
    $Gamma entails alpha_1 or alpha_2$,
    $Gamma, alpha_1 entails beta$,
    $Gamma, alpha_2 entails beta$,
  ),
  rule(
    name: [$or$-intro],
    $Gamma entails alpha or beta$,
    $Gamma entails alpha$,
  ),
  rule(
    name: [$or$-intro],
    $Gamma entails alpha or beta$,
    $Gamma entails beta$,
  ),
)

#rules-grid(
  rule(
    name: [$imply$-elimination],
    $Gamma entails beta$,
    $Gamma entails alpha$,
    $Gamma entails alpha imply beta$,
  ),
  rule(
    name: [$imply$-introduction],
    $Gamma, alpha entails beta$,
    $Gamma entails alpha imply beta$,
  ),
)

== Soundness and Completeness

- A formal system is *sound* if every provable formula is true in all models.
  - *Weak soundness*: "every provable formula is a tautology". \
    // If $entails alpha$, then $models alpha$.
    #[
      #import fletcher.shapes: *
      #diagram(blob((0, 0), [If $entails alpha$, then $models alpha$.], shape: rect, tint: green))
    ]
  - *Strong soundness*: "every derivable (from $Gamma$) formula is a logical consequence (of $Gamma$)". \
    // If $Gamma entails alpha$, then $Gamma models alpha$.
    #[
      #import fletcher.shapes: *
      #diagram(blob((0, 0), [If $Gamma entails alpha$, then $Gamma models alpha$.], shape: rect, tint: green))
    ]

- A formal system is *complete* if every formula true in all models is provable.
  - *Weak completeness*: "every tautology is provable". \
    // If $models alpha$, then $entails alpha$.
    #[
      #import fletcher.shapes: *
      #diagram(blob((0, 0), [If $models alpha$, then $entails alpha$.], shape: rect, tint: blue))
    ]
  - *Strong completeness*: "every logical consequence (of $Gamma$) is derivable (from $Gamma$)". \
    // If $Gamma models alpha$, then $Gamma entails alpha$.
    #[
      #import fletcher.shapes: *
      #diagram(blob((0, 0), [If $Gamma models alpha$, then $Gamma entails alpha$.], shape: rect, tint: blue))
    ]

== Computability

#definition(title: [Church--Turing Thesis])[
  _Computable functions_ are exactly the functions that can be calculated using a mechanical (that is, automatic) calculation device given unlimited amounts of time and storage space.
]

#quote[
  Every model of computation that has ever been imagined can compute _only_ computable functions, and _all_ computable functions can be computed by any of several _models of computation_ that are apparently very different, such as Turing machines, register machines, lambda calculus and general recursive functions.
]

For example, a partial function $f : NN^k arrow.hook NN$ is computable ("can be calculated") if there exists a computer program with the following properties:
- If $f(x)$ is defined, then the program terminates on the input $x$ with the value $f(x)$ stored in the computer memory.
- If $f(x)$ is undefined, then the program never terminates on the input $x$.

#definition[
  An *effective procedure* is a finite, deterministic, mechanical algorithm that guarantees to terminate and produce the correct answer in a finite number of steps.
]

== Decidability

#definition(title: [Decidable set])[
  Given a universal set $cal(U)$, a set $S subset.eq cal(U)$ is *decidable* (or *computable*) if there exists a computable function $f : cal(U) to {0,1}$ such that $f(x) = 1$ iff $x in S$.
]

*Examples:*

- The set $W$ of all WFFs is decidable.
  - _We can check if a given string is well-formed by recursively verifying the syntax rules._

- For a given finite set $Sigma$ of WFFs, the set ${alpha | Sigma models alpha}$ of all tautological consequences of $Sigma$ is decidable.
  - _We can decide $Sigma models alpha$ using a truth table algorithm by enumerating all possible interpretations (at~most~$2^(|Sigma|)$) and check if each satisfies all formulas in $Sigma$._

- The set of all tautologies is decidable. \
  - _It is the set of all tautological consequences of the empty set._

TODO: undecidable sets (existence proof)

== Semi-decidability

Suppose we want to determine $Gamma models alpha$ where $Gamma$ is infinite.
In general, it is undecidable.

However, it is possible to obtain a weaker result.

#definition(title: [Semi-decidable set])[
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
]

_(here, we assume that $S$ is a set of WFFs)_

_(`=>` proof of "only if" part)_ \ If $S$ is computably enumerable, we can check if $alpha in S$ by enumerating all members of $S$ and checking if $alpha$ is among them.
If it is, we answer "yes"; otherwise, we continue enumerating.
Thus, if $alpha in S$, the procedure produces "yes".
If $alpha notin S$, the procedure runs forever.

_(`<=` proof of "if" part)_ \ On the other hand, suppose we have a procedure $P$ which, given $alpha$, terminates and produces "yes" iff $alpha in S$.
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

#pagebreak()

#theorem[
  A set is decidable iff both it and its complement are semi-decidable.
]

_Proof._ Alternate between running the procedure for the set and the procedure for its completement.
One of them will eventually produce "yes".

#pagebreak()

#theorem[
  If $Sigma$ is an effectively enumerable set of WFFs, then the set of tautological consequences of $Sigma$ is effectively enumerable.
]

_Proof._ Consider an enumeration of the elements of $Sigma$: $sigma_1, sigma_2, sigma_3, dots$

By the compactness theorem, $Sigma models alpha$ iff ${sigma_1, dots, sigma_n} models alpha$ for some $n$.

Hence, it is sufficient to successively test:
- $emptyset models alpha$
- ${sigma_1} models alpha$
- ${sigma_1, sigma_2} models alpha$
- $dots$

If any of these tests succeeds (each is decidable), then $Sigma models alpha$.

== Complexity

TODO

== TODO

- [x] Natural deduction
- [/] Soundnsess and completeness of propositional logic
- [/] Compactness
- [x] Computability
- [x] Decidability
- [ ] Undecidable sets
- [x] Semi-decidability
- [ ] Complexity
- [/] Normal forms
- [ ] Canonical normal forms
- [ ] Equisatisfiability, Tseitin transformation, Example
- [ ] DIMACS format
- [ ] SAT
- [ ] Cook theorem

== Summary

- Propositional logic provides a foundation for reasoning about Boolean functions.
- Key concepts: Syntax, semantics, WFFs, truth tables, and logical laws.
- Next steps: SAT solvers and their role in automated reasoning.
