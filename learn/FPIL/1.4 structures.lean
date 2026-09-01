structure Point where
  x : Float
  y : Float

def origin : Point :=
  { x := 0.0, y := 0.0 }

#print origin

#check ({ x := 0.0, y := 0.0 } : Point)

#print Point


def Point.add (v : Point ) (w : Point) : Point :=
  { x := v.x + v.x, y := w.y + w.y }

def delta : Point := { x := 1.0, y := 1.0 }

#eval Point.add origin delta

#eval origin.add delta

#print Vector
#print Array


def firstThree (xs : Vector Nat 3) : Nat :=
  xs.get ⟨0, by decide⟩

#print Fin
