-- Conjunction

#print And
#print And.intro

-- elimination E_1, E_2
-- h.left, h.right


-- Disjunction

#print Or

theorem ThOrInl (h : P) : P ∨ Q := by
  exact Or.inl h

#check Or.inl
-- Or.inl has a function type that returns Or
-- Rust의 enum과 같은 형식
-- Consider it as a function that can be extracted
-- with a pattern matching.

theorem ThOrCases (h: P ∨ Q) : Q ∨ P := by
  cases h -- splits into constructor cases
  rename_i hP
  exact Or.inr hP
  rename_i hQ
  exact Or.inl hQ

theorem ThOrCases2 (h: P ∨ Q) : Q ∨ P := by
  match h with
    | Or.inl hP => exact Or.inr hP
    | Or.inr hQ => exact Or.inl hQ

theorem ThOrCases3 (h: P ∨ Q) : Q ∨ P := by
  apply Or.elim h
  intro hP
  exact Or.inr hP
  intro hQ
  exact Or.inl hQ

-- Lean works very closely with infoview.
-- The current goal and premises are all we have.
-- intro can be used when the goal is of a -> b type.
-- intro creates a term of type a.

#print Or.elim


-- # Implication

-- From a proof of Q, we can obtain a proof of P → Q
theorem ThImpIn {Q P : Prop} (hQ : Q) : P → Q := by
  intro hP
  exact hQ


-- From a proof P → Q and a proof of P, we can obtain a proof of Q
theorem ThModusPonens {P Q : Prop} (h : P → Q) (hP : P) : Q := by
  exact h hP -- h is an implication, hence we can apply it as a function.


theorem ThModusPonens2 {P Q : Prop} (h : P → Q) (hP : P) : Q := by
  have hQ := h hP
  exact hQ

-- # Double Implication

#print Iff
-- modus pones, modus pones reversed
-- this is a structure having two functions a -> b, and b -> a.
-- The similarity to ∧ is not a coincidence, I think. It is a product type.


-- From P ↔ Q we can derive (P → Q) ∧ (Q → P)
theorem ThIffOut (h : P ↔ Q) : (P → Q) ∧ (Q → P) := by
  apply And.intro
  -- Left
  have PQ : P → Q := by exact h.mp
  exact PQ
  have QP : Q → P := by exact h.mpr
  exact QP

-- Lean manages context Γ for each subgoal.
-- Hence care must be taken on the scope of have subproofs.


-- From (P → Q) ∧ (Q → P) we can derive P ↔ Q
theorem ThIffIn (h1 : P → Q) (h2 : Q → P) : P ↔ Q := by
  exact Iff.intro h1 h2

variable (a : Prop)
variable (b : Prop)

#check a ↔ b



-- # True

#print True

-- True can always be obtained
theorem ThTrueIn : True := by
  exact True.intro

-- Trivial is an element of type True
theorem ThTrivial : True := by
  exact trivial

-- False

#print False


-- False implies any proposition
theorem ThExFalso {P : Prop} : False → P := by
  intro h
  exact False.elim h  -- The elimination rule of False in Natural deduction.

-- # Negation

#print Not

-- Not is an implication that returns False

theorem ThModusTollens (h1 : P → Q) (h2 : ¬Q) : ¬P := by
  -- Assume P is true (to prove ¬P, which is P → False).
  intro h3
  -- Derive Q from P → Q and P.
  have h4 : Q := by
    exact h1 h3
  -- Use ¬Q (Q → False) and Q to derive False.
  exact h2 h4

-- !!! intro only looks at the current goal.
-- If it is a function (implication), then the premise is the one.
--


-- # Decidable Propositions

#print Decidable

def DecidableTrue : Decidable True := by
  have DTrue := isTrue True.intro
  exact DTrue


-- False is decidable
def DecidableFalse : Decidable False := by
  exact isFalse id

-- If P is decidable, then ¬ P is decidable
def DecidableNot {P : Prop} : Decidable P → Decidable (¬ P) := by
  intro hP
  match hP with
    | isFalse hP => exact isTrue  (fun h => False.elim (hP h))
    | isTrue hP  => exact isFalse (fun h => False.elim (h hP))

-- If P and Q are decidable, then P ∧ Q is decidable
def DecidableAnd {P Q : Prop} : Decidable P → Decidable Q → Decidable (P ∧ Q) := by
  intro hP hQ
  match hP, hQ with
    | isFalse hP, _           => exact isFalse (fun h => hP h.left)
    | _         , isFalse hQ  => exact isFalse (fun h => hQ h.right)
    | isTrue hP , isTrue hQ   => exact isTrue (And.intro hP hQ)

