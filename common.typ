#import "@preview/fletcher:0.5.4" as fletcher: node

// Horizontal rule
#let hrule = line(length: 100%)

// blob for fletcher diagrams
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
#let neg = sym.not
#let imply = sym.arrow.r
#let implies = imply
#let iff = sym.arrow.l.r
#let to = sym.arrow.long.r
#let maps = sym.arrow.bar
#let leq = sym.lt.eq
#let geq = sym.gt.eq
#let models = sym.tack.double
#let entails = sym.tack.r
#let notin = sym.in.not
