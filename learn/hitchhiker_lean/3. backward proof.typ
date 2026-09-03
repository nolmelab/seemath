// Hitchhiker's Guide — S (Summarize) Template
// 목적: 치트시트처럼 핵심을 압축하되, 이해에 도달한 Trajectory와 실패/수정 과정을 보존한다.

#set page(
  paper: "a4",
  margin: (x: 18mm, y: 18mm),
)
#set text(font: "Libertinus Serif", size: 10pt)
#set par(justify: true, leading: 0.65em)

#let concept(title, core, details: none) = {
  block(
    width: 100%,
    inset: 9pt,
    radius: 4pt,
    stroke: 0.7pt + luma(190),
  )[
    *#title*

    #text(weight: "bold")[Key]\
    #core

    #if details != none [
      #v(3pt)
      #text(weight: "bold")[Memo]\
      #details
    ]
  ]
  v(7pt)
}

#let example(title, body) = {
  block(
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    fill: luma(245),
  )[
    *예제 — #title*

    #body
  ]
  v(7pt)
}

#let trajectory(title, body) = {
  block(
    width: 100%,
    inset: 9pt,
    radius: 4pt,
    stroke: (left: 2pt + luma(120)),
  )[
    *Trajectory — #title*

    #body
  ]
  v(7pt)
}

#let failure(title, body) = {
  block(
    width: 100%,
    inset: 9pt,
    radius: 4pt,
    stroke: (left: 2pt + luma(170)),
  )[
    *실패 / 혼동 — #title*

    #body
  ]
  v(7pt)
}

#let recall(question) = {
  block(
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    stroke: 0.7pt + luma(205),
  )[
    #text(weight: "bold")[AA]

    #question
  ]
  v(5pt)
}

= Chapter 3 — #emph[Summary]

#text(size: 9pt, fill: luma(90))[
  *Goal:* Understands backward proof concepts and tactics.
]

== 1. Core Concepts

#concept(
  "1. Tactics",
  [
    Tactics operate on the goal, which consists of the proposition Q that we want to prove and of a local context C.
  ],
  details: [
    intro, $forall$ is a function (implication),
  ],
)

```lean
theorem fst_of_two_props :
 ∀a b : Prop, a → b → a := by
  intro a b
  intro ha hb
  apply ha
```

```lean
theorem prop_comp (a b c : Prop) (hab : a →b) (hbc : b →c) : a → c := by
  intro ha
  apply hbc
  apply hab
  apply ha
```

#concept(
  "2. Basic Tactics",
  [
    intro, apply, exact, assumption, rfl, ac_rfl
  ],
  details: [
    - apply works for the target of the goal if at is not specified.
    - conversions: $alpha, beta, delta, zeta, eta, iota$
      - These are the computations for definitional equality, and they are used to simplify expressions in Lean.
    - ac_rfl is similar to rfl, but it can handle equalities that involve commutative and associative operations, such as addition and multiplication.
  ],
)

#concept(
  "3. Metavariable and Unification",
  [
    Unification is the process to find substitutions for metavariables that make two expressions equal. In Lean, unification is used to match the goal with the conclusion of a theorem or lemma, and to find the appropriate substitutions for the metavariables in the theorem or lemma.

    Metavariables are placeholders for terms that are not yet known, and unification is the process of finding a substitution for metavariables that makes two expressions equal.
  ],
  details: [
    It relies on term rewriting, symbolic computation, and type inference.
  ],
)

```lean
theorem And_swap (a b : Prop) : a ∧ b → b ∧ a := by
  intro hab
  apply And.intro
  apply And.right
  exact hab
  apply And.left
  exact hab
```

#concept(
  "4. Introduction and Elimination Rules",
  [
    An introduction rule for a logical symbol (e.g., ∧) is a theorem whose conclusion has that symbol as the outermost symbol. Dually, an elimination rule has the symbol in an assumption. For each logical symbol, the introduction rules tell us how to prove a proposition with that symbol as the
    outermost position. By contrast, the elimination rules tell us how we must have
    proved such a proposition.
  ],
  details: [
    - Natural deduction is a proof system that uses introduction and elimination rules to derive conclusions from premises. Lean is based on natural deduction, and its tactics are designed to help users apply these rules effectively.
    - Or.inl, Or.inr, Or.elim,
    - And.intro, And.left, And.right,
    - Not.intro, Not.elim,
    - Imp.intro, Imp.elim,
    - Iff.intro, Iff.elim
    - True.intro, False.elim,
    - Not is defined as $¬P := P → "False"$.
  ],
)

