#import "requirements.typ": *

#let template(dark: false, doc) = {
  // Dark mode
  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  // Fix emptyset symbol
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Setup theorems
  show: thmrules.with(qed-symbol: $square$)

  doc
}

// Horizontal rule
#let hrule = line(length: 100%)

// Blob for fletcher diagrams
#let blob(
  pos,
  label,
  tint: white,
  ..args,
) = fletcher.node(
  pos,
  align(center, label),
  fill: tint.lighten(80%),
  stroke: 1pt + tint.darken(20%),
  corner-radius: 5pt,
  ..args,
)

// Colored box around a content
#let fancy-box(tint: green, content) = {
  fletcher.diagram(
    blob(
      (0, 0),
      content,
      shape: fletcher.shapes.rect,
      tint: tint,
    ),
  )
}

// Aliases
#let neg = sym.not
#let imply = sym.arrow.r
#let implies = imply
#let iff = sym.arrow.l.r
#let to = sym.arrow.long.r
#let maps = sym.arrow.bar
#let neq = sym.eq.not
#let leq = sym.lt.eq
#let geq = sym.gt.eq
#let models = sym.tack.double
#let entails = sym.tack.r
#let notin = sym.in.not
