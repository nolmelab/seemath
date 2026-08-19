# Design of Overall Architecture 

Yes. I’d build this as one shared scene/document engine with four adapters—Vello, Typst, Lean, and animation—rather than four separate subsystems.

```text
Canvas model
├── camera, selection, spatial index
├── document nodes
│   ├── vector objects
│   ├── Typst pages/fragments
│   ├── Lean source editors
│   ├── proof-state panels
│   └── animated mathematical objects
├── timeline/animation system
└── renderer
    ├── Vello 2D passes → textures
    └── wgpu 3D pass → meshes/window
```

## 1. Establish the rendering architecture

Use one shared `wgpu::Device` and `wgpu::Queue` for both Vello and your 3D renderer. Avoid creating separate GPU contexts.

The frame should look roughly like this:

```text
Update input, documents, proofs, animations
                    ↓
Build dirty Vello scenes
                    ↓
Render Vello scenes into GPU textures
                    ↓
Run 3D mesh render pass sampling those textures
                    ↓
Render overlays and editor UI
                    ↓
Present window surface
```

Represent the GPU state separately from application state:

```rust
struct GpuContext {
    device: wgpu::Device,
    queue: wgpu::Queue,
    surface: wgpu::Surface<'static>,
    surface_config: wgpu::SurfaceConfiguration,
}

struct RenderEngine {
    vello_renderer: vello::Renderer,
    mesh_pipeline: wgpu::RenderPipeline,
    texture_bind_group_layout: wgpu::BindGroupLayout,
    depth_texture: GpuTexture,
}
```

