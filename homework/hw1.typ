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

== Problem 7: Programming Challenge --- Logic in Practice

#Block(color: teal, width: 100%)[
  *Implementation context:*

  This is a _programming project_ where you implement core logic concepts from scratch and explore their real-world applications.
  Choose your language: Python, Rust, OCaml, Haskell, or any language with algebraic data types.
  For formal verification tasks, use Lean 4 or Coq.

  *Submission:* Code repository (GitHub/GitLab) with README explaining your design choices, plus a brief report (2-3 pages) documenting what you implemented, challenges encountered, and insights gained.

  *Grading:* Core tasks (50%), code quality & documentation (30%), extensions (20%).
]

=== Part A: Formula Engine (Core Implementation)

Build a _propositional logic toolkit_ from the ground up.

*Task A.1: Abstract Syntax Tree*

Design and implement an AST representation for propositional formulas.

#Block(color: blue.lighten(50%), width: 100%)[
  *Required:*
  - Data type/class for formulas: atoms ($p, q, dots$), $not$, $and$, $or$, $imply$, $iff$, constants ($top$, $bot$)
  - Constructor functions or smart constructors
  - Structural equality and hashing (for sets/maps)

  *Example (Rust):*
  ```rust
  enum Formula {
      Atom(String),
      Not(Box<Formula>),
      And(Box<Formula>, Box<Formula>),
      // ... complete the rest
  }
  ```

  *Example (Python):*
  ```python
  @dataclass(frozen=True)
  class Atom:
      name: str

  @dataclass(frozen=True)
  class Not:
      operand: Formula
  # ... complete using Union or inheritance
  ```

  *Open question:* Should $imply$ and $iff$ be primitive or derived? Justify your choice.
]

*Task A.2: Pretty Printer and Parser*

#Block(color: blue.lighten(50%), width: 100%)[
  *Required:*
  - `to_string(formula)`: Convert AST to human-readable string with minimal parentheses.
    Use precedence: $not > and > or > imply > iff$
  - Handle associativity correctly

  *Optional:*
  - Parser: `parse(string)` → AST. Use a parser combinator library (e.g., `pyparsing`, `nom`, `parsec`) or write a recursive descent parser.
  - Round-trip test: `parse(to_string(f)) == f`

  *Test case:*
  ```
  ((p ∧ q) → r) ∨ (¬p ∧ s)  should print with minimal parens
  ```
]

#block(sticky: true)[*Task A.3: Evaluator and Truth Tables*]

#Block(color: blue.lighten(50%), width: 100%)[
  *Required:*
  - `eval(formula, interpretation)`: Evaluate formula under a given variable assignment.
  - `truth_table(formula)`: Generate complete truth table as a list/table of `(valuation, result)` pairs.
  - `is_tautology(formula)`, `is_satisfiable(formula)`, `is_contradiction(formula)`

  *Output format:*
  ```
  p | q | r | (p ∧ q) → r
  --|---|---|-------------
  T | T | T |      T
  T | T | F |      F
  ...
  ```

  *Open task:* Implement _early termination_: stop generating the truth table for `is_satisfiable` as soon as you find one satisfying assignment.
]

#block(sticky: true)[*Task A.4: Normal Forms*]

#Block(color: blue.lighten(50%), width: 100%)[
  *Required:*
  - `to_nnf(formula)`: Convert to Negation Normal Form (push negations to atoms).
  - `to_cnf(formula)`: Convert to Conjunctive Normal Form using distributivity or Tseitin transformation.

  *Open choice:* Should `to_cnf` always use Tseitin (polynomial blowup) or try direct conversion first (exponential worst case, but often smaller)? Implement both and compare.

  *Test:* Verify that your CNF conversion preserves satisfiability (or equivalence, if not using Tseitin).
]

#block(sticky: true)[*Task A.5: Equivalence and Properties*]

#Block(color: blue.lighten(50%), width: 100%)[
  *Required:*
  - `equivalent(f1, f2)`: Check logical equivalence using truth tables or SAT solving.
  - Implement and test De Morgan's laws:
    - $not (p and q) equiv (not p) or (not q)$
    - $not (p or q) equiv (not p) and (not q)$
  - Test distributivity: $p and (q or r) equiv (p and q) or (p and r)$

  *Extension:*
  - Implement a _random formula generator_ for property-based testing.
  - Use it to test commutativity, associativity, absorption laws.
]

