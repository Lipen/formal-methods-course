#import "theme.typ": *
#show: slides.with(
  title: [Formal Methods in Software Engineering],
  subtitle: "First-Order Logic",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  dark: true,
)

= First-Order Logic

== Motivation
- First-order logic (FOL) extends propositional logic by introducing quantifiers and predicates, allowing reasoning about objects, their properties, and relationships.
- *Why FOL?*
  - Propositional logic is limited to truth-functional reasoning, but many real-world problems require reasoning about individuals and their relationships.
  - Applications: Verifying algorithms, formalizing mathematics, and modeling knowledge in AI.

== What is First-Order Logic?
- *Core Idea*:
  - FOL combines the syntax and semantics of propositional logic with additional expressiveness for quantification and predicates.
- *Comparison with Propositional Logic*:
  - Propositional logic deals with true/false values for fixed statements.
  - FOL enables reasoning about variable entities, their properties, and relationships.
  - Example:
    - Propositional: "A implies B" ($A imply B$).
    - FOL: "If a person is a student, they have an ID" $forall x ("Student"(x) imply "HasID"(x))$.

== Syntax of First-Order Logic

- *Alphabet*:
  + Logical symbols: $not, and, or, imply, iff$.
  + Quantifiers: $forall$ (universal) and $exists$ (existential).
  + Variables: $x, y, z, ...$.
  + Constants: $a, b, c, ...$ (specific entities).
  + Functions: $f(x), g(x, y), ...$ (map objects to objects).
  + Predicates: $P(x), Q(x, y), ...$ (statements about objects).

- *Terms*:
  - *Definition*: Constants, variables, or function applications.
  - Examples:
    - $x$ (variable), $a$ (constant), $f(x, y)$ (function).

- *Atomic Formulas*:
  - Formed by applying predicates to terms.
  - Examples: $P(x)$, $Q(f(x), y)$.

== Well-Formed Formulas (WFFs)
- Built inductively from atomic formulas using:
  + Logical connectives: $and, or, imply, iff$.
  + Quantifiers: $forall$ and $exists$.

- Examples:
  - $forall x . (P(x) imply Q(x))$.
  - $exists y . (R(y) and P(f(a, y)))$.

- Example of invalid (not well-formed) formula: $forall (P(x) and Q(x))$ (missing quantified variable).

== Semantics of First-Order Logic

- *Interpretations*:
  - Define the meaning of terms, predicates, and formulas.
  - An interpretation $I$ consists of:
    + A domain $D$ (set of objects).
    + An assignment of values to constants, functions, and predicates.

- *Variable Assignments*:
  - Map variables to elements in the domain $D$.
  - Extended to terms recursively using function interpretations.

- *Truth of a Formula*:
  - Defined inductively:
    - $P(t_1, ..., t_n)$ is true if $(t_1, ..., t_n)$ is in the interpretation of $P$.
    - $forall x . phi$ is true if $phi$ is true for all assignments of $x$.
    - $exists x . phi$ is true if $phi$ is true for some assignment of $x$.

#block(breakable: false)[
  - *Examples*:
    - Domain $D = \{1, 2, 3\}$.
    - $P(x)$: "x is even".
    - $forall x P(x)$: False (not all numbers are even).
    - $exists x P(x)$: True (2 is even).
]

== Logical Theories
- *Definition*:
  - A logical theory $T$ is a set of axioms (formulas assumed true).
  - Includes all formulas derivable from these axioms.
- *Examples of Theories*:
  + Peano Arithmetic: Axioms for natural numbers.
  + Group Theory: Axioms for algebraic groups.
  + Geometry: Axioms defining points, lines, and planes.
- *Consistency and Completeness*:
  - A theory is consistent if it does not derive contradictions.
  - A theory is complete if, for every formula $phi$, either $phi$ or $not phi$ is derivable.

== Logical Entailment
- *Definition*:
  - $Gamma models phi$ means $phi$ is true in every model of $Gamma$.
  - Generalizes propositional entailment.
