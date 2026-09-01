# Functional Programming in Lean 4

The well known tutorial on the programming in Lean 4. 

Work with Codex. 

# 1.1 Evaluating Expressions

I’ll anchor this in the actual “Evaluating Expressions” section, then frame its Lean-specific lessons against your C-family and functional-programming background, with special attention to what evaluation does and does not yet say about proofs.

Fetched https://lean-lang.org/functional_programming_in_lean/Getting-to-Know-Lean/Evaluating-Expressions/

**Summary**

The first section of [“Evaluating Expressions”](https://lean-lang.org/functional_programming_in_lean/Getting-to-Know-Lean/Evaluating-Expressions/) establishes Lean’s basic computational model:

- Lean programs are primarily **expressions**, like mathematical expressions.
- Evaluation means repeatedly reducing an expression to a value:
  $$2 \times (3 + 1) \;\longrightarrow\; 2 \times 4 \;\longrightarrow\; 8$$
- Variables are immutable. There is no ordinary mutable-memory model in Lean’s core language, and pure evaluation has no side effects.
- Consequently, expressions with the same value can be substituted for one another without changing the result. This is the computational intuition behind **referential transparency**.

**Lean syntax**

Lean uses `#eval` to evaluate an expression interactively:

```lean
#eval 1 + 2
-- 3
```

Arithmetic follows ordinary precedence:

```lean
#eval 1 + 2 * 5
-- 11
```

Function application is written by juxtaposition rather than parentheses:

```lean
#eval String.append "Hello, " "Lean!"
-- "Hello, Lean!"
```

This is important because application associates to the left:

```lean
String.append "a" "b"
```

means applying `String.append` to two arguments. Parentheses are needed when an argument is itself a compound expression:

```lean
#eval String.append "great " (String.append "oak " "tree")
-- "great oak tree"
```

Without parentheses, Lean would interpret the following function application as another argument.

**Conditionals are expressions**

Unlike C or C++, Lean does not distinguish fundamentally between conditional statements and conditional expressions. Its conditional construct always produces a value:

```lean
#eval
  String.append "it is "
    (if 1 > 2 then "yes" else "no")
-- "it is no"
```

The condition is evaluated first; only the selected branch contributes to the result:

```text
String.append "it is " (if 1 > 2 then "yes" else "no")
→ String.append "it is " (if false then "yes" else "no")
→ String.append "it is " "no"
→ "it is no"
```

The arrow notation is simply a compact way of showing successive reductions.

**Partial application**

If a function is given too few arguments, the result is another function:

```lean
String.append "it is "
```

has a type morally equivalent to:

```lean
String → String
```

`#eval` cannot print that result because functions are not ordinary displayable values. The resulting error is not saying that the function application is invalid; it is saying that Lean lacks a way to show a function value to the user.

This is the first place where Lean’s treatment should feel familiar from Haskell, OCaml, or F#: functions are naturally curried, and partial application is ordinary computation.

**Why this matters for your goals**

This section is deliberately pre-theoretical, but it introduces the foundation for later proof-oriented programming:

1. **Definitions compute.** A function is not merely a black-box procedure; applying it can reduce an expression.
2. **Types constrain expressions.** Every expression has a type, and Lean checks that applications and branches are compatible.
3. **Proofs will also be expressions.** Later, a proposition will be treated as a type, and a proof of that proposition as a value of that type.
4. **Some proofs reduce by computation.** For example, if a proposition can be decided by evaluating a Boolean-like computation, Lean may establish it through reduction rather than through a separate runtime test.
5. **Dependent types extend this idea.** Eventually, types themselves may contain values, so evaluating an expression can simplify not only a program result but also the type of a term.

A useful distinction at this stage is:

- `#eval` asks: **What value does this program compute?**
- A theorem asks: **Can Lean verify that a proposition has a proof?**

Those mechanisms overlap because proofs are terms in Lean, but they are not identical. `#eval` is an execution-oriented command; proof checking is kernel verification. The deeper “programs as proofs” perspective arrives when the book introduces propositions, proofs, inductive types, recursors, and elimination.

For your Monad focus, this chapter is mainly teaching the substrate on which monadic programming rests: expressions, application, immutability, and reduction. It does **not** yet address monads as functors or natural transformations. In categorical terms, a monad is more specifically an endofunctor equipped with unit and multiplication, or equivalently with `pure` and `bind` satisfying laws.


**Notes**

- Expressions 
- Immutability 
- Reductions are the steps of the evaluation process.
    - evaluating arithmetic;
    - unfolding definitions;
    - applying functions to arguments;
    - selecting a branch of an if;
    - simplifying pattern matches;
    - reducing recursive functions when their inputs are sufficiently known.

There are several related notions:

- Normal form: no further reduction is possible anywhere under the chosen rules.
- Value: a result considered finished for the evaluator. In call-by-value semantics, every value is usually a normal form, but not every normal form must be a value.
- Weak-head normal form: only the outermost structure has been reduced enough to reveal its constructor, lambda, or other head form.

Type constraints which type it can be reduced to. 


**Terms**

In Lean, a term is an expression that can have a type. 

Terms are syntactic objects constructed from variables, constants, application, lambdas, local bindings, and inductive constructors. 

Lean assigns each term a type, and reduction computes terms by unfolding definitions and applying the corresponding computation rules.

# 1.2 Types 

> A type classifies the values an expression can compute. 

Expression emphasizes syntax that can be evaluated.
Term emphasizes an object in the type theory that can receive a type.
In Lean discussions, they are often used nearly interchangeably.

- A term has a type.
- A type is also a term.
- A type may depend on terms.
- A proposition is a type.
- A proof is a term inhabiting that proposition-type.

term/expression
├── may be atomic: 42, x, true
└── may be compound: f x, x + 1, if c then a else b


# 1.3 Functions and Definitions

define a function
→ obtain a computation rule
→ computation can expose equality
→ equality can sometimes be proved by reduction

> Types are terms in Lean’s dependent type theory, and they participate in definitional reduction. They are not necessarily runtime data values.

> In Lean, types are terms classified by universes such as Type. They can reduce and can be passed as arguments to functions whose domains are universes. This allows type constructors and dependent functions to produce types based on type or value arguments.

Types generally do not become runtime values in compiled programs. They are used during:
- elaboration;
- type inference;
- type checking;
- proof checking;
- definitional equality checking.

> Types are computationally meaningful to the verifier, but usually computationally irrelevant to the generated runtime program.

Understanding `Type class` requires more work. 
- Needs to write examples. 
- Understand the structure of interpretation. 


**Elaboration** is Lean’s process of turning human-friendly notation and partial information into an explicit typed term. It happens before kernel verification, and it is responsible for inference, overloaded notation, implicit arguments, coercions, and type-class resolution.

Lean elaboration is like semantic analysis plus insertion of implicit syntax, with the additional responsibility of constructing fully typed terms in a dependent type theory.

# 1.4 Structures 

**Using recusion**:
base constructor:
  return the base result

recursive constructor:
  recursively solve the smaller input,
  then extend or transform that result

**Termnination of the Reursion**
The recursive call uses n again, unchanged. Lean cannot establish that the function reaches a base case.

Termination is not merely a runtime safety feature. It is essential for logic:

If Lean accepted arbitrary nonterminating definitions, a function could potentially be used to construct invalid proofs.

## Constructors and Eliminators 

This is why inductive types are so central to Lean. They are not just a data-definition feature. They define:

- what values exist;
- how values are constructed;
- how values can be analyzed;
- how values compute under analysis;
- how induction over those values works.

> The constructors define the data; pattern matching defines computation; induction defines reasoning.



# Polymorphism 

**Errors**:

universe error
  datatype declaration is rejected

positivity error
  recursive datatype could threaten consistency

termination error
  recursive function is not visibly decreasing

missing type argument
  elaboration cannot form a complete type

missing Repr instance
  computation succeeded, but output formatting failed


# Characters, Strings, and Slices 


# Additional Conveniences 


Lean’s convenient syntax is mostly a readable notation layer over the core language of typed terms, constructors, functions, local bindings, and eliminations. Understanding the expanded form is more important than memorizing every shorthand.

They are used often. So knowing them is essential. AI can explain them always. 


# 3. Type Classes 

traits in Rust. 

> Type classes form a compositional language for expressing reusable mathematical assumptions.

Since you know Rust traits, the best mental model is:

> A Lean **type class** is similar to a Rust trait, and an **instance** is similar to a Rust `impl`.

## 1. Declaring a type class

Lean:

```lean
class Describable (α : Type) where
  describe : α → String
```

Rough Rust equivalent:

```rust
trait Describable {
    fn describe(&self) -> String;
}
```

The class says: for a type `α`, there may be an implementation providing `describe`.

## 2. Defining an instance

Lean:

```lean
structure Person where
  name : String

instance : Describable Person where
  describe p := "Person: " ++ p.name
```

Rust:

```rust
impl Describable for Person {
    fn describe(&self) -> String {
        format!("Person: {}", self.name)
    }
}
```

## 3. Requesting an instance

Lean uses square brackets for an implicit type-class parameter:

```lean
def showDescription [Describable α] (value : α) : String :=
  Describable.describe value
```

This means approximately:

```lean
def showDescription
    (instance : Describable α)
    (value : α) : String :=
  instance.describe value
```

The difference is that Lean automatically synthesizes the bracketed argument.

Usage:

```lean
#eval showDescription { name := "Ada" }
```

Lean infers:

```lean
α := Person
```

and finds the `Describable Person` instance.

In Rust, trait bounds are written explicitly:

```rust
fn show_description<T: Describable>(value: T) -> String {
    value.describe()
}
```

## 4. Type classes enable overloaded notation

Many operators are type-class based.

For example:

```lean
#check (· + ·)
```

The `+` does not intrinsically mean integer addition. It uses an `HAdd` instance:

```lean
class HAdd (α : Type) (β : Type) (γ : outParam Type) where
  hAdd : α → β → γ
```

Conceptually:

```text
HAdd input-left-type input-right-type output-type
```

This allows expressions such as:

```lean
2 + 3
```

for natural numbers, integers, floating-point numbers, matrices, vectors, and user-defined types, provided appropriate instances exist.

Rust has a close analogue:

```rust
use std::ops::Add;

impl Add for MyType {
    type Output = MyType;

    fn add(self, rhs: MyType) -> MyType {
        ...
    }
}
```

The important Lean distinction is that `HAdd` permits the input and output types to differ:

```lean
α → β → γ
```

That is why it is called heterogeneous addition.

## 5. Classes can contain laws, not only operations

A Lean class may contain proofs describing required behavior.

For example:

```lean
class MyOrder (α : Type) where
  le : α → α → Prop
  le_refl : ∀ x, le x x
```

An instance must provide both:

1. the operation `le`;
2. a proof that `le` is reflexive.

Rust traits can contain methods and associated types, but Lean classes can naturally contain propositions and proofs as fields. This is central to formal mathematics.

The standard classes build on this idea:

```lean
class AddMonoid (α : Type) extends Add α, Zero α where
  add_assoc : ...
  zero_add : ...
  add_zero : ...
```

This resembles Rust trait inheritance:

```rust
trait AddMonoid: Add + Default {
    // laws are not normally expressible as compile-time fields
}
```

But Lean’s laws are actual data: proofs that can be used by later definitions and theorems.

## 6. Extending classes

Lean:

```lean
class Pretty (α : Type) where
  pretty : α → String

class PrettyAndSized (α : Type)
    extends Pretty α where
  size : α → Nat
```

An instance of `PrettyAndSized α` automatically includes a `Pretty α` implementation.

This is similar to:

```rust
trait Pretty {
    fn pretty(&self) -> String;
}

trait PrettyAndSized: Pretty {
    fn size(&self) -> usize;
}
```

Lean’s structure inheritance is especially important because type classes are structures underneath.

## 7. Type-class search

Suppose:

```lean
def render [ToString α] (value : α) : String :=
  toString value
```

When Lean sees:

```lean
render someValue
```

it searches for an instance of:

```lean
ToString (typeOf someValue)
```

The search may use:

- directly declared instances;
- instances built from other instances;
- parent classes;
- local instances;
- automatically derived instances.

For example, if a type has an `AddGroup` instance and a theorem requires an `AddMonoid` instance, Lean can obtain the parent `AddMonoid` structure from `AddGroup`.

Rust trait solving performs a similar job for trait bounds, but Lean’s type-class mechanism is more general and is heavily used for notation, algebraic structures, representations, equality, ordering, serialization, and proofs.

## 8. Ordinary parameters versus instance parameters

Compare:

```lean
def useFormatter (formatter : Formatter α) (value : α) :=
  formatter.format value
```

with:

```lean
def useFormatter [Formatter α] (value : α) :=
  Formatter.format value
```

The first requires the caller to supply the formatter explicitly:

```lean
useFormatter myFormatter value
```

The second asks Lean to synthesize one:

```lean
useFormatter value
```

The square brackets communicate:

> This argument is an implementation or capability that should usually be inferred automatically.

Rust often expresses the same idea through trait bounds, but the implementation is not passed as an ordinary visible function argument.

## 9. Explicitly selecting an instance

Although Lean normally infers instances, you can provide one explicitly:

```lean
def describeWith
    (instance : Describable α)
    (value : α) : String :=
  instance.describe value
```

Or use a named instance:

```lean
let custom : Describable Person := ...
let result := @showDescription Person custom person
```

The `@` exposes normally implicit arguments. This is useful for understanding what elaboration has inserted.

## 10. Local instances

An instance can be limited to a local scope:

```lean
section
  letI : Describable Person where
    describe p := "Custom: " ++ p.name

  #eval showDescription { name := "Ada" }
end
```

`letI` creates a local instance. This is somewhat like introducing a local implementation or passing a temporary strategy object, though Lean’s type-class search automatically finds it.

## 11. Deriving instances

Lean can generate many routine instances:

```lean
structure Point where
  x : Int
  y : Int
  deriving Repr, BEq
```

This asks Lean to generate implementations for:

- `Repr`, so values can be displayed;
- `BEq`, so values can be compared with Boolean equality.

This is similar to Rust:

```rust
#[derive(Debug, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}
```

The generated code is not magic at runtime; it is an instance definition produced by elaboration or compiler support.

## 12. The key difference from Rust

The most important conceptual difference is:

> Lean type classes are not merely interfaces for runtime dispatch. 
  They are also a mechanism for supplying compile-time mathematical structure and proofs.

For example, a theorem might require:

```lean
variable [AddGroup α]
```

This does not merely mean “`α` has addition methods.” It means Lean has access to:

- addition;
- zero;
- negation;
- associativity proofs;
- identity proofs;
- inverse proofs;
- and related inherited structure.

Then generic theorems can be written once:

```lean
theorem add_left_cancel
    [AddGroup α] {a b c : α}
    (h : a + b = a + c) : b = c := by
  ...
```

The theorem works for every type with a valid `AddGroup` instance.

## The section’s intended message

The authors are building this progression:

```text
overloaded notation
        ↓
type classes
        ↓
automatically synthesized implementations
        ↓
generic functions
        ↓
generic mathematical structures and laws
```

In Rust terms, start by reading Lean classes as traits and instances as `impl`s. Then add one crucial extension:

> A Lean instance may package not only operations, but also proofs that those operations obey laws.

# 4 Monads 

- Active recall always. 
- Express in simple and intuitive words. 
  - What I understand.
  - Why do we need it? 
  - How does it work?


## 4.1 One Api Many Applications 

- Example: Chaining Options with Functions that strips the Option and builds a new Option.
  - The functions bridge the compositions.

```Lean 

match xs[0]? with 
| none => none 
| some v1 => 
  match xs[2]? with 
  | none => none 
  | some v2 => 
    some (v1, v2) 
```

Use a andThen chaining function. 

```Lean 
andThen xs[0]? (fun first => 
   andThen xs[2]? (fun third => 
      some (first, third)))
```

What is andThen? 



## 4.2 The Monad Type Class

Monad is a tool to bind computations embedding diverse content into a type, Monad. 
Monad can be rendered as a gift box that contains a present, another type. 
Monad has an ability to wrap the present into it, and then unwrap to draw the present out, 
and deliver it to a function that polishes the gift, and put it into the same shaped different box. 

In this way, the Monad can establish a pure computational model without side effects that can 
change the state or the shape. This pattern is so general and ubiquitous that category theory
discovered it.  

Codex fixed the above statement as following:
```
A monad is a structure for composing computations whose results are wrapped in a type constructor.

We can picture a monad as a gift box containing a value of another type. A monad provides a way to wrap an ordinary value into the box with pure, and to pass the contained value to a function that produces another box using bind.

The resulting box has the same outer shape, although the type of its contents may be different. For example, an Option Int computation may be connected to a function producing an Option String.

In this way, monads let us represent and sequence computations involving effects such as failure, exceptions, state, logging, or I/O while keeping the code compositional and purely functional at the level of the program’s description.

This recurring and general pattern has a precise formulation in category theory, where the mathematical structure called a monad was studied before its use in functional programming.
```

## 4.3 Example: Arithmetic in Monad 

## 4.4 do-Notation for Monads 

## 4.5 The IO Monad

## 4.6 Additional Conveniences 

## 4.7 Summary 

