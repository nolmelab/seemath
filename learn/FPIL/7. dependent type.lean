namespace Sec_7_1

-- # Indexed families

inductive Vect (α : Type u) : Nat → Type u where
   | nil : Vect α 0
   | cons : α → Vect α n → Vect α (n + 1)

#print Vect




end Sec_7_1
