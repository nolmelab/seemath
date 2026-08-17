-- # function

variable (A B C D : Type)

#check A → B

variable (f g : A → B)

variable (a : A)

#check f a

-- # Equality

-- function extensionality

#check ∀ (a : A), f a = g a → f = g -- funext

theorem TEqApl : f = g ↔ ∀ (a : A), f a = g a := by
  apply Iff.intro
  -- f = g → ∀ (a : A), f a = g a
  intro h a
  exact congrFun h a -- f = g →  f a = g a ∀ a: A
  -- (∀ (a : X), f a = g a) → f = g
  intro h
  exact funext h

-- # Composition

variable (h : B → C)

#check h ∘ f

theorem TCompAss {A B : Type} {f : A → B} {g : B → C} {h : C → D} :
h ∘ (g ∘ f) = (h ∘ g) ∘ f := by
  funext a
  exact rfl


-- Lean에서는 이처럼 별도의 공리나 정리 없이 정의와
-- 환원(Reduction)만으로 양변이 완벽히 동일해지는 상태를
-- Definitional Equality(정의적 동등성)라고 불러.

-- rfl (Reflexivity)은 Definitional Equality가 성립하는 모든
-- 곳에서 "어떤 대상은 자기 자신과 같다 ($x = x$)"라는 논리로
-- 증명을 0초 만에 끝내버리지.

-- # Identity function

theorem TIdNeutral : (f ∘ id = f) ∧ (id ∘ f = f) := by
  apply And.intro
  -- f ∘ id = f
  funext a -- is it equal if we apply the functions?
  exact rfl -- yes, by reduction (or definitional equality)
  -- id ∘ f = f
  funext a
  exact rfl -- mostly by delta reduction, I think.

#check @id A

-- # Injections

-- ## Injective

def injective {A B : Type} (f : A → B) : Prop :=
  ∀{a₁ a₂ : A}, (f a₁ = f a₂) → (a₁ = a₂)

-- ## Monomorphism

def monomorphism {A B : Type} (f : A → B) : Prop :=
  ∀{C : Type}, ∀{g h : C → A}, f ∘ g = f ∘ h → g = h

-- C → A → B


-- ## Left Inverse

def has_left_inv {A B : Type} (f : A → B) : Prop :=
  ∃(g : B → A), g ∘ f = id


-- The identity is injective
theorem TIdInj : injective (@id A) := by
  -- rw [injective] -- rw to recover the definition
  intro a1 a2 h
  calc
    a1 = id a1 := by exact rfl
    _  = id a2 := by exact h
    _  = a2    := by exact rfl

-- The identity is a monomorphism
theorem TIdMon : monomorphism (@id A) := by
  -- rw [monomorphism] -- rw to recover the definition
  intro C g h h1
  calc
    g = id ∘ g := by exact rfl
    _ = id ∘ h := by exact h1
    _ = h      := by exact rfl

-- The identity has a left inverse
theorem TIdHasLeftInv : has_left_inv (@id A) := by
  -- rw [hasleftinv] -- rw to recover the definition
  apply Exists.intro id -- I will apply this to the goal and change the goal.
  exact rfl -- Reduction will reach to the definitional equality.

#print injective

-- exercises

open Classical

-- Negation of injective
theorem TNegInj {A B : Type} {f : A → B} : ¬ (injective f) ↔ ∃(a1 a2 : A),
f a1 = f a2 ∧ a1 ≠ a2 := by
  apply Iff.intro
  intro h1
  unfold injective at h1
  apply byContradiction 
  intro h_no_exists 
  apply h1 
  intro a1 a2 h_feq 
  apply byContradiction 
  intro h_neq 
  apply h_no_exists 
  exact ⟨ a1, a2, h_feq, h_neq ⟩ 

  intro h2 h_inj 
  rcases h2 with ⟨ a1, a2, h_eq, h_neq ⟩ 
  exact h_neq (h_inj h_eq) 


  
 

-- The composition of injective functions is injective
theorem TCompInj {A B : Type}  {f : A → B} {g : B → C} (h1 : injective f)
(h2 : injective g) : injective (g ∘ f) := by sorry

-- If the composition (g∘f) is injective, then f is injective
theorem TCompRInj {A B : Type} {f : A → B} {g : B → C} (h1 : injective (g ∘ f))
: (injective f) := by sorry

-- Injective and Monomorphism are equivalent concepts
theorem TCarMonoInj {A B : Type} {f : A → B} : injective f ↔ monomorphism f := by sorry

-- If a function has a left inverse then it is injective
theorem THasLeftInvtoInj {A B : Type} {f : A → B} : hasleftinv f → injective f := by sorry
