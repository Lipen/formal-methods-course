#let dark = false
#set text(fill: white) if dark
#set page(fill: luma(12%)) if dark

#import "common.typ": *

#import "@preview/numbly:0.1.0": numbly
#import "@preview/cetz:0.3.2"

#set par(justify: true)
#set text(size: 14pt)
#set heading(numbering: numbly(sym.section + "{1} "))

///////////////////////////////////////

#block[
  #set par(justify: false)
  #set text(size: 1.5em)
  *Formal Methods in Software Engineering*
]

= Annotation

_Ever dreamed of writing perfect, bug-free code?_
In this course, you'll dive into the depths of formal methods: explore propositional and first-order logic, master SAT and SMT solvers, and discover the fundamentals of verification --- from transition systems and Kripke models to specification and temporal logics (LTL, CTL, ATL).
We'll examine SAT- and BDD-based verification approaches, look at bounded model checking (BMC) and property-directed reachability (IC3/PDR), and show how to systematically ensure reliability and correctness (safety and liveness properties) in complex systems.
All theoretical concepts are reinforced through hands-on examples using academic tools such as NuSMV, Alloy/Forge, and Dafny, so you can see exactly how research ideas become practical solutions.
This course is ideal for anyone seeking to understand the core principles of verification and apply them in real projects, aiming for the highest standards of software quality and reliability.

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

== Overview

- *Introduction to Formal Methods*: Motivation, applications, and core concepts.

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

== Homework Assignments (20%)

Assignments focusing on each logic or tool introduced.

== Literature Review & Presentation (20%)

Students analyze a real case study, synthesizing insights from papers or technical reports.

== Term Project (30%)

A substantial modeling/verification effort that integrates multiple techniques from the course. Includes a written report and final presentation.

== Final Exam (20%)

Tests both theoretical understanding (logic, model checking principles) and tool-based reasoning (e.g., how to encode properties in NuSMV).

== Participation (10%)

Evaluates discussion contributions, attendance, engagement in peer reviews, and collaboration in labs.

= Course Policies

- Standard university policies on academic integrity, attendance, and accommodations apply.
- Students are encouraged to regularly collaborate and discuss concepts, but all submitted work must be their own unless explicitly stated otherwise.
- Late submissions will be penalized unless prior arrangements are made with the instructor.

= Resources

Lecture notes, slides, and additional readings will be uploaded in the course GitHub repo: https://github.com/Lipen/formal-methods-course.

= Contacts

...
