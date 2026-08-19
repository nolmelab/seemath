# step 3 - gui investigation 

- Xilem & Masonry 

# Xilem 

https://raphlinus.github.io/rust/gui/2022/05/07/ui-architecture.html


# Discussion w/ the Codex of Copilot

Yes, but I would not treat the entire infinite canvas as a transformed Xilem widget tree.

The practical architecture is:

```text
Xilem/Masonry
├── application chrome
│   ├── toolbar
│   ├── inspector
│   ├── search
│   └── proof panel
├── InfiniteCanvasWidget
│   └── custom semantic scene rendered with Vello
└── interactive overlay
    └── editor/widgets for the currently active canvas object
```

Xilem can host the infinite canvas, but the canvas should have its own scene graph, culling, hit testing and level-of-detail system.

## What Xilem can do easily

A custom Masonry widget receives a mutable Vello `Scene` in its `paint` method:

```rust
fn paint(
    &mut self,
    ctx: &mut PaintCtx<'_>,
    props: &PropertiesRef<'_>,
    scene: &mut vello::Scene,
) {
    // Append visible canvas objects here.
}
```

Masonry’s painting API exposes transforms, clipping, text contexts and the output Vello scene. [Masonry `PaintCtx`](https://docs.rs/masonry/latest/masonry/core/struct.PaintCtx.html)

Your widget can therefore:

- Receive mouse and keyboard events
- Track pan and zoom
- Cull invisible nodes
- Render visible shapes and text into Vello
- Handle canvas-specific hit testing
- Paint selection and hover overlays
- Request redraws when animations change

This is a good use of Xilem.

## What Xilem does not provide directly

Xilem does not currently provide a general facility like:

```rust
let texture = xilem.render_subtree_to_texture(widget_tree);
```

Its normal model is to paint the widget hierarchy into the window’s Vello scene.

In particular, Xilem’s image widget currently says that GPU-resident wgpu textures are not supported directly. [Xilem image implementation](https://docs.rs/xilem/latest/src/xilem/view/image.rs.html)

Therefore, these are not currently turnkey operations:

- Render an arbitrary Xilem subtree to a wgpu texture
- Place that texture on a 3D mesh
- Transform arbitrary interactive widgets through canvas coordinates
- Automatically transform pointer, IME and accessibility behavior along with them
- Efficiently instantiate thousands of live widget subtrees

You could implement these features by extending Masonry’s renderer, but that would be framework-level work.

## Why scaling the widget tree is problematic

Suppose a Lean editor is a normal Xilem widget and you apply a 0.01 scale transform to show an entire theory.

Its visual output may scale, but several other systems must agree with that transform:

- Layout constraints
- Pointer hit testing
- Scroll offsets
- Caret coordinates
- IME candidate-window position
- Text selection
- Focus routing
- Accessibility bounds
- Popup placement
- Font rasterization
- Pixel-sized borders and cursors

At extreme zoom, the editor is technically visible but unusable. A one-pixel caret becomes 0.01 pixels wide, text becomes visual noise, and laying out every line is wasted work.

This is why an infinite canvas needs semantic zoom, not merely geometric scaling.

## Recommended node model

Keep canvas objects outside the Xilem widget tree:

```rust
struct CanvasNode {
    id: NodeId,
    position: DVec2,
    size: DVec2,
    z_index: i32,
    content: CanvasContent,
    presentation: PresentationState,
}

enum CanvasContent {
    TypstDocument(TypstDocumentId),
    LeanModule(LeanDocumentId),
    Theorem(TheoremId),
    ProofState(ProofStateId),
    Diagram(DiagramId),
    Animation(AnimationId),
    Mesh(MeshId),
}
```

The infinite-canvas widget owns:

```rust
struct CanvasState {
    camera: Camera2D,
    nodes: SlotMap<NodeId, CanvasNode>,
    spatial_index: SpatialIndex,
    selection: HashSet<NodeId>,
    hovered: Option<NodeId>,
    active_editor: Option<NodeId>,
}
```

## Camera transform

Use an explicit camera:

```rust
struct Camera2D {
    center: DVec2,
    zoom: f64,
}
```

Convert between spaces:

```rust
fn world_to_screen(camera: &Camera2D, viewport: Vec2) -> Affine;
fn screen_to_world(camera: &Camera2D, viewport: Vec2) -> Affine;
```

Rendering uses:

```text
node-local → world → screen
```

Input uses the inverse:

```text
screen → world → node-local
```

For example:

```rust
let world_point = screen_to_world * pointer_position;
let candidates = spatial_index.query_point(world_point);
```

Keep world positions in `f64`. For extremely large canvas coordinates, render relative to the camera origin:

```rust
let relative_position = node.position - camera.center;
```

This prevents loss of precision as the canvas grows.

## Cull before building the Vello scene

Do not append every theory node and expect the GPU to discard it.

Compute the visible world rectangle:

```rust
let visible_world = camera.visible_world_rect(viewport_size);
let visible_nodes = spatial_index.query(visible_world);
```

Then build only visible representations:

```rust
for node in visible_nodes {
    let lod = choose_lod(node, camera.zoom);

    match lod {
        Lod::Hidden => {}
        Lod::Overview => paint_overview(node, scene),
        Lod::Summary => paint_summary(node, scene),
        Lod::Detailed => paint_detailed(node, scene),
        Lod::Interactive => paint_interactive(node, scene),
    }
}
```

Use an R-tree or quadtree for spatial lookup.

## Semantic zoom levels

A mathematical theory is a good match for semantic zoom:

| Zoom level | Representation |
|---|---|
| Extremely far | Major domains and dependency clusters |
| Far | Modules, namespaces and major theories |
| Medium | Theorem cards and dependency edges |
| Near | Statements rendered with Typst |
| Very near | Proof summaries and metadata |
| Editing | Lean source editor, goals and diagnostics |

For example:

```rust
fn choose_lod(node: &CanvasNode, zoom: f64) -> Lod {
    let screen_width = node.size.x * zoom;

    match screen_width {
        width if width < 2.0 => Lod::Hidden,
        width if width < 30.0 => Lod::Overview,
        width if width < 150.0 => Lod::Summary,
        width if width < 600.0 => Lod::Detailed,
        _ => Lod::Interactive,
    }
}
```

The thresholds should be based on projected screen size, not raw camera zoom.

At overview scale, a theorem should become a colored rectangle or point. Rendering its full Typst statement at 0.5 pixels tall has no value.

## Use cached Vello scenes carefully

Each node can cache its vector representation:

```rust
struct NodeRenderCache {
    overview: Option<vello::Scene>,
    summary: Option<vello::Scene>,
    detailed: Option<vello::Scene>,
    revision: u64,
}
```

Visible child scenes can be appended with a camera/node transform:

```rust
frame_scene.append(&node_scene, Some(camera_transform * node_transform));
```

Vello supports applying a transform while appending a child scene. However, the operation is documented as O(N), so culling and LOD selection must happen first. [Vello `Scene::append`](https://docs.rs/vello/latest/vello/struct.Scene.html)

For static Typst content:

- Compile only after source changes.
- Cache the resulting node scene.
- Append it only when visible.
- Select a simpler scene at low zoom.

## Handling editors on the canvas

There are three possible approaches.

### 1. Overlay editor — recommended

When the user activates a Lean node:

1. Draw the inactive node using Vello.
2. Calculate its screen-space rectangle.
3. Place a normal Xilem/Masonry editor above the canvas.
4. Keep the editor at a usable UI scale.
5. Commit its changes back to the canvas document.

```text
Canvas node at any zoom
          ↓ activate
Normal screen-space editor overlay
          ↓ close/zoom away
Cached Vello representation
```

Advantages:

- Correct IME behavior
- Normal focus and accessibility
- Sharp text
- Conventional cursor sizes
- No transformed popup problems
- Only one or a few live editors

The editor can visually align with the node without inheriting every part of its world-space transform.

### 2. Custom canvas-native editor

Render the editor entirely inside `InfiniteCanvasWidget` using `floem-editor-core`, Parley and Vello.

This gives precise zoom behavior but makes you responsible for:

- Input
- Selection
- IME
- Clipboard
- Accessibility
- Hit testing
- Scrolling
- Popup placement

This is valid when embedded editing is central to the product, but it is significantly more work.

### 3. Transform arbitrary Xilem widget subtrees

This is the least attractive option. It would require extending or deeply integrating with Masonry’s layout, composition, painting, hit testing and accessibility machinery.

I would avoid making this a foundational requirement.

## Typst content behaves better than editor widgets

Typst documents are naturally suited to the canvas because they can become vector scenes:

```text
Typst source
    ↓ compile/layout
Typst frame or SVG
    ↓
Cached Vello scene
    ↓ affine transform
Canvas frame scene
```

They remain sharp while zooming and do not need widget-level interaction at every scale.

For selection, annotations or links, retain semantic geometry alongside the Vello scene:

```rust
struct TypstCanvasObject {
    scene: vello::Scene,
    bounds: Rect,
    regions: Vec<InteractiveRegion>,
}
```

The Vello scene is only the visual representation; `regions` provide hit testing and semantic interaction.

## Theory visualization should not be document visualization alone

Viewing an entire theory requires a second representation beyond pages and source files.

Represent mathematical relationships as a graph:

```rust
struct TheoryGraph {
    nodes: Vec<TheoryEntity>,
    edges: Vec<TheoryRelation>,
}

enum TheoryEntity {
    Definition,
    Theorem,
    Lemma,
    Structure,
    Type,
    Namespace,
    Module,
}

enum TheoryRelation {
    DependsOn,
    Uses,
    Proves,
    Generalizes,
    Specializes,
    EquivalentTo,
}
```

At distant zoom, render this graph rather than miniature documents. At close zoom, graph nodes expand into theorem cards, Typst statements and Lean editors.

That makes “view the whole theory” meaningful rather than showing thousands of unreadable pages.

## Where 3D fits

Keep 3D rendering as a separate render pass:

```text
Vello canvas pass → 2D canvas texture
Vello node pass   → selected document textures
wgpu 3D pass      → textured meshes
Xilem pass        → UI overlays
```

The challenging part is that Xilem/Masonry normally controls its Vello rendering. Integrating a custom wgpu 3D pass may require:

- A custom Masonry/winit backend
- A rendering hook before presentation
- Or rendering 3D separately into an image that Xilem can display

Because Xilem’s stock image widget does not currently accept GPU-resident textures, a zero-copy 3D/Xilem integration will probably require framework-level extension. That is a more significant constraint than infinite-canvas zoom itself.

## Recommended implementation path

1. Create an `InfiniteCanvasWidget` as a custom Masonry widget.
2. Draw several thousand colored rectangles with camera transforms.
3. Add inverse-transform hit testing.
4. Add a spatial index and viewport culling.
5. Add semantic zoom representations.
6. Add cached Typst/Vello scenes.
7. Add dependency edges and theory clustering.
8. Add a normal screen-space editor overlay.
9. Add Lean diagnostics and goal panels.
10. Only then investigate custom wgpu render passes and 3D textures.

Approximate effort:

| Capability | Rough effort |
|---|---:|
| Basic pan/zoom canvas widget | Several days |
| Culling, selection and spatial index | 1–2 weeks |
| Semantic zoom and node caches | 2–4 weeks |
| Typst vector nodes | 1–3 weeks |
| Screen-space editor overlay | 1–3 weeks |
| Fully transformed interactive widgets | Potentially months |
| Custom Xilem + 3D render integration | Several weeks or more |

So the answer is: Xilem can effectively host and render an infinite canvas, provided the canvas is one specialized widget. Rendering a general Xilem UI tree “inside” world space is technically possible only with substantial custom framework work and is not the architecture I recommend.


## Experiments 

- Xilem GUI rendering 
  - Understand the overall flow 
  - Widget development 
- EulerCanvas
  - Canvas for math 
  - Render Vello scenes inside the canvas.
  - Canvas manages Nodes. Node types are Typst, Lean, and Manim.
  - Nodes have dependencies. 
    - Mathlib visualization can be done automatically. 
    - Typst can be used to explain Mathlib nodes (Theorem, Definition, Lemma, and so on).   
  - Semantic zoom is essential.
- LeanEditorCanvas
  - Xilem widget
  - Place properly considering the focus of EulerCanvas 
- ManimEditorCanvas 
  - Edit the animation script. 
     

