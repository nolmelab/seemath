-- # Equalities

variable (A : Type)
variable (a b c d : A)
variable (P : A → Prop)

-- # Equality

#check Eq
#check Eq a b
#check a = b

#print Eq
-- refl : reflexive constructor only

#check Ne
#check a ≠ b

-- # Reflexivity

theorem TEqRfl (a: A) : a = a := by
  exact rfl

theorem T1 : 2 + 2 = 4 := by
  exact rfl

theorem T1_1 : 20000000 + 2 = 20000002 := by
  exact rfl

-- # Symmertry

theorem TEqSymm (h : a = b) : (b = a) := by
  exact Eq.symm h
  -- exact h.symm
  -- Eq.symm is a theorem. This is the first theorem in Lean.

#print Eq.symm

-- # Transitivity

theorem TEqTrans (h1 : a = b) (h2 : b = c) : (a = c) := by
  exact Eq.trans h1 h2

#print Eq.trans
-- The proof of Eq.trans uses ▸ or rw. rewrite tactic is very powerful in Lean.
-- The substitution or rewrite is very clear, and it makes Lean powerful.
-- P ↔ Q can be used to rewrite Props.

theorem TEqRw (h1: a = b) : P b ↔ P a := by
  apply Iff.intro
  -- We can achieve the goal if we apply and meet Iff.intro type constructor.
  -- hence, we split the goal and have two subgoals.
  -- P b → P a
  intro h2
  rewrite [h1]
  exact h2
  -- P a → P b
  intro h2
  rewrite [← h1] -- or rewrite [h1] at h2
  exact h2

-- # calc

theorem TCalc (h1 : a = b) (h2 : b = c) (h3: c = d) : (a = d) := by
  calc
    a = b := by rw [h1]
    _ = c := by rw [h2]
    _ = d := by rw [h3]
 -- each line is a proof.
 -- Eq.trans is being built underneath.

-- # Types with meaningful equality

-- # Decidable equality

-- A type has a decidable equality if there exists an algorithm to determine whether
-- any two elements of that type are equal. In Lean, this is captured by
-- the DecidableEq type class.

#print Decidable
#print DecidableEq

def DecidableEqBool : DecidableEq Bool := by
  intro a b
  match a, b with
    | false, false => exact isTrue rfl
    | false, true  => exact isFalse (fun h => Bool.noConfusion h)
    | true , false => exact isFalse (fun h => Bool.noConfusion h)
    | true , true  => exact isTrue rfl

-- TODO: This is a good time to stop.
-- Continue in the evening or tomorrow. Don't skip this.
-- Think about Decidable to begin with to understand DecidableEq.

#check Nat.decEq 

#check Nat.decEq 5 5 = isTrue rfl
#check (if 3 = 4 then "yes" else "no") = "no"
#check show 12 = 12 by decide


-- Function Charp
def Charp : Nat → Nat → Bool := by
  intro n m
  by_cases n = m
  -- Case n = m
  exact true
  -- Case n ≠ m
  exact false

-- Function Charp2
def Charp2 : Nat → Nat → Bool := fun n m => if n = m then true else false

-- Function Charpoint
noncomputable def Charpoint {A : Type} : A → A → Bool := by
  intro a b
  by_cases a = b
  -- Case a = b
  exact true
  -- Case a ≠ b
  exact false

-- Function Charpoint2
def Charpoint2 {A : Type} [DecidableEq A] : A → A → Bool :=
fun n m => if n = m then true else false


-- # Equality in Prop 

#print propext 

theorem TEqProp {Q : Prop} : (Q ∧ True) = Q := by
  apply propext
  apply Iff.intro
  -- Q ∧ True → Q
  intro h2
  exact h2.left
  -- Q → Q ∧ True
  intro h2
  apply And.intro
  exact h2
  trivial