#concept(
  "5. for all is a function (implication)",
  [
    In Lean, the universal quantifier ∀ is treated as a function type, which means that proving a statement of the form ∀x : A, P x is equivalent to proving that for any x of type A, the proposition P x holds. This is closely related to implication, as it allows us to assume an arbitrary element and prove a property about it.

    $forall x, P thick x$ = $x -> P thick x$
  ],
)

```lean
theorem f5_if (h : ∀n : N, f n = n) : f 5 = 5 := by
  exact h 5
```

#concept(
  "6. Classical logic",
  [
    - Classical.em : ∀a : Prop, a ∨¬ a
    - Classical.byContradiction : (¬ ?a →False) →?a
  ],
)

#concept(
  "7. Equality",
  [
    - Eq.refl : ∀a, a = a
    - Eq.symm : ?a = ?b →?b = ?a
    - Eq.trans : ?a = ?b →?b = ?c →?a = ?c
    - Eq.subst : ?a = ?b →?P ?a →?P ?b
  ],
  details: [
    - Look at the code following and recall how it works. Look closely at the metavariables and subgoals.
    - apply is the core of backward proof.
  ],
)

```lean
theorem Eq_trans_symm {α : Type} (a b c : α) (hab : a = b) (hcb : c = b) : a = c := by
  apply Eq.trans
    { exact hab }
    { apply Eq.symm
      exact hcb }
```

#concept(
  "8. Rewriting",
  [
    Rewriting is the process of replacing a term in an expression with another term that is equal to it, according to some equality or equivalence relation. In Lean, rewriting can be done using the `rw` tactic, which allows us to apply equalities to transform expressions in our goals or hypotheses.
  ],
  details: [
    - rw tactic can be used to rewrite using equalities in the goal or in the hypotheses.
    - The `rw` tactic can also be used with the `←` symbol to rewrite in the opposite direction.
    - simp is rw with a set of simplification rules, which can be used to simplify expressions in the goal or in the hypotheses.
  ],
)

#concept(
  "9. Mathematical Induction",
  [
    Recursive inductive types can be defined in Lean, and mathematical induction is a proof technique that allows us to prove properties of these types by showing that they hold for the base case and that if they hold for an arbitrary case, they also hold for the next case. In Lean, we can use the `induction` tactic to perform mathematical induction on inductive types.
  ],
  details: [

  ],
)

```lean
theorem add_succ (m n : N) : add (Nat.succ m) n = Nat.succ (add m n) := by
induction n with
| zero => rfl
| succ n’ ih => simp [add, ih]

theorem add_comm (m n : N) : add m n = add n m := by
induction n with
| zero => simp [add, add_zero]
| succ n’ ih => simp [add, add_succ, ih]

theorem add_assoc (l m n : N) : add (add l m) n = add l (add m n) := by
induction n with
| zero => rfl
| succ n’ ih => simp [add, ih]
```

== 2. Ask → Answer

#recall([
  What is the core of the backward proof? How does it relate to the application of tactics and the use of metavariables? How does unification work in Lean, and how does it relate to metavariables and the application of tactics?
])

#recall([
  Write down introduction and elimination rules for each logical symbol. How do these rules relate to the application of tactics in Lean? How does the use of introduction and elimination rules affect the structure of proofs in Lean?
])

#recall([
  How does the universal quantifier ∀ relate to implication in Lean? How does this relationship affect the way we prove statements involving ∀ in Lean? How does the use of ∀ as a function type affect the structure of proofs in Lean?
])

#recall([
  Explain intro, apply, exact, assumption, rfl, ac_rfl tactics in Lean.
])

#recall([
  Explain rw, simp tactics in Lean. What are the conversions alpha, beta, delta, zeta, eta, iota? How do they relate to the simplification of expressions in Lean?
])

== 3. Remaining Questions

#block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  fill: luma(245),
)[
  - How does unification work in Lean, and how does it relate to metavariables and the application of tactics? Matching is one form of unification, but there are more general forms of unification that can handle more complex cases.

  - When is proper to use classical logic without construction of terms? How does it relate to the law of excluded middle and proof by contradiction? What are the implications of using classical logic in Lean, and how does it affect the constructiveness of proofs?
]

#pagebreak()
