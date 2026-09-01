def add1 (n : Nat) : Nat := n + 1

#print add1

#eval add1 7 = 8

example : add1 7 = 8 := by
  rfl

#check (38 : Nat)

#print HAdd
