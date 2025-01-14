// Functions for OI-Wiki remark-typst

/* BEGIN packages */
#import "pymdownx-details.typ": *
#import "@preview/tablex:0.0.5": *
// #import "@preview/codelst:1.0.0": code-frame, sourcecode
/* END plugins */

/* BEGIN packages */
#let typst-qrcode-wasm = plugin("./typst_qrcode_wasm.wasm")
/* END plugins */

/* BEGIN constants */
#let ROOT_EM = 10pt
#let VISIBLE_WIDTH = 21cm - 1in
#let VISIBLE_HEIGHT = 29.7cm - 1.5in
#let BLOCKQUOTE_CONTENT_WIDTH = VISIBLE_WIDTH - ROOT_EM * 2
#let MAX_IMAGE_WIDTH = VISIBLE_WIDTH - ROOT_EM * 8
#let MAX_IMAGE_HEIGHT = VISIBLE_HEIGHT / 2 - ROOT_EM * 8
// #let ENDPOINT = MAX_IMAGE_HEIGHT - MAX_IMAGE_WIDTH / 2
// #let MAX_RATIO = MAX_IMAGE_WIDTH / ENDPOINT
/* END constants */

#let antiflash-white = (bright: cmyk(0%, 0%, 0%, 5%), dark: cmyk(0%, 0%, 0%, 20%))

// There ARE thematic (section) breaks in paperprints!
// Although they are usually represented by three asterisks a.k.a. a dinkus.
#let horizontalrule = block(
  h(1fr) + sym.ast.op + h(1em) + sym.ast.op + h(1em) + sym.ast.op + h(1fr)
)

#let blockquote(content) = {
  let cmyk-gray = cmyk(0%, 0%, 0%, 70%)

  let cont_block = block.with(
    inset: (left: 1.75em, y: .25em),
  )

  [
    #v(.375em)
    #grid(
      columns: (.25em, auto),
      // HACK: parameterized (not hard-coded) size measurement is in progess
      // issue: https://github.com/typst/typst/issues/113
      layout(size => style(styles => {
        let h_cont = measure(
          cont_block(width: BLOCKQUOTE_CONTENT_WIDTH)[#content],
          styles
        ).height
        block(
          width: 100%,
          height: h_cont,
          fill: cmyk-gray,
          radius: .25em,
        )[]
      })),
      cont_block[
        #set text(fill: cmyk-gray)
        #content
      ]
    )
    #v(.375em)
  ]
}

#let kbd(string) = {
  let key = box(
    outset: .25em,
    fill: antiflash-white.bright,
    stroke: (
      bottom: (paint: cmyk(0%, 0%, 0%, 50%), thickness: 2pt, cap: "round", join: "round"), 
      x: (paint: cmyk(0%, 0%, 0%, 50%), thickness: 1pt, cap: "round", join: "round"), 
    ),
    radius: .25em,

    raw(string)
  )

  [#h(.5em)#key#h(.5em)]
}

#let authors(authors) = blockquote[#strong[Authors: ]#authors]

#let codeblock(
  lang: str,
  unwrapped: false, 
  code
) = {
  let radius = if unwrapped {
    (bottom: .1em)
  } else {
    .1em
  }
  let stroke = if unwrapped {
    (
      top: (thickness: 1pt, paint: antiflash-white.dark, dash: "dashed"),
      bottom: 1pt + antiflash-white.dark,
      x: 1pt + antiflash-white.dark
    )
  } else {
    1pt + antiflash-white.dark
  }

  // BEGIN plain code block
  // block(
  //   width: 100%,
  //   radius: radius,
  //   inset: (x: 1em, y: .5em),
  //   fill: antiflash-white.bright,
  //   stroke: stroke,
  //   raw(block: true, lang: lang, code)
  // )
  // END plain code block

  // Code block with line numbers
  // Issue: https://github.com/typst/typst/issues/344
  // Reference: https://gist.github.com/mpizenberg/c6ed7bc3992ee5dfed55edce508080bb
  grid(
    columns: 2,
    column-gutter: -100%,
    
    block(
      width: 100%,
      radius: radius,
      inset: (x: 4em, y: .5em),
      fill: antiflash-white.bright,
      stroke: stroke,
      
      {
        set text(font: ("DejaVu Sans Mono", "LXGW Wenkai"), size: 0.8 * 1.125em, fill: antiflash-white.dark)
        
        for (i, line) in code.replace("\t", "  ").split("\n").enumerate() {
          box(width: 0pt, inset: (right: 2em), align(right, str(i + 1)))
          hide(line)
          linebreak()
        }
      }
    ),
    block(
      width: 100%,
      inset: (x: 4em, y: .5em),

      raw(block: true, lang: lang, code)
    )
  )
}

