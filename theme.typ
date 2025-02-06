#import "common.typ": *

#let default-color = blue.darken(40%)

#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

#let title-slide(content) = {
  set page(header: none, footer: none)
  set align(horizon)
  content
  pagebreak(weak: true)
}

#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4 / 3,
  title-color: none,
  dark: false,
) = {
  // Parsing
  if layout not in layouts {
    panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height

  // Colors
  if title-color == none {
    title-color = default-color
  }

  // Dark mode
  if dark {
    title-color = title-color.lighten(30%)
  }

  // Common template
  show: template.with(dark: dark)

  // Setup
  if title != none {
    set document(title: title, author: authors)
  }
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.75 * space),
    header: context {
      let page = here().page()
      let headings = query(selector(heading.where(level: 2)))
      let heading = headings.rev().find(x => x.location().page() <= page)
      if heading != none {
        set align(bottom)
        set text(1.4em, weight: "bold", fill: title-color)
        let body = {
          heading.body
          if not heading.location().page() == page {
            numbering(" [1]", page - heading.location().page() + 1)
          }
        }
        underline(offset: 0.3em, body)
      }
    },
    header-ascent: 1.2em,
    footer: context {
      set text(0.8em)
      set align(right)
      rect(radius: 100%, fill: title-color.transparentize(85%))[
        #counter(page).display("1/1", both: true)
      ]
    },
    footer-descent: 0.5em,
  )
  set outline(target: heading.where(level: 1), title: none)
  set bibliography(title: none)

  // Rules
  show heading.where(level: 1): x => {
    set page(header: none, footer: none, margin: 0pt)
    set align(horizon)
    set text(1.2em, weight: "bold", fill: title-color)
    grid(
      columns: (1fr, 3fr),
      inset: 1em,
      align: (right, left),
      fill: (title-color, none),
      [#block(height: 100%)], [#text(size: 1.2em, weight: "bold", fill: title-color)[#x]],
    )
  }
  show heading.where(level: 2): pagebreak(weak: true)
  show heading: set text(1.1em, fill: title-color)

  // Style headings
  set heading(
    numbering: numbly.numbly(
      sym.section + "{1} ",
      none,
      sym.square + "",
      default: (.., last) => str(last) + ".",
    ),
  )

  // Style lists
  set list(
    marker: (
      text(fill: title-color)[•],
      text(fill: title-color)[‣],
      text(fill: title-color)[-],
    ),
  )
  set enum(numbering: nums => text(fill: title-color)[*#nums.*])

  // Make links underlined
  show link: underline

  // Setup theorems
  show: thmrules.with(qed-symbol: $square$)

  // Title page
  if title != none {
    if (type(authors) != array) {
      authors = (authors,)
    }
    title-slide[
      #text(2em, weight: "bold", fill: title-color, title)
      #v(1.4em, weak: true)
      #if subtitle != none {
        text(1.1em, weight: "bold", subtitle)
      }
      #if subtitle != none and date != none {
        text(1.1em)[ --- ]
      }
      #if date != none {
        text(1.1em, date)
      }
      #v(1em, weak: true)
      #authors.join(", ", last: " and ")
    ]
  }

  // Content
  content
}

#let definition = thmbox(
  "definition",
  "Definition",
  fill: rgb("#e8f8e8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("e8e8f8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",
  fill: rgb("f8e8e8"),
  inset: 0.8em,
  padding: (),
)
#let proof = thmproof(
  "proof",
  "Proof",
  inset: (x: 0em, y: 0em),
)
#let example = thmplain(
  "example",
  "Example",
  inset: (x: 0em, y: 0em),
).with(numbering: none)