Before the project grows, consider upgrading from Vello 0.3 to a newer compatible Vello/wgpu stack. Current Vello documentation is already substantially different from 0.3, so otherwise you will be building new architecture around obsolete APIs. Pin Vello, `vello_svg`, and wgpu-compatible dependencies together. [Vello documentation](https://docs.rs/vello/latest/vello/), [Vello repository](https://github.com/linebender/vello)

## 2. Render a Vello scene into a texture

Create an off-screen texture with at least:

```rust
wgpu::TextureUsages::STORAGE_BINDING
    | wgpu::TextureUsages::TEXTURE_BINDING
    | wgpu::TextureUsages::COPY_SRC
```

Use `Rgba8Unorm`, which Vello requires for its render target:

```rust
let texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width,
        height,
        depth_or_array_layers: 1,
    },
    format: wgpu::TextureFormat::Rgba8Unorm,
    usage: wgpu::TextureUsages::STORAGE_BINDING
        | wgpu::TextureUsages::TEXTURE_BINDING
        | wgpu::TextureUsages::COPY_SRC,
    // ...
});
```

Then render:

```rust
vello_renderer.render_to_texture(
    &device,
    &queue,
    &scene,
    &texture_view,
    &render_params,
)?;
```

Vello explicitly supports rendering a `Scene` into an `Rgba8Unorm` storage texture. [Vello `Renderer::render_to_texture`](https://docs.rs/vello/latest/vello/struct.Renderer.html)

Important details:

- Keep the texture GPU-resident; do not read it back to the CPU.
- Recreate it only when its required resolution changes.
- Use transparent Vello backgrounds when the texture is composited in 3D.
- Define your alpha convention carefully.
- Be explicit about linear versus sRGB color handling.
- Render only dirty content.
- Add padding around mathematical content to avoid clipped antialiasing.

Start with one Vello texture on a simple quad. Only after that works should you generalize it to arbitrary meshes.

## 3. Sample the texture on a 3D mesh

Build a conventional wgpu render pipeline with:

- Vertex position
- Normal, if lighting is needed
- UV coordinates
- Model/view/projection uniforms
- Texture view
- Sampler

The WGSL fragment shader can initially be very simple:

```wgsl
@group(1) @binding(0)
var document_texture: texture_2d<f32>;

@group(1) @binding(1)
var document_sampler: sampler;

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(document_texture, document_sampler, input.uv);
}
```

The texture and sampler are exposed through a `BindGroup`; wgpu binds those resources to a render pass with `set_bind_group`. [wgpu bind groups](https://docs.rs/wgpu/latest/wgpu/struct.BindGroup.html)

Implement this in stages:

1. Static Vello circle on a quad.
2. Camera movement and perspective.
3. Multiple textured objects.
4. Transparent textures.
5. Curved or arbitrary meshes.
6. Picking and interaction.
7. Resolution/LOD selection.

For text on a tilted mesh, texture resolution becomes important. Compute desired resolution from the object’s projected screen size and rerender when it crosses an LOD threshold.

## 4. Build the infinite canvas

Do not make the infinite canvas itself one huge texture. Treat it as a world containing independently renderable objects.

A useful model is:

```rust
struct CanvasNode {
    id: NodeId,
    transform: Transform2D,
    bounds: Rect,
    z_index: i32,
    content: NodeContent,
    dirty: DirtyFlags,
}

enum NodeContent {
    Vector(VectorObject),
    Typst(TypstDocumentId),
    LeanEditor(EditorId),
    Animation(AnimationId),
    Texture(TextureId),
}
```

Add:

- Pan and zoom camera
- World-to-screen transforms
- Stable node identifiers
- Z ordering
- Selection and manipulation
- Spatial indexing
- Dirty-region tracking
- Undo/redo commands

Use an R-tree, quadtree, or spatial hash so only visible nodes are processed. At extreme zoom levels, introduce:

- Bounding-box placeholders
- Cached thumbnails
- Multiple raster resolutions
- Vector rendering only near the viewport
- Texture eviction based on recency and GPU memory budget

Maintain coordinate spaces explicitly:

```text
Document coordinates
    ↓ node transform
Canvas/world coordinates
    ↓ camera
Screen coordinates
    ↓ DPI scale
Physical pixels
```

Mixing these spaces implicitly will cause selection, text positioning, and zoom bugs.

## 5. Render Typst with Vello

Typst compilation has four broad phases: parsing, evaluation, layout, and export. The result of layout contains frames that exporters turn into SVG, PDF, or pixels. Typst’s compilation is incremental, which is important for interactive editing. [Typst architecture](https://github.com/typst/typst/blob/main/docs/dev/architecture.md)

There are two viable integrations.

### First implementation: Typst → SVG → Vello

Use:

```text
Typst source
    ↓ Typst compilation/layout
Typst frame
    ↓ typst-svg
SVG
    ↓ vello_svg
Vello Scene
```

This is the fastest route to a working renderer. Typst officially provides `typst-svg`, while Linebender provides `vello_svg` for converting SVG content to Vello scenes. [Typst workspace crates](https://github.com/typst/typst/blob/main/Cargo.toml), [Vello SVG integration](https://github.com/linebender/vello)

Benefits:

- Relatively little custom rendering code
- Vector output at arbitrary zoom
- Typst already handles mathematical layout
- Easy visual comparison with official Typst output

Costs:

- SVG serialization and parsing overhead
- Harder mapping from displayed geometry back to Typst source
- Some advanced SVG effects may need special handling

Cache the resulting Vello scene per Typst page or fragment. Recompile only when source, dependencies, fonts, or layout constraints change.

### Long-term implementation: Typst frame → Vello directly

Implement a visitor over Typst’s laid-out `Frame` structures:

```text
Typst FrameItem       Vello operation
────────────────────────────────────────
Text                  Scene::draw_glyphs
Shape                 Scene::fill/stroke
Image                 Scene::draw_image
Group                 transform + layer
Clip                  push clip layer
Gradient              Peniko brush
```

This is more work, but gives you:

- Better source-to-geometry mapping
- Precise hit testing
- Lower conversion overhead
- Better control over glyph and image caches
- Semantic selection of formulas and document elements

Do this only after the SVG path proves the product concept.

Typst’s existing raster renderer uses `tiny-skia`, so it is not itself a Vello renderer. [Typst raster renderer](https://github.com/typst/typst/blob/main/crates/typst-render/src/lib.rs)

## 6. Add the text editor before Lean integration

Build a robust general-purpose editor component first. It needs:

- Rope or piece-table text storage
- Multiple cursors and selections
- UTF-8 byte-offset tracking
- UTF-16 position conversion for LSP
- Incremental syntax highlighting
- IME support
- Clipboard support
- Undo/redo
- Scrolling and line virtualization
- Diagnostic decorations
- Hover and completion popups

Keep editor layout independent from Typst document layout. Source code editing and rendered mathematical pages have different requirements.

A useful boundary is:

```rust
trait LanguageService {
    fn open(&mut self, document: DocumentSnapshot);
    fn change(&mut self, changes: Vec<TextChange>);
    fn request_completion(&mut self, position: TextPosition);
    fn request_hover(&mut self, position: TextPosition);
    fn request_definition(&mut self, position: TextPosition);
}
```

This lets the editor work with Lean today and potentially Typst or Rust later.

## 7. Integrate the Lean 4 server through LSP

Do not embed Lean’s elaborator into the GUI initially. Launch Lean as a child process and communicate over JSON-RPC/LSP:

```text
Editor
  ↓ didOpen / didChange / requests
LSP client
  ↓ stdin/stdout
lake serve / lean --server
  ↓
Lean watchdog
  ↓
Per-file Lean workers
```

Lean’s server uses a watchdog plus separate workers for open files, providing isolation if an individual worker fails. [Lean language-server design](https://github.com/leanprover/lean4/blob/master/src/Lean/Server/README.md)

Implement the standard LSP lifecycle first:

1. Start the server in the project root.
2. Send `initialize`.
3. Send `initialized`.
4. Send `textDocument/didOpen`.
5. Send incremental `textDocument/didChange`.
6. Display `publishDiagnostics`.
7. Add hover, completion, definition, and semantic tokens.
8. Send `shutdown`, followed by `exit`.

Lean also exposes custom RPC methods for interactive goal and InfoView functionality. Its protocol includes RPC connection, call, keep-alive, and release operations. [Lean protocol overview](https://github.com/leanprover/lean4/blob/master/src/Lean/Server/ProtocolOverview.lean)

Treat custom goal-state RPC as a later milestone. First prove that:

- Editing sends correct document versions.
- Diagnostics remain synchronized.
- UTF-8/UTF-16 positions are correct.
- Server restarts are handled.
- Stale responses are discarded.

Never block the winit event-loop thread while waiting for Lean. Run the LSP transport on background asynchronous tasks and send typed events back to the UI.

## 8. Connect Lean content to the canvas

Once the editor works, represent proof-related content as linked nodes:

```text
Lean source node
├── diagnostic markers
├── current goal node
├── hypotheses nodes
├── theorem declaration node
└── dependency/concept graph
```

Useful interactions could include:

- Clicking a theorem opens its source.
- Selecting a tactic shows the goal before and after it.
- Dragging a definition onto the canvas creates a reference card.
- Hovering a symbol highlights its uses.
- Proven statements receive a verified-state badge.
- Typst formulas link to Lean declarations through explicit metadata.

Keep the link explicit:

```rust
struct LeanReference {
    project: ProjectId,
    uri: Url,
    range: LspRange,
    declaration_name: Option<String>,
}
```

Source ranges alone become fragile after edits, so eventually supplement them with declaration identities and remapping logic.

## 9. Design the Manim-like engine around retained objects

Do not begin by porting all of Manim. Start with a small retained animation system:

```rust
trait Animatable {
    fn evaluate(&self, time: f64, output: &mut SceneBuilder);
}

struct AnimationClip {
    start: f64,
    duration: f64,
    easing: Easing,
    target: NodeId,
    property: AnimatedProperty,
}
```

Core mathematical objects:

- Points and vectors
- Lines, arrows, and axes
- Curves and parametric paths
- Polygons and geometric constructions
- Graphs and plots
- Typst formula objects
- Groups
- Cameras
- 3D meshes and surfaces

Core animations:

- Create/write
- Fade
- Transform
- Move/rotate/scale
- Color interpolation
- Path following
- Camera animation
- Formula term matching
- Morphing compatible paths

The animation system should evaluate properties at time `t`; it should not directly mutate GPU resources. Each frame:

```text
Timeline evaluates node properties
        ↓
Scene builder creates visible geometry
        ↓
Vello encodes 2D vector content
        ↓
wgpu renders 3D content
```

Vello scenes are command recordings, not a general-purpose mutable scene graph. Preserve your semantic objects separately, then rebuild or append Vello scenes as needed. Also reset retained `Scene` values before rebuilding them, because repeatedly appending without resetting grows scene complexity. [Vello `Scene`](https://docs.rs/vello/latest/vello/struct.Scene.html)

For formula transformations, preserve semantic sub-elements:

```rust
FormulaObject {
    source: String,
    parts: Vec<FormulaPart>,
}

FormulaPart {
    semantic_id: String,
    geometry: VectorGeometry,
}
```

That makes it possible to transform matching symbols rather than cross-fading entire raster images.

## 10. Separate interactive and export rendering

Interactive playback and final video export have different requirements.

Interactive mode:

- Render at display refresh rate.
- Skip frames if evaluation is late.
- Use adaptive texture resolution.
- Cache aggressively.

Export mode:

- Fixed timestep such as exactly 60 FPS.
- Never skip frames.
- Fixed output resolution.
- Deterministic random seeds.
- Render into off-screen textures.
- Copy frames into an encoder pipeline.
- Keep audio and animation time based on timestamps, not wall-clock time.

Design the timeline deterministically from the beginning:

```rust
let time = frame_number as f64 / frames_per_second;
```

This avoids export results differing from interactive playback.

## Suggested implementation sequence

### Milestone 1: GPU composition

- Upgrade and pin the Vello/wgpu stack.
- Render a Vello scene to an off-screen texture.
- Display it on a 3D quad.
- Add depth testing and a movable camera.

### Milestone 2: Infinite canvas

- Add pan, zoom, selection, transforms, and picking.
- Add canvas nodes and spatial indexing.
- Render multiple vector-texture nodes.
- Implement texture caching and LOD.

### Milestone 3: Typst prototype

- Compile one in-memory Typst document.
- Export each page through `typst-svg`.
- Convert SVG into a Vello scene.
- Place pages on the canvas.
- Add incremental recompilation and diagnostics.

### Milestone 4: Lean editor

- Build the text editor.
- Implement an asynchronous JSON-RPC/LSP client.
- Launch Lean through the active Lake project.
- Show diagnostics, hover, completion, and goals.
- Link Lean declarations to canvas objects.

### Milestone 5: Animation core

- Add timeline, easing, transforms, and cameras.
- Animate simple Vello paths.
- Add Typst formula objects.
- Implement formula-part matching and transitions.
- Add deterministic off-screen frame export.

### Milestone 6: Advanced visualization

- Curves, vector fields, graphs, and axes
- 3D surfaces and lighting
- Proof trees and dependency graphs
- Interactive theorem-step visualizations
- Video/audio export
- Plugin or scripting API

## Most important architectural choices

I would make these decisions early:

- One shared wgpu device and queue.
- A semantic retained scene model above Vello.
- Vello textures are caches, not the source of truth.
- Typst → SVG → Vello for the first version.
- Direct Typst-frame rendering only after the product works.
- Lean runs out of process through LSP.
- All compilation and theorem proving happens off the UI thread.
- Canvas coordinates remain independent of pixels.
- Animation is deterministic and time-based.
- GPU textures have explicit memory and resolution policies.

The best first vertical slice is small but representative:

```text
Editable Typst formula
        ↓
Incremental Typst compilation
        ↓
SVG → Vello scene
        ↓
Off-screen GPU texture
        ↓
Texture displayed on a movable 3D quad
```

Once that works, the same architecture naturally supports Lean goal panels and animated mathematical objects.