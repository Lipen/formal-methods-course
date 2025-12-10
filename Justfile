default:
    @just --list

files := """
    syllabus.typ
    lec-prop-logic.typ
    lec-normal-forms.typ
    lec-sat.typ
    lec-dpll.typ
    lec-computation.typ
    lec-fol.typ
    lec-smt.typ
    lec-dafny.typ
"""

all:
    #!/usr/bin/env sh
    set -e
    for file in {{replace(files, "\n", ' ')}}; do
        if [ -f $file ]; then
            just compile $file
        else
            echo "File '$file' does not exist!"
        fi
    done

compile target:
    typst compile {{target}}

parallel:
    parallel -k -- just compile {} ::: {{replace(files, "\n", ' ')}}
