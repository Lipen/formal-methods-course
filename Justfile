root := justfile_directory()
export TYPST_ROOT := root

[private]
default:
    @just --list --unsorted

# All Typst files to compile
files := """
    syllabus.typ
    lec-logic.typ
    lec-sat.typ
    lec-fol.typ
    lec-computation.typ
    lec-smt.typ
    lec-dafny.typ
    homework/hw1.typ
"""

# Compile a single file
compile target:
    typst compile {{target}}

# Compile all files
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

# Compile all files _in parallel_
parallel:
    parallel -k -- just compile {} ::: {{replace(files, "\n", ' ')}}
