#import "@preview/numbly:0.1.0": numbly

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

  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  // Setup
  if title != none {
    set document(title: title, author: authors)
  }
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.8 * space),
    // background: context {
    //   let top_margin = if type(page.margin) == dictionary {
    //     page.margin.at("top")
    //   } else {
    //     0pt
    //   }
    //   let bottom_margin = if type(page.margin) == dictionary {
    //     page.margin.at("bottom")
    //   } else {
    //     0pt
    //   }
    //   place(top)[
    //     #box(height: top_margin, fill: green.transparentize(50%))[
    //       top margin = #top_margin
    //     ]
    //   ]
    //   place(bottom)[
    //     #box(height: bottom_margin, fill: green.transparentize(50%))[
    //       bottom margin = #bottom_margin
    //     ]
    //   ]
    // },
    // background: place(top, box(height: space, fill: green.transparentize(50%))[BOTTOM MARGIN = #space]),
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
        block(inset: (bottom: 0.8em))[
          #context {
            body
            place(bottom, dy: 0.5em)[
              #line(length: measure(body).width, stroke: 0.8pt + title-color)
            ]
          }
        ]
      }
    },
    header-ascent: 0%,
    footer: [
      #set text(0.8em)
      #set align(right)
      #rect(radius: 100%, fill: title-color.transparentize(80%))[
        #context counter(page).display("1/1", both: true)
      ]
    ],
    footer-descent: 0.8em,
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

  // Headings
  set heading(
    numbering: numbly(
      sym.section + "{1} ",
      none,
      sym.square + "",
      default: (.., last) => str(last) + ".",
    ),
  )

  // Title
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
      #align(left, authors.join(", ", last: " and "))
    ]
  }

  // Styling
  set list(
    marker: (
      text(fill: title-color)[•],
      text(fill: title-color)[‣],
      text(fill: title-color)[-],
    ),
  )
  set enum(numbering: nums => text(fill: title-color)[*#nums.*])

  // Fix emptyset symbol
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Content
  content
}

#let frame(
  content,
  counter: none,
  title: none,
  fill-body: none,
  fill-header: none,
  radius: 0.2em,
) = {
  let header = none

  if fill-header == none and fill-body == none {
    fill-header = default-color.lighten(75%)
    fill-body = default-color.lighten(85%)
  } else if fill-header == none {
    fill-header = fill-body.darken(10%)
  } else if fill-body == none {
    fill-body = fill-header.lighten(50%)
  }

  if radius == none {
    radius = 0pt
  }

  if counter == none and title != none {
    header = [*#title.*]
  } else if counter != none and title == none {
    header = [*#counter.*]
  } else {
    header = [*#counter:* #title.]
  }

  show stack: set block(breakable: false, above: 0.8em, below: 0.5em)

  stack(
    block(
      width: 100%,
      inset: (x: 0.4em, top: 0.35em, bottom: 0.45em),
      fill: fill-header,
      radius: (top: radius, bottom: 0cm),
      header,
    ),
    block(
      width: 100%,
      inset: (x: 0.4em, top: 0.35em, bottom: 0.45em),
      fill: fill-body,
      radius: (top: 0cm, bottom: radius),
      content,
    ),
  )
}

#let d = counter("definition")
#let definition(content, title: none, ..options) = {
  d.step()
  frame(
    counter: context d.display(x => "Definition " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let t = counter("theorem")
#let theorem(content, title: none, ..options) = {
  t.step()
  frame(
    counter: context t.display(x => "Theorem " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let l = counter("lemma")
#let lemma(content, title: none, ..options) = {
  l.step()
  frame(
    counter: context l.display(x => "Lemma " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let c = counter("corollary")
#let corollary(content, title: none, ..options) = {
  c.step()
  frame(
    counter: context c.display(x => "Corollary " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let a = counter("algorithm")
#let algorithm(content, title: none, ..options) = {
  a.step()
  frame(
    counter: context a.display(x => "Algorithm " + str(x)),
    title: title,
    content,
    ..options,
  )
}

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