=== Part B: Proof Systems (Advanced Implementation)

Implement proof checking and (optionally) proof search.

#block(sticky: true)[*Task B.1: Fitch Proof Representation*]

#Block(color: green.lighten(60%), width: 100%)[
  *Required:*
  - Data structure for Fitch proofs: list of steps, each with:
    - Line number
    - Formula
    - Justification (rule name + references to earlier lines)
    - Indentation level (for subproofs)

  *Example structure (pseudocode):*
  ```
  Step = {
    line: int,
    formula: Formula,
    rule: Rule,
    references: List[int],
    level: int,  // subproof depth
  }
  ```

  *Open design question:* How do you represent assumptions vs. derived steps? How do you track subproof scope?
]

#block(sticky: true)[*Task B.2: Proof Checker*]

#Block(color: green.lighten(60%), width: 100%)[
  *Required:*
  Implement a checker that validates Fitch proofs step-by-step.
  Support at minimum:
  - Premise (assumption at depth 0)
  - Assumption (start subproof, increase depth)
  - ∧i, ∧e, ∨i, ∨e, →i, →e, ¬i, ¬e, ⊥e
  - Reiteration (repeat earlier line from valid scope)

  *Checker requirements:*
  - Verify each step references valid earlier lines
  - Check subproof scoping (can only reference lines from current or outer scopes)
  - Verify rule applications are correct
  - Report specific errors with line numbers

  *Test case:* Validate the proof from Problem 1(a) in HW1.

  *Extension:*
  - Add RAA (reductio ad absurdum) and LEM (law of excluded middle)
  - Support FOL quantifier rules ($forall$i/e, $exists$i/e) with eigenvariable checking
]

#block(sticky: true)[*Task B.3: Automated Proof Search (Optional)*]

#Block(color: green.lighten(60%), width: 100%)[
  *Challenge:* Implement a simple automated prover.

  *Approach 1 (Semantic Tableaux):*
  - Implement a tableau prover: try to build a countermodel by systematic case analysis.
  - If all branches close, the formula is a tautology.

  *Approach 2 (Resolution):*
  - Convert to CNF, apply resolution until deriving $square$ or saturating.

  *Approach 3 (Sequent Calculus):*
  - Bottom-up proof search in sequent calculus.

  *Open exploration:* Which approach finds proofs fastest for the examples in Problem 1?
  Can you find formulas where one method outperforms the others dramatically?
]

=== Part C: Real-World Applications

Connect theory to practical software engineering.

#block(sticky: true)[*Task C.1: Configuration Validation*]

#Block(color: orange.lighten(70%), width: 100%)[
  *Scenario:* You're building a deployment system with configuration constraints (like Problem 5: production mode, debug mode, logging, security).

  *Implementation:*
  - Define a configuration schema as propositional formulas (constraints).
  - Implement `validate_config(constraints, config)`: check if a configuration satisfies all constraints.
  - Implement `find_valid_configs(constraints)`: enumerate _all_ valid configurations using your SAT solver or truth table generator.
  - Implement `explain_conflict(constraints, config)`: if a config is invalid, report which constraints are violated and suggest fixes.

  *Test:* Use the access control system from Problem 5.

  *Extension:*
  - Minimal correction: given an invalid config, find the _smallest_ set of variables to flip to make it valid.
]

#block(sticky: true)[*Task C.2: SMT Solver Integration*]

#Block(color: orange.lighten(70%), width: 100%)[
  *Tool:* Use Z3 (Python/C\+\+/Java bindings) or CVC5.

  *Task:*
  - Translate your propositional formulas to SMT-LIB or use the API.
  - Solve satisfiability: `z3_solve(formula)` → SAT/UNSAT + model.
  - Compare performance with your truth table implementation on large formulas (100+ variables).

  *Research direction:*
  - Generate random 3-SAT instances with varying clause/variable ratios.
  - Plot satisfiability probability vs. ratio. Observe the _phase transition_ around ratio ≈ 4.26.
  - Document your findings.
]

#block(sticky: true)[*Task C.3: Symbolic Execution (Bonus)*]

