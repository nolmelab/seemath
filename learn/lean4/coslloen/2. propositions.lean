-- Propositions

#check Prop
-- #print Prop
-- This shows an error like #check Type

variable (P : Prop)
variable (h : P)

#check P

-- # First proofs

theorem Th1 (h : P) : P := by
  exact h

#check Th1
#check Th1 P
#check Th1 P h

variable (Q : Prop )

#check Th1 Q

#print Th1

theorem Th2 { P : Prop } (h : P) : P := by
  exact h

#print Th2

#check Th2
#check Th2 h

variable (r : Q)
#check Th2 r

theorem Th3 { P : Prop } (h : P) : P := by
  apply Th2
  exact h 

-- ## have

theorem Th4 {P : Prop} (h : P) : P := by
  have h2 : P := by
    exact h
  exact h2

#check P ∧ Q 
#print And 
#print And.intro  

-- From a proof of P, we can obtain a proof of P ∨ Q
theorem ThOrInl (h : P) : P ∨ Q := by
  exact Or.inl h
  
-- From a proof of Q, we can obtain a proof of P ∨ Q
theorem ThOrInr (h : Q) : P ∨ Q := by
  exact Or.inr h