-- case analysis and mathematical induction
--

-- definition

#print Nat

inductive N : Type where
  | z : N
  | s : N → N
deriving Repr

#print N

-- cases


      --           Inductive Type N
      --                  │
      --     ┌────────────┴────────────┐
      --     │                         │
      -- Constructor               Eliminator
      --     │                         │
      --  "만든다"                   "쓴다"
      --     │                         │
      -- z, s                    N을 분석한다
      --                               │
      --                      ┌────────┴────────┐
      --                      │                 │
      --                  cases/match        recursion
      --                      │                 │
      --                  case analysis      Recursor
      --                                        │
      --                             ┌──────────┴──────────┐
      --                             │                     │
      --                          함수 정의              증명
      --                          toNat, add             induction

-- constructor builds a recursor
-- - a basis of the induction / ellimination
-- -


open N

def EqZero : N → Bool := by
  intro n
  cases n
  exact true
  exact false

-- The above code defines a function following cases or
-- following the recursor.

-- # Match

def Eqzero2 : N → Bool := by
  intro n
  match n with
    | z    => exact true
    | s _  => exact false

-- # Dedekind-Peano
-- ## Cases

theorem TZInj : ∀ (n : N), z ≠ s n := by
  intro n
  intro h
  cases h

-- cases를 볼 때:
--  "이 값을 쪼갠다"
-- 보다는
--  "이 값이 어떤 constructor로 만들어졌을 수 있는지를 열거한다."
-- 라고 생각해봐.


-- ## injection

def injective {A B : Type} (f : A → B) : Prop :=
  ∀{a₁ a₂ : A}, (f a₁ = f a₂) → (a₁ = a₂)

theorem TSuccInj : injective s := by
  intro n m
  intro h
  injection h


theorem TSuccInjAlt : injective s := by
  intro n m h
  have hnc := N.noConfusion h id
  exact hnc


#print N.noConfusionType 
#print N.casesOn 