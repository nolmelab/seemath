-- Monads again.  Look carefully.
-- Understand it with my brain version enhanced.


def andThen (opt : Option α) (next : α → Option β) : Option β :=
  match opt with
  | none => none
  | some x => next x

infixl:55 " ~~> " => andThen


def firstThirdFifthSeventh (xs : List α) : Option (α × α × α × α) :=
  xs[0]? ~~> fun first =>
  xs[2]? ~~> fun third =>
  xs[4]? ~~> fun fifth =>
  xs[6]? ~~> fun seventh =>
  some (first, third, fifth, seventh)


#eval firstThirdFifthSeventh [1, 2, 3, 4]

def xs := [1, 2, 3, 4]

#print xs

#eval xs[0]?
#eval xs[11]?

-- # Propagating Error Messages

inductive Result (ε : Type) (α : Type) where
  | error : ε → Result ε α
  | ok : α →  Result ε α
deriving BEq, Hashable, Repr

def andThenResult (attempt : Result e α) (next : α → Result e β) : Result e β :=
  match attempt with
  | Result.error msg => Result.error msg
  | Result.ok x => next x


def ok (x : α) : Result ε α := Result.ok x

def fail (err : ε) : Result ε α := Result.error err


infixl:55 " ~~> " => andThenResult


def get (xs : List α) (i : Nat) : Result String α :=
  match xs[i]? with
  | none => fail s!"Index {i} not found (maximum is {xs.length - 1})"
  | some x => ok x

def firstThirdFifthSeventhResult (xs : List α) : Result String (α × α × α × α) :=
  get xs 0 ~~> fun first =>
  get xs 2 ~~> fun third =>
  get xs 4 ~~> fun fifth =>
  get xs 6 ~~> fun seventh =>
  ok (first, third, fifth, seventh)

-- # Logging
def isEven (i : Int) : Bool :=
  i % 2 == 0

def sumAndFindEvens : List Int → List Int × Int
  | [] => ([], 0)
  | i :: is =>
    let (moreEven, sum) := sumAndFindEvens is
    (if isEven i then i :: moreEven else moreEven, sum + i)

namespace Log

def xs : List Int := [1, 3, 5, 8, 10]

#eval sumAndFindEvens xs

structure WithLog (logged : Type) (α : Type) where
  log : List logged
  val : α

def andThen (result : WithLog α β) (next : β → WithLog α γ) : WithLog α γ :=
  let {log := thisOut, val := thisRes} := result
  let {log := nextOut, val := nextRes} := next thisRes
  {log := thisOut ++ nextOut, val := nextRes}

def ok (x : β) : WithLog α β := {log := [], val := x}

def save (data : α) : WithLog α Unit :=
  {log := [data], val := ()}

def sumAndFindEvens : List Int → WithLog Int Int
  | [] => ok 0
  | i :: is =>
    andThen (if isEven i then save i else ok ()) fun () =>
    andThen (sumAndFindEvens is) fun sum =>
    ok (i + sum)

infixl:55 " ~~> " => andThen

def sumAndFindEvens2 : List Int → WithLog Int Int
  | [] => ok 0
  | i :: is =>
    (if isEven i then save i else ok ()) ~~> fun () =>
    sumAndFindEvens is ~~> fun sum =>
    ok (i + sum)

#eval sumAndFindEvens2 xs



end Log


namespace Monads

#print Monad
#print Except

instance : Monad Option where
  pure x := some x
  bind opt next :=
    match opt with
    | none => none
    | some x => next x

instance : Monad (Except ε) where
  pure x := Except.ok x
  bind attempt next :=
    match attempt with
    | Except.error e => Except.error e
    | Except.ok x => next x

def firstThirdFifthSeventh [Monad m] (lookup : List α → Nat → m α)
    (xs : List α) : m (α × α × α × α) :=
  lookup xs 0 >>= fun first =>
  lookup xs 2 >>= fun third =>
  lookup xs 4 >>= fun fifth =>
  lookup xs 6 >>= fun seventh =>
  pure (first, third, fifth, seventh)

def slowMammals : List String :=
  ["Three-toed sloth", "Slow loris"]

def fastBirds : List String := [
  "Peregrine falcon",
  "Saker falcon",
  "Golden eagle",
  "Gray-headed albatross",
  "Spur-winged goose",
  "Swift",
  "Anna's hummingbird"
]

#eval firstThirdFifthSeventh (fun xs i => xs[i]?) slowMammals

end Monads

namespace Sec_4_2

#print Option
#synth Applicative Option
#print Except


def slowMammals : List String :=
  ["Three-toed sloth", "Slow loris"]

def fastBirds : List String := [
  "Peregrine falcon",
  "Saker falcon",
  "Golden eagle",
  "Gray-headed albatross",
  "Spur-winged goose",
  "Swift",
  "Anna's hummingbird"
]

def getOrExcept (xs : List α) (i : Nat) : Except String α :=
  match xs[i]? with
  | none =>
    Except.error s!"Index {i} not found (maximum is {xs.length - 1})"
  | some x =>
    Except.ok x

def firstThirdFifthSeventh [Monad m] (lookup : List α → Nat → m α)
    (xs : List α) : m (α × α × α × α) :=
  lookup xs 0 >>= fun first =>
  lookup xs 2 >>= fun third =>
  lookup xs 4 >>= fun fifth =>
  lookup xs 6 >>= fun seventh =>
  pure (first, third, fifth, seventh)

#eval firstThirdFifthSeventh getOrExcept slowMammals



end Sec_4_2

namespace Sec_4_3

-- # Arithemetic in Monads

#print List

inductive Expr (op : Type) where
  | const : Int → Expr op
  | prim : op → Expr op → Expr op → Expr op

def ll := open Expr in
 @const Int 3

#print ll

inductive Arith where
  | plus
  | minus
  | times
  | div

#print Arith


end Sec_4_3

namespace Sec_4_5 -- IO

#print IO
#print EIO
#print EST
#print EST
#print EST.Out

#print IO.println
#print IO.print


instance : Applicative Option where
  pure x := .some x
  seq f x :=
    match f with
    | none => none
    | some g => g <$> x ()

end Sec_4_5

namespace Sec_5_2

structure Pair (α β : Type) : Type where
  first : α
  second : β

instance : Functor (Pair α) where
  map f x := ⟨x.first, f x.second⟩

#print Functor

def p1 := Pair.mk 1 2
#print p1

#eval (fun n => n + 1) <$> p1 

#print Applicative 

#print Subtype 

def FastPos : Type := {x : Nat // x > 0}

#print FastPos 

def PositiveInteger := {n : Int // 0 < n}

def n : PositiveInteger := ⟨5, by decide⟩ 



end Sec_5_2
