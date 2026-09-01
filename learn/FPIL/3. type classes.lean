#print HAdd

class Plus (α : Type) where
  plus : α → α → α

#print Plus

instance : Plus Nat where
  plus := Nat.add

open Plus (plus)

#eval plus 3 7

#print HAdd


inductive Pos : Type where
  | one : Pos
  | succ : Pos → Pos

def posToString (atTop : Bool) (p : Pos) : String :=
  let paren s := if atTop then s else "(" ++ s ++ ")"
  match p with
  | Pos.one => "Pos.one"
  | Pos.succ n => paren s!"Pos.succ {posToString false n}"