#Block(color: orange.lighten(70%), width: 100%)[
  *Challenge:* Implement a _toy symbolic executor_ for a simple imperative language.

  *Language (example):*
  ```
  x := E         // assignment
  if B then S1 else S2
  assert(B)      // fails if B is false
  while B do S   // bounded unrolling
  ```

  #block(sticky: true)[*Symbolic execution:*]
  - Execute with _symbolic_ inputs (variables, not concrete values).
  - Track path condition (formula representing choices made).
  - At `assert(B)`, check if `path_condition ∧ ¬B` is satisfiable:
    - If SAT → assertion can fail (counterexample).
    - If UNSAT → assertion always holds on this path.

  *Deliverable:*
  - Implement symbolic executor for assertion checking.
  - Test on 2-3 small programs (e.g., array bounds check, login validation).

  *Open question:* How do you handle loops? (Bounded unrolling? Loop invariants?)
]

#block(sticky: true)[*Task C.4: Type Checking as Logic (Bonus)*]

#Block(color: orange.lighten(70%), width: 100%)[
  *Insight:* Type systems are logical systems (Curry-Howard correspondence).

  *Task:*
  - Design a simple typed lambda calculus or a subset of a real language (e.g., Simply Typed Lambda Calculus with booleans and integers).
  - Encode typing judgments $Gamma tack e : tau$ as logical formulas or inference rules.
  - Implement a type checker using your proof representation from Part B.
  - Show that type checking $equiv$ proof search in a specific logic.

  *Extension:*
  - Implement in Lean or Coq: prove type safety (progress + preservation theorems).
  - Compare the formal proof to your implementation.
]

=== Part D: Formal Verification Track (Optional)

Use Lean 4 or Coq to _prove properties_ about your implementations.

#block(sticky: true)[*Task D.1: Verified Evaluator (Lean/Coq)*]

#Block(color: teal.lighten(60%), width: 100%)[
  *Task:*
  - Define propositional formulas in Lean/Coq as an inductive type.
  - Implement `eval : Formula → Valuation → Bool`.
  - *Prove:* `eval` is deterministic: `∀ f v, eval f v = eval f v` (trivial, warmup).
  - *Prove:* Double negation: `∀ f v, eval (¬¬f) v = eval f v`.
  - *Prove:* De Morgan: `∀ f g v, eval (¬(f ∧ g)) v = eval (¬f ∨ ¬g) v`.

  *Resources:*
  - Lean 4: #link("https://leanprover.github.io/theorem_proving_in_lean4/")[Theorem Proving in Lean]
  - Coq: Software Foundations (Vol. 1, _Logical Foundations_)
]

#block(sticky: true)[*Task D.2: Verified CNF Conversion (Lean/Coq)*]

#Block(color: teal.lighten(60%), width: 100%)[
  *Challenge:*
  - Implement NNF conversion in Lean/Coq.
  - *Prove correctness:* `∀ f, equivalent f (to_nnf f)` where `equivalent f g := ∀ v, eval f v = eval g v`.
  - Prove termination (structural recursion or well-founded relation).

  *Extension:*
  - Prove Tseitin transformation preserves _satisfiability_ (not equivalence).
]

#block(sticky: true)[*Task D.3: Soundness of Proof Checker (Lean/Coq)*]

#Block(color: teal.lighten(60%), width: 100%)[
  *Advanced challenge:*
  - Formalize Fitch-style natural deduction in Lean/Coq.
  - Implement proof checking.
  - *Prove soundness:* If `check_proof Γ φ proof = true`, then `Γ ⊢ φ` (semantic entailment).

  *This is research-level work* — partial results are valuable. Document your approach and any obstacles.
]

// = Notation Reference
//
// #grid(
//   columns: 2,
//   column-gutter: 2em,
//   row-gutter: 1em,
//   [
//     *Semantic relations:*
//     - $Gamma models phi$ --- semantic entailment
//     - $nu models phi$ --- interpretation $nu$ satisfies $phi$
//     - $models phi$ --- $phi$ is valid (tautology)
//   ],
//   [
//     *Syntactic relations:*
//     - $Gamma tack phi$ --- syntactic derivability
//     - Fitch rules: $and$i/e, $or$i/e, $imply$i/e, $not$i/e, $bot$e, RAA, LEM
//     - FOL rules: $forall$i/e, $exists$i/e
//   ],
// )
