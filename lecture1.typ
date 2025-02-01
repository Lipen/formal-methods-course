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
  - ${not, and}$ --- see AIG (And-Inverter Graph) and #link("http://github.com/arminbiere/aiger")[AIGER format].
  - ${not, or}$
  - ${overline(and)}$ --- NAND
  - ${overline(or)}$ --- NOR

== TODO

- Natural deduction
- Soundnsess and completeness of propositional logic
- Decidability of propositional logic
- Complexity
- Normal forms
- Compactness
- Equisatisfiability, Tseitin transformation, Example
- DIMACS format
- SAT
- Cook theorem

== Summary

- Propositional logic provides a foundation for reasoning about Boolean functions.
- Key concepts: Syntax, semantics, WFFs, truth tables, and logical laws.
- Next steps: SAT solvers and their role in automated reasoning.
