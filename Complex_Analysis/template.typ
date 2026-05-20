// 1. 페이지 및 텍스트 기본 설정
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
  header: align(right, text(fill: gray.darken(20%), size: 9pt)[see-math Study Log]),
)

#set text(
  font: ("New Computer Modern", "Noto Sans CJK KR"),
  size: 11pt,
  spacing: 120%,
  lang: "ko",
)

// 2. 제목 및 목차 스타일
#set heading(numbering: "1.1.")
// #show heading: it => block(bottom-edge: "descender", v(1em) + it + v(0.5em))

// 3. 수학 연구용 커스텀 매크로 (Shortcuts)
#let R = $bb(R)$
#let C = $bb(C)$
#let Z = $bb(Z)$
#let dx = $dif x$
#let dy = $dif y$
#let implies = $arrow.r.long$

// 4. 시각적 구조화를 위한 디자인 블록 (Definition, Theorem, Proof)
#let definition(title, body) = block(
  fill: rgb("#eff6ff"), // 연한 파란색 배경
  stroke: (left: 4pt + rgb("#3b82f6")), // 파란색 왼쪽 테두리
  inset: 1.2em,
  radius: (right: 4pt),
  width: 100%,
  [
    #text(weight: "bold", fill: rgb("#1d4ed8"))[Def. #title] \
    #v(0.5em)
    #body
  ],
)

#let theorem(title, body) = block(
  fill: rgb("#f0fdf4"), // 연한 초록색 배경
  stroke: (left: 4pt + rgb("#22c55e")), // 초록색 왼쪽 테두리
  inset: 1.2em,
  radius: (right: 4pt),
  width: 100%,
  [
    #text(weight: "bold", fill: rgb("#15803d"))[Thm. #title] \
    #v(0.5em)
    #body
  ],
)

#let proof(body) = block(
  stroke: (left: 1pt + gray.lighten(50%)),
  inset: (left: 1em),
  width: 100%,
  [
    #text(style: "italic", fill: gray.darken(30%))[pf.] \
    #v(0.3em)
    #body
    #align(right)[$square$] // 증명 종료 기호
  ],
)

#let idea(title, body) = block(
  fill: rgb("#f5f3ff"), // 연한 보라색 배경
  stroke: (left: 4pt + rgb("#8b5cf6")), // 보라색 왼쪽 테두리
  inset: 1.2em,
  radius: (right: 4pt),
  width: 100%,
  [
    #text(weight: "bold", fill: rgb("#6d28d9"))[💡 #title] \
    #v(0.5em)
    #body
  ],
)

#let example(title, body) = block(
  stroke: (left: 1pt + gray.lighten(50%)),
  inset: (left: 1em),
  width: 100%,
  [
    #text(weight: "bold", fill: rgb("a00f10"))[Example. #title] \
    #v(0.3em)
    #body
  ],
)

// 상세 설명용 Definition (직관과 예시 내장형)
#let d-definition(title, intuition: none, example: none, body) = block(
  stroke: (left: 3pt + rgb("#3b82f6")), // 요약보다 배경을 빼고 선을 슬림하게
  inset: (left: 1.2em, y: 0.4em),
  width: 100%,
  [
    #text(weight: "bold", size: 11pt, fill: rgb("#1d4ed8"))[Def. #title] \
    #v(0.3em)
    #body

    // 직관(Intuition) 영역 분리
    #if intuition != none [
      #v(0.6em)
      #block(
        fill: rgb("#f0fdfa"), // 옅은 민트색으로 신선한 느낌
        inset: 0.8em,
        radius: 4pt,
        width: 100%,
        [#text(size: 10pt)[*🧠 직관:* #intuition]],
      )
    ]

    // 예시(Example) 영역 분리
    #if example != none [
      #v(0.5em)
      #block(
        fill: rgb("#f8fafc"), // 단정한 회색 배경
        inset: 0.8em,
        radius: 4pt,
        stroke: (left: 2pt + rgb("#cbd5e1")),
        width: 100%,
        [#text(size: 10pt)[*🔍 구체적 예시:* #example]],
      )
    ]
  ],
)

// 상세 설명용 Theorem (기하적/물리적 의미 강조형)
#let d-theorem(title, meaning: none, body) = block(
  stroke: (left: 3pt + rgb("#22c55e")),
  inset: (left: 1.2em, y: 0.4em),
  width: 100%,
  [
    #text(weight: "bold", size: 11pt, fill: rgb("#15803d"))[Thm. #title] \
    #v(0.3em)
    #body

    #if meaning != none [
      #v(0.6em)
      #text(size: 10pt, fill: rgb("#16a34a"))[*🎯 기하학적/구조적 의미:*]
      #text(size: 10pt)[ #meaning]
    ]
  ],
)

// 상세 설명용 Proof (설계도와 엄밀한 증명 분리형)
#let d-proof(blueprint: none, body) = block(
  stroke: (left: 1pt + rgb("#e2e8f0")),
  inset: (left: 1.2em, y: 0.4em),
  width: 100%,
  [
    #text(style: "italic", fill: gray.darken(40%))[Proof.] \

    // 증명의 큰 그림(Blueprint)을 먼저 제시
    #if blueprint != none [
      #v(0.4em)
      #block(
        fill: rgb("#fff7ed"), // 연한 귤색으로 아이디어 부각
        inset: 0.8em,
        radius: 4pt,
        stroke: 1pt + rgb("#ffedd5"),
        width: 100%,
        [#text(size: 10pt)[*🗺️ 증명 설계도 (The Big Picture):* #blueprint]],
      )
    ]
    #v(0.6em)
    #body
    #align(right)[$square$]
  ],
)

#let comp = math.class("binary", scale(60%, math.circle))
