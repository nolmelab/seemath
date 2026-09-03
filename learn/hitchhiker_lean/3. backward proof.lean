theorem prop_comp (a b c : Prop) (hab : a → b) (hbc : b → c) :
a → c := by
  intro ha
  apply hbc
  apply hab
  apply ha



theorem And_swap (a b : Prop) :
a ∧b →b ∧a :=
by
  intro hab
  apply And.intro
  apply And.right
  exact hab
  apply And.left
  exact hab


#print And.right

theorem And_swap_2 (a b : Prop) :
a ∧b →b ∧a :=
by
  intro hab
  apply And.intro
  exact And.right hab
  exact And.left hab


def f (x : Nat) := x


theorem f5_if (h : ∀n : Nat, f n = n) : f 5 = 5 := by
  exact h 5


def double (n : Nat) := n * n

theorem Exists_double_iden :
  ∃n : Nat, double n = n := by
  apply Exists.intro 0
  rfl

#print Exists
#print Exists.elim

theorem Eq_trans_symm {α : Type} (a b c : α)
(hab : a = b) (hcb : c = b) : a = c := by
  apply Eq.trans
  {
    exact hab
  }
  {
    apply Eq.symm
    exact hcb
  }

theorem Eq_trans_symm_2 {α : Type} (a b c : α)
(hab : a = b) (hcb : c = b) : a = c := by
  rw [hab]
  rw [hcb]

def add (m n : Nat) : Nat :=
  match m with
  | 0 => n
  | Nat.succ m' => Nat.succ (add m' n)

theorem add_zero (n : Nat) :
  add 0 n = n := by
  induction n with
  | zero => rfl
  | succ n' ih => simp [add, ih]

-- simp is rw on a list of rules.
