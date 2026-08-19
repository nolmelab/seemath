# Design the Editor 

Yes. The strongest fit is Floem’s editor, especially `floem-editor-core`.

## Recommendation

For your existing custom winit/Vello application, use:

```toml
floem-editor-core = "0.2"
```

as a headless editing engine, while continuing to render the editor yourself with Vello.

It already provides:

- Rope-backed text storage
- Cursors and multiple selections
- Editing commands
- Undo-related edit classifications
- Word and paragraph movement
- Indentation
- Line-ending handling
- Modal editing concepts
- Bracket matching
- Deltas suitable for incremental syntax highlighting

The full Floem toolkit also includes an actual [`TextEditor`](https://docs.rs/floem/latest/floem/views/text_editor/struct.TextEditor.html) with gutters, wrapping, preedit/IME state, visible-line calculation, styling, and change callbacks. Its core is independently exposed through [`floem-editor-core`](https://docs.rs/floem-editor-core/latest/floem_editor_core/).

## Two integration options

### Option A: Use Floem as the whole UI toolkit

This is the quickest path to a capable editor:

```text
Floem application
├── Floem TextEditor
├── proof-state panels
├── menus and controls
└── custom infinite-canvas View
```

Floem supports wgpu rendering through Vello or Vger, has virtual lists, reactive state, and comes from the Lapce editor ecosystem. [Floem repository](https://github.com/lapce/floem)

Advantages:

- Existing editor widget
- IME/preedit support
- Gutter and visible-line machinery
- Clipboard, focus, keyboard, and pointer handling
- Less UI infrastructure to implement

Disadvantages:

- Floem will want significant control over the event loop and rendering.
- Integrating your own Vello-to-texture and 3D render graph may require a custom Floem renderer/view.
- Floem is still maturing and warns that breaking changes can occur.
- You must align Floem’s winit, Vello, and wgpu versions with yours.

Choose this if you are willing to make Floem the application shell.

### Option B: Use only `floem-editor-core`

This is my preferred choice for your architecture:

```text
Your winit application
├── Your wgpu render graph
├── Your Vello renderer
├── Infinite canvas
└── Editor widget
    ├── floem-editor-core for editing state
    ├── Parley for shaping/layout
    ├── Vello for painting
    └── Your Lean LSP adapter
```

This preserves control over:

- The shared wgpu device and queue
- Off-screen textures
- Canvas transforms
- 3D composition
- Redraw scheduling
- Texture caching
- Lean integration

The tradeoff is that you must implement the visual editor widget around the core.

## Suggested editor stack

I would use:

| Concern | Library/component |
|---|---|
| Editing operations | `floem-editor-core` |
| Text buffer | Its re-exported `lapce_xi_rope` |
| Text shaping/layout | Parley |
| Glyph rendering | Vello `Scene::draw_glyphs` |
| Syntax parsing | Tree-sitter |
| Lean features | Lean LSP over JSON-RPC |
| Protocol types | `lsp-types` |
| Async process handling | Tokio |
| Accessibility | AccessKit |
| Clipboard/window input | winit integration |

Parley is particularly appropriate because it belongs to the same Linebender graphics ecosystem as Vello. Xilem/Masonry already combine winit, wgpu, Vello, Parley, and AccessKit, demonstrating that this stack is intended to work together. [Masonry architecture](https://docs.rs/masonry/latest/masonry/), [Xilem architecture](https://docs.rs/xilem/latest/xilem/)

## Editor rendering architecture

Keep editor state separate from graphical layout:

```rust
struct EditorModel {
    buffer: EditorBuffer,
    selections: Selection,
    revision: u64,
    diagnostics: Vec<Diagnostic>,
    semantic_tokens: Vec<SemanticToken>,
}

struct EditorView {
    scroll: Vec2,
    viewport: Rect,
    line_height: f64,
    cached_lines: HashMap<VisualLineId, CachedLine>,
}
```

For each frame:

1. Determine the visible line range.
2. Shape only dirty or newly visible lines with Parley.
3. Cache their glyph runs.
4. Append visible glyphs to the Vello scene.
5. Draw selection backgrounds.
6. Draw diagnostics and semantic highlighting.
7. Draw carets and IME preedit decorations.
8. Render the scene into a texture or directly into the canvas scene.

Do not create one texture for the entire source file. Either render visible lines directly into the window scene or maintain a viewport-sized editor texture.

## Lean integration boundary

The editor should not know Lean-specific details. Introduce a service interface:

```rust
trait LanguageService {
    fn did_open(&mut self, document: DocumentSnapshot);
    fn did_change(&mut self, revision: u64, edits: &[TextEdit]);
    fn completion(&mut self, position: TextPosition);
    fn hover(&mut self, position: TextPosition);
    fn goto_definition(&mut self, position: TextPosition);
    fn goals(&mut self, position: TextPosition);
}
```

The `floem-editor-core` delta callback can produce changes for:

```text
textDocument/didChange
```

Be careful with coordinate systems:

- Editor buffer: usually UTF-8 byte or scalar offsets
- Tree-sitter: byte offsets and row/column points
- Lean LSP: negotiated position encoding, traditionally UTF-16
- Vello/Parley: glyph positions in layout coordinates

Create one tested `PositionMapper` responsible for all conversions. This is a high-risk area for Lean source containing Unicode mathematical symbols.

## Why not use the other obvious options?

### Masonry/Xilem `TextArea`

Masonry’s `TextArea` has selection, clipboard, text events, accessibility, and IME support, and paints directly into a Vello `Scene`. That makes it an excellent multiline text-input foundation. However, it is not yet a complete code editor: you would still need large-file virtualization, gutters, code navigation, multiple cursors, syntax integration, folding, and editor commands. [Masonry `TextArea`](https://docs.rs/masonry/latest/masonry/widgets/struct.TextArea.html)

It is attractive if you decide to adopt Xilem/Masonry for all UI, but less complete than Floem’s editor machinery.

### Helix crates

Helix exposes useful internal crates such as `helix-core`, `helix-lsp`, and `helix-lsp-types`. Its editing core is powerful and well-tested, but it is designed around Helix’s modal editor model and terminal application architecture. Embedding it into a graphical Vello widget would require substantial adaptation. [Helix repository](https://github.com/helix-editor/helix)

It is worth studying for selection and LSP design, but I would not use it as your initial embedded widget.

### Zed/GPUI

Zed contains a production-quality graphical editor, but its editor is deeply integrated with GPUI and Zed’s application models. GPUI exposes text-input primitives, but adopting Zed’s editor is closer to adopting or extracting a large framework than adding a library. Its input example alone implements substantial selection, Unicode boundary, IME, and layout machinery. [GPUI text-input example](https://github.com/zed-industries/zed/blob/main/crates/gpui/examples/input.rs)

### Building everything from `Ropey`

A rope solves text storage, not editing. You would still need selection behavior, Unicode navigation, undo grouping, IME, layout, hit testing, scrolling, and clipboard integration. `floem-editor-core` gives you a much better starting layer.

## Practical path

I suggest this sequence:

1. Prototype the full Floem `TextEditor` in a separate small executable.
2. Test Unicode Lean code, IME, large files, selections, and change deltas.
3. Prototype `floem-editor-core` in your existing winit/Vello app.
4. Render ten visible lines using Parley and Vello.
5. Add caret, selection, scrolling, and hit testing.
6. Connect edit deltas to a mock LSP service.
7. Replace the mock service with `lake serve`.
8. Add diagnostics and proof goals.
9. Decide whether to retain the custom view or adopt more of Floem.

The key decision is:

- Choose full Floem if editor productivity is more important than total render-loop control.
- Choose `floem-editor-core` plus a custom Vello view if the infinite canvas and 3D composition are the center of the product.

For your stated platform, I would choose the second approach.