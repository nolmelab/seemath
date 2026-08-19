= plan finalized

That is a coherent choice. It is ambitious, but the components reinforce one another:

- Xilem/Masonry provides the application shell, input, accessibility, and overlay UI.
- Vello provides a shared vector rendering vocabulary.
- Typst provides mathematical typesetting and potentially the authoring language.
- Lean provides formal semantics and verification.
- The animation engine operates on the same semantic canvas objects.
- Rust keeps the model, compiler integrations, and renderer in one ecosystem.

The key is to avoid building the whole vision simultaneously.

## Recommended system boundary

```text
Application model
├── project/workspace
├── infinite canvas
├── document graph
├── animation timeline
└── source references
        │
        ├── Typst service
        ├── Lean service
        └── persistence
        │
Rendering model
├── semantic canvas nodes
├── cached Vello scenes
├── off-screen textures
└── 3D meshes
        │
Xilem/Masonry shell
├── toolbar and panels
├── editor overlay
├── inspector
└── accessibility
```

Keep the application model independent of Xilem, Vello, Typst, and Lean-specific runtime objects wherever practical. That will help with testing, serialization, background processing, and future API changes.

## Build one vertical slice first

Your first meaningful prototype should do exactly this:

1. Show an infinite canvas.
2. Create a node containing Typst source.
3. Compile the source.
4. Render it as a Vello scene.
5. Pan and zoom around it.
6. Double-click it to open a Xilem editor overlay.
7. Edit the source and update the rendered node.

That small slice validates nearly every major architectural boundary without requiring Lean, 3D, or animation.

A second slice can add:

1. A Lean source node.
2. An editor overlay.
3. A Lean server process.
4. Diagnostics.
5. The proof goal at the cursor.
6. A link between a Typst statement and Lean declaration.

Only then begin animation.

## Suggested workspace

```text
crates/
├── app
│   └── Xilem application and composition
├── model
│   └── canvas, nodes, IDs, commands, persistence
├── canvas
│   └── camera, culling, picking, semantic zoom
├── renderer
│   └── Vello scenes, textures and GPU resources
├── typst-engine
│   └── compilation, fonts and Vello conversion
├── editor
│   └── Masonry widget and floem-editor-core bridge
├── lean-client
│   └── process management and LSP/RPC
├── animation
│   └── timeline, interpolation and scene evaluation
├── geometry
│   └── reusable mathematical geometry
└── export
    └── deterministic frame and video rendering
```

Do not create all these crates immediately. Start with `app`, `model`, `canvas`, and `typst-engine`, then split more code only when boundaries become real.

## Preserve semantic objects

Vello scenes and textures should be caches, never the canonical document:

```rust
struct DocumentNode {
    id: NodeId,
    transform: Transform2D,
    content: NodeContent,
    revision: Revision,
}

enum NodeContent {
    Typst(TypstSource),
    Lean(LeanSourceReference),
    Diagram(Diagram),
    Animation(AnimationScene),
}
```

Derived data can be discarded and regenerated:

```rust
struct RenderCache {
    source_revision: Revision,
    overview: Option<vello::Scene>,
    detailed: Option<vello::Scene>,
    texture: Option<GpuTexture>,
}
```

This separation will be especially important when Typst or Vello changes APIs.

## Treat Typst as two things

Typst can serve two distinct roles:

1. Mathematical typesetting
2. Animation scripting

Keep these roles separate internally.

For typesetting:

```typst
$ integral_0^1 x^2 dif x = 1/3 $
```

For animation scripting, define a library rather than modifying the Typst compiler:

```typst
#let scene = animation.scene(
  duration: 4s,
  objects: (
    animation.formula(
      id: "equation",
      content: $a^2 + b^2 = c^2$,
    ),
  ),
  tracks: (
    animation.fade-in("equation", from: 0s, to: 1s),
    animation.move("equation", to: (200pt, 100pt)),
  ),
)
```

Typst evaluates this into structured content. Your Rust side should extract a serializable animation description, then evaluate it independently.

Avoid tying animation playback directly to Typst evaluation. Compile the script once into:

```rust
struct AnimationDocument {
    duration: Time,
    objects: Vec<AnimationObject>,
    tracks: Vec<Track>,
}
```

Playback then remains fast and deterministic.

## Do not literally port all of Manim

Start by reproducing its conceptual model:

- Mathematical objects
- Groups
- Cameras
- Timelines
- Transforms
- Easing
- Create/write/fade animations
- Formula matching
- Deterministic export

Implement only the objects needed by real examples. Porting Manim’s entire Python API and behavior would become its own multi-year project.

A good initial target is enough functionality to reproduce:

- A geometric proof
- Function plotting
- A linear transformation
- A sequence of algebraic formula transformations
- A Lean proof-state animation

## Protect the UI thread

Typst compilation, Lean communication, graph layout, indexing, and export must stay away from the event-loop thread.

Use a message-based model:

```text
UI thread
    │ request with revision
    ▼
Worker/service
    │ result with revision
    ▼
UI accepts result only if revision is current
```

For example:

```rust
enum WorkerRequest {
    CompileTypst {
        node: NodeId,
        revision: Revision,
        source: Arc<str>,
    },
}

enum WorkerResult {
    TypstCompiled {
        node: NodeId,
        revision: Revision,
        output: CompiledTypst,
    },
}
```

The revision check prevents an old compilation result from replacing newer edits.

## Plan for API churn

Xilem and Vello are still evolving. Isolate them behind narrow adapters:

```rust
trait VectorSceneBuilder {
    fn fill_path(&mut self, path: &Path, style: &FillStyle);
    fn stroke_path(&mut self, path: &Path, style: &StrokeStyle);
    fn draw_glyphs(&mut self, run: &GlyphRun);
    fn draw_image(&mut self, image: ImageId, transform: Affine);
}
```

Do not expose `vello::Scene` throughout the entire model. Similarly, keep Xilem widget types in the application/view layer.

Pin dependency versions and upgrade intentionally rather than continually tracking Git revisions.

## Define success in stages

A sensible progression is:

1. Infinite canvas with basic vector nodes.
2. Editable Typst nodes.
3. Persistence, undo/redo, and semantic zoom.
4. Lean editor with diagnostics.
5. Lean goals and source navigation.
6. Animation timeline with basic mathematical objects.
7. Typst-based animation descriptions.
8. Off-screen rendering and deterministic export.
9. 3D surfaces and texture composition.
10. Theory-scale graph visualization.
11. Performance, accessibility, and polish.

Each stage should produce an application you can use, not just infrastructure for the next stage.

The project is large, but it has a strong unifying idea: mathematical content should be editable, typeset, formally connected, spatially organized, and animatable within one semantic model. Keep that model at the center, and let Xilem, Vello, Typst, and Lean remain replaceable adapters around it.