- *Examples*:
  - $forall x . (P(x) imply Q(x)), P(a) models Q(a)$.
- *Relation to Proof*:
  - Logical entailment connects semantic truth to syntactic provability.

== Proof Systems for First-Order Logic
- *Natural Deduction*:
  - Rules for quantifier introduction/elimination and connectives.
  - Example:
    - From $forall x . P(x)$, infer $P(a)$ (universal elimination).
  - Constructing formal proofs step by step.
- *Sequent Calculus*:
  - Represents logical arguments as sequents: $Gamma imply Delta$.
  - Rules for manipulating sequents.
  - Example:
    - $Gamma imply P(a)$ inferred from $Gamma imply forall x . P(x)$.
- *Resolution*:
  - Refutation-based method for proving unsatisfiability.
  - Converts formulas into clausal form.
  - Unification: Finding substitutions to make terms identical.
  - Example: Proving $exists x . (P(x) and Q(x))$ entails $exists x . P(x)$.

== Soundness and Completeness
- *Soundness*:
  - If $Gamma tack phi$, then $Gamma models phi$.
  - Ensures derivations produce semantically valid results.
- *Completeness*:
  - If $Gamma models phi$, then $Gamma tack phi$.
  - Guarantees all semantically true formulas are provable.
- *Compactness Theorem*:
  - If every finite subset of $Gamma$ is satisfiable, then $Gamma$ is satisfiable.
  - Applications in model theory and automated reasoning.
  - Example: Infinite sets of constraints on natural numbers.

== Decidability and Complexity
- *Decidability of FOL*:
  - FOL is undecidable: No algorithm can determine the truth of every FOL formula.
  - Contrast with propositional logic (decidable via truth tables).
- *Semi-Decidability*:
  - If $Gamma models phi$, there exists a proof procedure to verify it.
  - If $Gamma models.not phi$, no guarantee of termination.
- *Complexity in Restricted Cases*:
  - Certain fragments of FOL (e.g., monadic logic) are decidable.
  - Example: Deciding satisfiability for formulas with a single quantifier.

== Theorem Proving in First-Order Logic
- *Automated Theorem Proving*:
  - Tools like Prover9, Vampire, and Coq implement FOL reasoning.
  - Applications: Program verification, AI planning.
  - Example: Prove "If all inputs to a circuit are high, the output is high."
- *Resolution in Practice*:
  - Convert formulas to clausal form.
  - Apply resolution rules iteratively to detect contradictions.
- *Interactive Proof Assistants*:
  - Examples: Coq, Lean.
  - Application: Verifying mathematical proofs and software correctness.

== Examples and Applications
- *Translating Natural Language*:
  - "All students passed": $forall x . ("Student"(x) imply "Passed"(x))$.
  - "Some courses are challenging": $exists y . ("Course"(y) and "Challenging"(y))$.
- *Verifying Theorems*:
  - Show $forall x . (P(x) imply Q(x)) and P(a)$ entails $Q(a)$.
- *Database Constraints*:
  - Example: "Every employee has a manager": $forall x . ("Employee"(x) imply exists y . ("Manager"(y) and "ReportsTo"(x, y)))$.

== Advanced Topics
- *Extensions of FOL*:
  - Higher-order logic: Quantification over predicates and functions.
  - Temporal logic: Reasoning about time-dependent properties.
  - Modal logic: Adding necessity and possibility operators.
- *Skolemization*:
  - Eliminating existential quantifiers using Skolem functions.
- *Herbrand Universes*:
  - Constructing finite representations of models from ground terms for automated reasoning.

== Summary
- First-order logic (FOL) provides a powerful framework for reasoning about objects, their properties, and relationships.
- Key topics:
  - Syntax and semantics.
  - Logical theories and proof systems.
  - Soundness, completeness, and compactness.
  - Applications in theorem proving, AI, and verification.
- FOL underpins modern formal methods, including higher-order logics and model checking.