// BEGIN codeblock using codelst
// #let codeblock(lang: str, unwrapped: false, code) = {
//   let frame = code-frame.with(
//     fill: antiflash-white,
//     stroke: if not unwrapped {
//       (bottom: 1pt + color.dark, left: 1pt + color.dark, right: 1pt + color.dark, )
//     } else {
//       none
//     },
//     inset: (x: 1em, y: .5em),
//     radius: if not unwrapped {
//       .1em
//     } else {
//       (bottom: .1em)
//     }
//   )
// 
//   sourcecode(
//     frame: frame,
//     raw(lang: lang, code)
//   )
// }
// END codeblock using codelst

// Auto-sized figure.
// NOTE: optimized image size is in progress
// issue: https://github.com/typst/typst/issues/436
#let figauto(
  src: str, 
  alt: str, 
  tight: false,
) = style(styles => {
  let img = image(src)
  let (width, height) = measure(img, styles)

  if width / height > MAX_IMAGE_WIDTH / MAX_IMAGE_HEIGHT {
    set image(width: calc.min(width, MAX_IMAGE_WIDTH))
    // if tight {
      v(.8em) + align(center, img) + v(.8em)
    // } else {
    //  v(1fr) + v(.8em) + align(center, img) + v(.8em) + v(1fr)
    // }
  } else {
    set image(height: calc.min(height, MAX_IMAGE_HEIGHT))
    // if tight {
      v(.8em) + align(center, img) + v(.8em)
    // } else {
    //  v(1fr) + v(.8em) + align(center, img) + v(.8em) + v(1fr)
    // }
  }

  // BEGIN trigonometric solution
  // let hori = VISIBLE_WIDTH.pt()
  // let radius = hori / 2
  // let ratio = width / height
  // let vert = hori / ratio
  // let diag = calc.sqrt(radius * radius + vert * vert)
  // let factor = diag / radius
  // set image(width: calc.min(width, VISIBLE_WIDTH / factor))
  // figure(img, caption: alt)
  // END trigonometric solution

  // BEGIN another trigonometric solution
  // if width / height > MAX_RATIO {
  //   set image(width: calc.min(width / 2, MAX_IMAGE_WIDTH))
  //   figure(img, caption: alt)
  // } else {
  //   let r   = MAX_RATIO / 2
  //   let v   = MAX_RATIO / (width / height)
  //   let b1  = calc.sqrt((v - 1) * (v - 1) + r * r)
  //   let c1  = calc.sqrt(v * v + r * r)
  //   let a   = 1
  //   let b   = r
  //   let B   = calc.acos((a * a + c1 * c1 - b1 * b1) / (2 * a * c1))
  //   let A   = calc.asin(a * calc.sin(B) / b)
  //   let C   = 180deg - A - B
  //   let c   = (a * calc.sin(C) / calc.sin(A))
  //   let f   = c1 / c
  //   set image(width: calc.min(width / 2, MAX_IMAGE_WIDTH / f))
  //   figure(img, caption: alt)
  // }
  // END another trigonometric solution
})

#let dispmath(svg: str) = style(styles => {
  let img = image.decode(svg)
  let (width, height) = measure(img, styles)
  set image(width: width * (12 / 16), height: height * (12 / 16))

  align(center)[#img]
})
#let inlinemath(svg: str) = box(
  style(styles => {
    let img = image.decode(svg)
    let (width, height) = measure(img, styles)
    set image(width: width * (12 / 16), height: height * (12 / 16))

    img
  })
)

#let qrcode(arg) = image.decode(
  str(typst-qrcode-wasm.generate(bytes(arg))),
  width: .5in,
)

#let links-grid(..content) = {
  set text(9pt)
  set par(leading: .5em)

  grid(
    columns: (1fr, .75in, 1fr, .5in),
    rows: .5in,

    ..content
  )
}
#let links-cell(content) = block(
  width: 100%, 
  height: 100%,

  align(horizon, content)
)

#let tablex-custom(
  columns: (),
  aligns: (),

  ..cells
) = {
  set text(9pt)

  align(
    center,
    block(
      radius: .1em,
      inset: (x: .5em),
      stroke: 1pt + antiflash-white.dark,
      tablex(
        columns: columns,
        column-gutter: 1fr,
        // NOTE: repeat-header has no effect when the table is in a container
        // it is also a little buggy right now, so we are not enabling it at this moment
        // issue: https://github.com/PgBiel/typst-tablex/issues/43
        // repeat-header: true,
        align: (col, row) => aligns.at(col),
        stroke: 1pt + antiflash-white.dark,
        auto-vlines: false,

        ..cells
      )
    )
  )
}
