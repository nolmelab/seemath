-- # Quantifiers
--

-- # Predicates

variable (A: Type)
variable (P : A → Prop)

-- ## Examples of Predicates

-- False predicate
def PFalse {A : Type} : A → Prop := fun _ => False

-- True predicate
def PTrue {A : Type} : A → Prop := fun _ => True


-- Conjunction of two predicates
def PAnd {A : Type} (P Q : A → Prop) : A → Prop := by
  intro a
  exact P a ∧ Q a

notation : 65 lhs:65 " ∧ " rhs:66 => PAnd lhs rhs


-- # Universal Quantifier

#check ∀ (a : A), P a -- explicit. User needs to specify a.
#check ∀ a, P a -- type interference
#check ∀ {a : A}, P a -- implicit. Lean can infer.

-- intro
theorem T1 : ∀ (a : A), P a := by
  intro a -- By introducing a fresh value, we start proving the universally qunatified Prop.
  sorry

variable (a : A)
variable (h : ∀ (a : A), P a)
#check h a


-- elimination
theorem T2 (a : A) (h : ∀ (a : A), P a) : P a := by
  specialize h a -- h is changed to the special case inplace.
  exact h -- that's P a, which is a Prop (a new type of Prop)

-- P is of type A → Prop
-- This is the key to use the universal quantification.
-- P a is a new type object in Prop universe  - Slot 0.

-- # Existential Quantifier

#check ∃ (a : A), P a
#check ∃ a, P a
#check Exists P

theorem T3 (a : A) (h : P a) : ∃ (a : A), P a := by
  exact Exists.intro a h

variable (Q : Prop)
theorem T4 (h1 : ∃ (a : A), P a) (h2 : ∀ (a : A), P a → Q) : Q := by
  cases h1
  rename_i a h3
  specialize h2 a
  exact h2 h3

-- Do I remember what I learned?

namespace Exercises
open Classical
variable (a b c : A)
variable (R : Prop)

theorem E1 : (∃ (a : A), R) → R := by
  intro h1
  apply Exists.elim h1  --
  intro h2
  intro h3
  exact h3


theorem E1_1 {A : Type} {R : Prop} : (∃ (a : A), R) → R := by
  intro h1
  -- extract things from intro. 
  -- instance value, proposition in Exists.intro case 
  cases h1 
  rename_i a hR
  exact hR

theorem E1_2 {A : Type} {R : Prop} : (∃ (a : A), R) → R := by
  intro h1
  cases h1 with
  | intro a hR => exact hR


theorem E2 (a : A) : R → (∃ (a : A), R) := by 
  intro hR 
  exact Exists.intro a hR  

theorem E3 : (∃ (a : A), P a ∧ R) ↔ (∃ (a : A), P a) ∧ R := by 
  constructor 
  -- 1st goal.
  intro hE 
  cases hE 
  rename_i a hPR 
  have hPa := by exact hPR.left 
  have hR := by exact hPR.right 
  have hEP := by exact Exists.intro a hPa 
  exact And.intro hEP hR 

  -- 2nd goal.
  intro hPR 
  have hEP := by exact hPR.left 
  have hR := by exact hPR.right 
  cases hEP 
  rename_i a hP 
  have hP_AND_R := by exact And.intro hP hR 
  exact Exists.intro a hP_AND_R 
    

#print And 
#print Or 
#print True 
#print False 
#print Iff 

theorem P_TO_Q {P : Prop}{Q : Prop} (p : P) (q : Q) : P → Q := by 
  intro hP 



theorem E4 : (∃ (a : A), (P ∨ Q) a) ↔ (∃ (a : A), P a) ∨ (∃ (a : A), Q a) :=  by sorry

theorem E5 : (∀ (a : A), P a) ↔ ¬(∃ (a : A), (¬P) a) := by sorry

theorem E6 : (∃ (a : A), P a) ↔ ¬ (∀ (a : A), (¬P) a) := by sorry

theorem E7 : (¬∃ (a : A), P a) ↔ (∀ (a : A), (¬P) a) := by sorry

theorem E8 : (¬∀ (a : A), P a) ↔ (∃ (a : A), (¬P) a) := by sorry

theorem E9 : (∀ (a : A), P a → R) ↔ (∃ (a : A), P a) → R := by sorry

theorem E10 (a : A) : (∃ (a : A), P a → R) → (∀ (a : A), P a) → R := by sorry

theorem E11 (a : A) : (∃ (a : A), R  →  P a) → (R → ∃ (a : A), P a) :=  by sorry

end Exercises