-- If P and Q are decidable, then P ∨ Q is decidable
def DecidableOr {P Q : Prop} : Decidable P → Decidable Q → Decidable (P ∨ Q) := by
  intro hP hQ
  match hP, hQ with
    | isTrue hP , _            => exact isTrue (Or.inl hP)
    | _         , isTrue hQ    => exact isTrue (Or.inr hQ)
    | isFalse hP, isFalse hQ   => exact isFalse (fun h => h.elim hP hQ)

-- If P and Q are decidable, then P → Q is decidable
def DecidableImplies {P Q : Prop} : Decidable P → Decidable Q → Decidable (P → Q) := by
  intro hP hQ
  match hP, hQ with
    | isFalse hP , _          => exact isTrue  (fun h => False.elim (hP h))
    | _          , isTrue hQ  => exact isTrue  (fun _ => hQ)
    | isTrue hP  , isFalse hQ => exact isFalse (fun h => hQ (h hP))

-- If P and Q are decidable, then P ↔ Q is decidable
def DecidableIff {P Q : Prop} : Decidable P → Decidable Q → Decidable (P ↔ Q) := by
  intro hP hQ
  have hPtoQ : Decidable (P → Q) := DecidableImplies hP hQ
  have hQtoP : Decidable (Q → P) := DecidableImplies hQ hP
  match hPtoQ, hQtoP with
    | isFalse hPtoQ, _ => exact isFalse (fun h => hPtoQ h.mp)
    | _, isFalse hQtoP => exact isFalse (fun h => hQtoP h.mpr)
    | isTrue  hPtoQ, isTrue  hQtoP => exact isTrue (Iff.intro hPtoQ hQtoP)


-- Classical Logic

namespace Exercises
variable (A B C D I L M P Q R : Prop)

theorem T51 (h1 : P) (h2 : P → Q) : P ∧ Q := by
  have hQ := by
    exact h2 h1
  exact And.intro h1 hQ

theorem T52 (h1 : P ∧ Q → R) (h2 : Q → P) (h3 : Q) : R := by
  have hP := by exact h2 h3
  have hPQ := by exact And.intro hP h3
  exact h1 hPQ

theorem T53 (h1 : P → Q) (h2 : Q → R) : P → (Q ∧ R) := by
  intro hP
  have hQ := by exact h1 hP
  have hR := by exact h2 hQ
  exact ⟨hQ, hR⟩

theorem T54 (h1 : P) : Q → P := by
  intro hQ
  exact h1

theorem T55 (h1 : P → Q) (h2 : ¬Q) : ¬P := by
  intro hP
  have hQ := by exact h1 hP
  exact h2 hQ -- ¬ Q = Q → False

theorem T56 (h1 : P → (Q → R)) : Q → (P → R) := by
  intro hQ
  intro hP
  have hQR := by exact h1 hP
  exact hQR hQ

theorem T57 (h1 : P ∨ (Q ∧ R)) : P ∨ Q := by
  apply Or.elim h1
  -- left
  intro hP
  exact Or.inl hP
  -- right
  intro hQR
  have hQ := by exact And.left hQR
  exact Or.inr hQ

theorem T58 (h1 : (L ∧ M) → ¬P) (h2 : I → P) (h3 : M) (h4 : I) : ¬L := by sorry

theorem T59 : P → P := by
  intro hP
  exact hP

theorem T510 : ¬ (P ∧ ¬P) := by
  intro P_notP
  have hP := by exact And.left P_notP
  exact And.right P_notP hP

theorem T511 (hP: P) : P ∨ ¬P := by
  -- This cannot be proven in contructive logic.
  sorry

theorem T512 (h1 : P ∨ Q) (h2 : ¬P) : Q := by
  apply Or.elim h1
  -- left
  intro hP
  have hFALSE := by exact h2 hP
  exact False.elim hFALSE
  -- right
  intro hQ
  exact hQ

theorem T513 (h1 : A ∨ B) (h2 : A → C) (h3 : ¬D → ¬B) : C ∨ D := by 
  sorry

theorem T514 (h1 : A ↔ B) : (A ∧ B) ∨ (¬A ∧ ¬B) := by sorry

end Exercises
