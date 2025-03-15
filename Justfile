default:
    @just --list

all: \
    (compile "syllabus.typ") \
    (compile "lec-prop-logic.typ") \
    (compile "lec-normal-forms.typ") \
    (compile "lec-sat.typ") \
    (compile "lec-dpll.typ") \
    (compile "lec-computation.typ") \
    (compile "lec-fol.typ") \
    (compile "lec-smt.typ") \
    (compile "lec-alloy.typ") \
    (compile "lec-dafny.typ")

compile target:
    typst compile {{target}}
