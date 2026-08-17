#check 3


def a := 3
#eval a


#print Bool

def b := Bool.false

#check b
#eval b

#print String

#check "Hello"
#check "Hello".toByteArray
#eval "Hello".toByteArray


#print List
#print Nat
#print Char


def sum ( a : Nat ) ( b : Nat ) : Nat := a + b

#check sum

def sum_c := sum 3

#check sum_c

def sum_3 : Nat  → Nat → Nat:= by
 intro a b
 exact a + b

#eval sum_3 4 5

def BootNot : Bool → Bool := by
  intro b
  cases b
  exact true
  exact false

def BootNot2 : Bool → Bool := by
  intro b
  cases b with
    | true => exact false
    | false => exact true

#check 2 + 2 < 1 

#eval 2 + 2 < 1 