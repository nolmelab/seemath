# Math Canvas 

Navigate the space of math. 



Yes. That clarifies the project considerably.

The primary product isn't really **a better Lean IDE**, **a Typst editor**, or **a mathematical visualization system**. Those are means toward a more fundamental goal:

> **EulerCanvas is a spatial interface for navigating and searching the mathematical universe, so that you can think and do mathematics in it efficiently.**

That distinction should probably drive the architecture.

### The central abstraction

I'd make **Mathematical Object** the fundamental concept rather than `Document`, `Node`, or `LeanDeclaration`.

A mathematical object might be:

* a definition
* theorem
* proof
* concept
* structure
* notation
* example
* textbook explanation
* diagram
* computation
* animation

and potentially several of these at once.

For example:

```text
                         GROUP
                           │
             ┌─────────────┼─────────────┐
             │             │             │
        Definition      Theorem       Examples
             │             │             │
          Group.mul     Lagrange      Z/2Z
                           │
                           ▼
                         Proof
                           │
                           ▼
                         Lean
```

The **canvas is a view of this graph**, not the graph itself.

That distinction is important because it means you can have the same mathematical object appear in several places without duplicating it.

---

### Search and navigation should be two sides of the same operation

Traditional search is:

> Type something → get a list of documents.

For seemath, I think the ideal interaction is:

> **Search → land in the mathematical neighborhood → navigate from there.**

Suppose you search for *compactness*.

Instead of:

```text
Search results:
1. CompactSpace
2. IsCompact
3. compactness theorem
4. ...
```

EulerCanvas could bring you into a region:

```text
                    Topology
                       │
          ┌────────────┼────────────┐
          │            │            │
     Compactness    Connected    Separation
          │
    ┌─────┼─────┐
    │     │     │
  def   lemmas  theorems
    │
    ▼
 CompactSpace
    │
    ├── Mathlib
    ├── Typst explanation
    └── Lean declarations
```

Now **navigation itself becomes search**.

And conversely, navigating through the graph naturally generates new search contexts.

That could be one of the defining characteristics of seemath.

---

### Semantic zoom becomes essential

Your phrase **"spatial representation"** makes semantic zoom much more important than ordinary canvas zoom.

At one scale:

```text
Topology
```

Zoom in:

```text
Topology
 ├── Open sets
 ├── Closed sets
 ├── Continuity
 ├── Compactness
 └── Connectedness
```

Zoom further:

```text
Compactness
 ├── definition
 ├── equivalent formulations
 ├── important theorems
 ├── examples
 └── counterexamples
```

Zoom further:

```text
IsCompact s
```

Zoom further:

```text
Lean declaration
```

And eventually:

```text
theorem ... := by
    ...
```

So **zoom level determines cognitive granularity**.

That is much more interesting than simply scaling a 2D document.

---

### This also changes what "doing math" means

The ultimate interaction shouldn't be:

> "Open Lean and prove a theorem."

It should be more like:

> "I'm thinking about this mathematical region. Let me move around, recall the definitions, inspect related results, sketch an idea, open a formal theorem, try a proof, and return to the surrounding structure."

In other words, **the canvas becomes your mathematical workspace and memory**.

Lean provides formal rigor.

Typst provides exposition.

Mathlib provides accumulated mathematical knowledge.

Manim eventually provides intuition.

But EulerCanvas provides the **place where your mathematical thought happens**.

That is a much more ambitious idea than an IDE, but also a much clearer one.

And given that your motivation is ultimately *"I want to do mathematics again"*, I think that should remain the architectural north star. Every major design decision can be tested against one question:

> **Does this make it easier for a mathematician to find, understand, remember, connect, and manipulate mathematical ideas?**

If not, it probably doesn't belong in the core of seemath.


# The north star 

**make me do math again.**

Nothing matters other than that. Keep this in mind.
