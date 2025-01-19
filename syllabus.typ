#let dark = false
#set text(fill: white) if dark
#set page(fill: luma(12%)) if dark

#import "@preview/numbly:0.1.0": numbly
#import "@preview/cetz:0.3.1"
#import "@preview/fletcher:0.5.2" as fletcher: node, edge

#set par(justify: true)
#set text(size: 14pt)
#set heading(numbering: numbly(sym.section + "{1} "))

// Horizontal rule
#let hrule = line(length: 100%)

// Blob for fletcher diagrams
#let blob(
  pos,
  label,
  tint: white,
  ..args,
) = node(
  pos,
  align(center, label),
  fill: tint.lighten(80%),
  stroke: 1pt + tint.darken(20%),
  corner-radius: 5pt,
  ..args,
)

// Aliases
#let imply = sym.arrow.r
#let iff = sym.arrow.l.r
#let maps = sym.arrow.bar

#show "TLA+": [TLA#super("+")]

///////////////////////////////////////

#block[
  #set par(justify: false)
  #set text(size: 1.5em)
  *Formal Methods in Software Engineering*
]

= Annotation

Are you curious about the logical foundations that guarantee software correctness from the ground up?
In this course, you will deepen your understanding of propositional and first-order logic, see how SAT and SMT solvers automate reasoning, and explore a range of model-checking techniques --- from transition systems and Kripke structures to temporal logics (LTL, CTL, ATL).
We also examine BDD-based verification, bounded model checking (BMC), and property-directed reachability (IC3/PDR) to show how safety, liveness, and fairness properties can be systematically verified.
The course centers on the core theories and methods that shape modern formal verification research, and uses academic tools like NuSMV, Alloy/Forge, and Dafny.
This blend of theory and hands-on exploration is ideal for CS students seeking a thorough look at how logic-based techniques ensure reliability in complex software systems.


= (more motivating) Annotation

Curious about how mathematics can make software error-free?
This course offers a thorough exploration of logic-based techniques for modeling and verifying complex systems.
You’ll gain strong foundations in propositional and first-order logic, learn how SAT and SMT solvers automate reasoning, and practice a variety of model-checking methods --- from Kripke structures and transition systems to specifications and temporal logics (LTL, CTL, ATL).
We also look at BDD-based verification, bounded model checking (BMC), and property-directed reachability (IC3/PDR), revealing how safety, liveness, and fairness properties can be systematically proven.
By working with academic tools such as NuSMV, Alloy/Forge, and Dafny, you’ll discover how cutting-edge research aligns with practical analysis techniques, readying you for deeper explorations in formal verification.


= (more formal) Annotation

This course examines the logical foundations of software correctness through a rigorous study of formal verification methods.
Students will refine their understanding of propositional and first-order logic, explore SAT and SMT solver internals, and learn a range of model-checking techniques, including Kripke structures, temporal logics (LTL, CTL, ATL), and BDD-based algorithms.
Further topics include bounded model checking (BMC) and property-directed reachability (IC3/PDR), each illustrating key theoretical insights that underpin the verification of safety, liveness, and fairness properties.
Although the course showcases academic tools such as NuSMV, Alloy/Forge, and Dafny, its primary focus lies in the deep theoretical concepts that unify current research in formal methods, making it ideal for students seeking an advanced, concept-driven understanding of software reliability.



= Learning Outcomes

By the end of the semester, students should be able to:
- Demonstrate fluency in propositional and first-order logic for use in formal specification.
- Encode verification problems in SAT/SMT formulations and effectively utilize modern solvers (e.g., Cadical, Z3).
- Model reactive systems using transition systems and Kripke structures, and specify correctness properties in temporal logics (LTL, CTL, ATL).
- Employ a range of model checking techniques --- including SAT-based, BDD-based, bounded model checking, and IC3/PDR --- to verify safety and liveness properties.
- Use software tools (NuSMV, Alloy/Forge, Dafny) to perform model checking and automated reasoning on simplified but realistic software systems.
- Critically assess industrial and academic literature on formal verification, synthesizing insights into a final project or case study presentation.

= Prerequisites

Students are expected to have prior exposure to:
- Discrete mathematics (propositional logic, set theory)
- Basic proof techniques (natural deduction)
- Automata theory and formal languages
- At least one programming language

Experience with software engineering or systems design is helpful but not required.

= Course Format

- *Lectures*: Present theoretical foundations and methods.
- *Seminars*: Discuss research papers, advanced topics, and industrial cases.
- *Assignments*: Reinforce core concepts via problem sets and tool-based labs.
- *Project*: Undertake a substantial verification or modeling task.
- *Exam*: Assess understanding of theoretical and applied aspects of formal methods.

= Course Structure

== Overview and Industrial Context

- *Key Themes:* Historical failures (Therac-25, Ariane 5), business impacts (Intel, NASA), and how formal methods reduce errors.
- *Activities:* Case study discussions, short reflections on the cost of software bugs.

