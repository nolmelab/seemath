-- # types and terms
--
notation "ℕ" => Nat

#print Bool
#print Nat
#print String

-- 결국 term을 만들고, term에 term을 적용하고, term을 다른 term으로 reduce하는 세계
-- This is a critical point of view in Lean and functional programming.

#eval (fun n : Int => n + 1) 5

#eval (fun n : ℕ => n + 1) 5

#print Add



inductive AExp : Type where
| num : Int →AExp
| var : String → AExp
| add : AExp → AExp → AExp
| sub : AExp → AExp → AExp
| mul : AExp → AExp → AExp
| div : AExp → AExp → AExp

def N1 := AExp.num 1
def N2 := AExp.num 2

#eval AExp.add N1 N2


def fib : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n + 2 => fib (n + 1) + fib n

#eval fib 2 


def append (α : Type) : List α →List α →List α
| List.nil, ys => ys
| List.cons x xs, ys => List.cons x (append α xs ys)

#eval append _ [1, 2, 3] [4, 5, 6]



