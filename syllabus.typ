#let dark = false
#set text(fill: white) if dark
#set page(fill: luma(12%)) if dark

#import "@preview/numbly:0.1.0": numbly

#set par(justify: true)
#set text(size: 14pt)
#set heading(numbering: numbly(
  sym.square + "",
  sym.section + "{2}.",
  default: none,
))

#let hrule = line(length: 100%)

#show "TLA+": [TLA#super("+")]

= Formal Methods in Software Engineering

== Annotation

This course explores the foundational principles and practical applications of Formal Methods in Software Engineering.
Students will learn how to specify, model, and verify software systems using techniques such as model checking (with Kripke structures, TLA+, and temporal logics) and symbolic execution (with SMT solvers).
A light introduction to theorem proving with Coq will contrast automated approaches with interactive proof development.
Emphasis will be placed on real-world applications and industry case studies, culminating in group projects and literature reviews.

== Learning Outcomes

By the end of the semester, students should be able to:

- Formally specify concurrent or complex software systems using TLA+.
- Construct and interpret Kripke structures and temporal logic (LTL) formulas to model system properties.
- Apply model checking techniques in NuSMV, including SAT-based bounded model checking.
- Understand and experiment with symbolic execution as a complementary technique for verifying software.
- Use Coq at a basic level to prove simple properties and distinguish between automated vs. interactive verification.
- Critically review academic/industrial literature on the use of formal methods and propose simplified project implementations.

== Prerequisites

Students are expected to be proficient in discrete mathematics (propositional logic, natural deduction, set theory) and to have basic knowledge of automata theory, formal languages, and at least one programming language.
Prior completion of a course in software engineering or systems design is helpful but not strictly required.

== Course Format

- Lectures
- Seminars
- Assignments
- Project
- Exam

== Course Structure

Topics are introduced in a modular fashion, roughly in the order below.
Depending on class progress, some modules may be shifted or compressed.

+ *Overview and Industrial Context:* \
  This module establishes the importance of formal methods by showcasing real-world failures and successes in software and systems engineering.
  - Students will examine case studies from leading organizations (Intel, NASA, Amazon) to illustrate how formal techniques address software complexity and correctness.
  - By reflecting on past accidents and current best practices, students will appreciate why rigorous approaches to specification and verification are indispensable for critical systems.
  - Discussion sessions will prompt students to connect these lessons to their own fields of interest.

+ *SAT and SMT for Verification:* \
  An overview of how SAT/SMT solvers (MiniSAT, Z3) provide the foundation for verifying models and finding counterexamples.
  Simple exercises such as encoding small constraints or puzzles will be used to demonstrate solver capabilities.

+ *Model Checking Foundations:* \
  A focused look at Kripke structures, labeling, and temporal logic (LTL).
  Students will formulate system properties (safety, liveness) and explore how to verify them.

+ *NuSMV Model Checker:* \
  Hands-on use of NuSMV for modeling concurrent or reactive systems.
  Students will learn to specify LTL properties, run model checking, interpret counterexamples, and address challenges like state-space explosion.

+ *TLA+ for System Specification:* \
  Specification syntax, actions, and states in TLA+.
  The TLA+ Toolbox will be used for writing, simulating, and model checking high-level system requirements.
  Concepts such as refinement and invariants will be introduced with small concurrent algorithm examples.

+ *Bounded Model Checking and Symbolic Execution:* \
  Coverage of SAT-based bounded model checking, unrolling transitions to a fixed depth, encoding them into SAT/SMT.
  Students will also learn symbolic execution fundamentals, exploring how tools like KLEE systematically test paths in a program.

+ *Introduction to Coq:* \
  A short tour of interactive theorem proving.
  Key features of Coq (proof terms, tactics, induction) will be demonstrated through small functional programs or data structure proofs.
  The goal is to show the contrast between automated and manual proof approaches.

+ *Research, Case Studies, and Student Presentations:* \
  A deeper examination of industrial applications (e.g., Microsoft's driver verification, NASA mission-critical software, Amazon's usage of TLA+).
  Students will present reviews of selected research papers or book chapters, focusing on the problem domain, formal verification techniques, and insights gained.

== Projects and Assignments

Throughout the course, students will complete lab exercises and a major project. Exercises will reinforce tool proficiency (e.g., NuSMV specs, TLA+ modeling, small symbolic execution tasks).
The major project can be chosen from instructor-proposed topics or student proposals with instructor approval.
Possible project directions include bounded model checking of a simplified protocol, symbolic execution of a small software component, or a TLA+ specification of a concurrency scheme.

Students will also conduct literature reviews on relevant research or industry papers, culminating in group presentations.
These reviews should dissect how formal methods were applied, what problems were solved, and how this could translate to real business contexts.

== Grading and Evaluation

- *Homework and Lab Exercises* (20%): Short assignments focusing on each new tool or technique introduced.
- *Literature Review & Presentation* (20%): Students individually or in small groups evaluate an academic or industrial formal methods case study.
- *Term Project* (30%): A substantial verification or specification effort that integrates multiple course topics. Final deliverables include a written report and an in-class demo or presentation.
- *Final Exam* (20%): A written or oral exam covering theoretical concepts, tool usage, and practical applications.
- *Participation* (10%): Assessed through discussion contributions, attendance, and engagement in peer reviews.

=== Homework

=== Literature Review & Presentation

=== Term Project

=== Final Exam

=== Participation

TODO: coins/tokens

== Course Policies

Standard university policies on academic integrity, attendance, and accommodations apply.
Students are encouraged to regularly collaborate and discuss concepts, but all submitted work must be their own unless explicitly stated otherwise.
Late submissions will be penalized unless prior arrangements are made with the instructor.

== Resources

- Clarke, Grumberg, and Peled, Model Checking.
- Lamport, Specifying Systems (TLA+).
- Huth and Ryan, Logic in Computer Science.
- SAT/SMT solver documentation (e.g., Z3, MiniSAT).
- Online tutorials for symbolic execution tools (KLEE, Java PathFinder).
- Coq documentation and “Coq in a Hurry” by Yves Bertot.- https://softwarefoundations.cis.upenn.edu/

Instructor handouts, slides, and additional readings will be posted on the course website.
Software such as NuSMV, TLA+ Toolbox, and Coq will be provided or linked for students to download.

== Additional Information

...

== Contacts

...