== Propositional Logic

- *Content:* Syntax, semantics, normal forms (CNF), tautologies, satisfiability.
- *Applications:* Encoding simple constraints, forming the basis for SAT solving.
- *In-class/Lab:* Translating small puzzles or system properties into propositional logic.

== SAT

- *Content:* SAT-solving fundamentals, DPLL backtracking, conflict-driven clause learning (CDCL).
- *Tools and Demos:* MiniSAT, short solver experiments.
- *Assignments:* Students encode a small problem (e.g., Sudoku or scheduling) and run a solver to find solutions or detect unsatisfiability.

== First-Order Logic

- *Content:* Syntax, semantics, quantifiers, free vs. bound variables, theories in FOL.
- *Deduction in FOL:* Natural deduction, sequent calculus (at a high level).
- *Relevance:* Understanding how real software specifications require more expressive logic than propositional alone.

== SMT

- *Content:* Extending SAT to Satisfiability Modulo Theories (linear arithmetic, arrays, bitvectors).
- *Standard Formats:* SMT-LIB language for specifying problems.
- *Tools and Frameworks:* Z3 usage.
- *Nelson-Oppen Framework:* Combining theories for more complex verifications.

== Model Checking

- *Transition Systems and Kripke Structures:* Modeling program states, transitions, labeling atomic propositions.
- *Temporal Logics:* Safety, liveness, fairness; LTL, CTL, ATL for specifying system properties.
- *NuSMV Tutorial:* Creating models, writing properties, interpreting counterexamples.
- *Alloy / Forge:* Relational modeling, generating instances or counterexamples.
- *Dafny:* A language+tool that integrates specification, verification, and proof-like checks.

== Advanced Model Checking Techniques

- *SAT-based Model Checking:* Bounded model checking (BMC) with unrolling.
- *BDD-based Model Checking:* Using binary decision diagrams for state-space representation.
- *k-Induction and Inductive Invariants:* Proving properties beyond a fixed bound.
- *IC3 / PDR:* Incremental construction of inductive proofs, property-directed reachability.
- *Comparisons and Trade-Offs:* When each technique excels or struggles.

= Projects and Assignments

Students will complete:
1. *Lab Exercises:* Applying each method or tool in small-scale examples --- e.g., encoding a puzzle in SAT, verifying a simple concurrency protocol in NuSMV, exploring an Alloy model.
2. *Major Course Project:* A deeper verification or specification task selected from instructor-provided ideas (e.g., verifying a distributed cache algorithm in NuSMV or Alloy, experimenting with Dafny for array safety proofs).
3. *Literature Reviews and Presentations:* Groups research an industrial or academic use of formal methods (e.g., hardware verification at Intel, flight software checks at NASA). They present both the methodology and lessons learned.

= Grading and Evaluation

#[
  #import fletcher.shapes: *
  #set align(center)
  #fletcher.diagram(
    // debug: true,
    spacing: 2pt,
    edge-stroke: 1pt,
    edge-corner-radius: 5pt,
    mark-scale: 150%,

    blob((0, 0), [Homework (20%)], shape: rect, tint: green),
    blob((1, 0), [Review (20%)], shape: rect, tint: green),
    blob((2, 0), [Project (30%)], shape: rect, tint: green),
    blob((3, 0), [Exam (20%)], shape: rect, tint: blue),
    blob((4, 0), [Participation (10%)], shape: rect, tint: purple),
  )
]

== Homework and Lab Exercises (20%)

Frequent assignments focusing on each logic or tool introduced.

== Literature Review & Presentation (20%)

Students analyze a real case study, synthesizing insights from papers or technical reports.

== Term Project (30%)

A substantial modeling/verification effort that integrates multiple techniques from the course. Includes a written report and final presentation.

== Final Exam (20%)

Tests both theoretical understanding (logic, model checking principles) and tool-based reasoning (e.g., how to encode properties in NuSMV).

== Participation (10%)

Evaluates discussion contributions, attendance, engagement in peer reviews, and collaboration in labs.

TODO: coins/tokens

= Course Policies

Standard university policies on academic integrity, attendance, and accommodations apply.
Students are encouraged to regularly collaborate and discuss concepts, but all submitted work must be their own unless explicitly stated otherwise.
Late submissions will be penalized unless prior arrangements are made with the instructor.

= Resources

- Clarke, Grumberg, and Peled, Model Checking.
- Lamport, Specifying Systems (TLA+).
- Huth and Ryan, Logic in Computer Science.
- SAT/SMT solver documentation (e.g., Z3, MiniSAT).
- Online tutorials for symbolic execution tools (KLEE, Java PathFinder).
- Coq documentation and “Coq in a Hurry” by Yves Bertot.
- https://softwarefoundations.cis.upenn.edu/

Instructor handouts, slides, and additional readings will be posted on the course website.
Software will be provided or linked for students to download.

= Additional Information

...

= Contacts

...
