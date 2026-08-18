# render typst documents 

[ Typst Markup ] ──► [ Typst Compiler ] ──► [ Typst Layout Frame ]
                                                    │
                                                    ▼ (Iterate Items)
                                         [ Vello Scene Builder ]
                                         (Path / Text / Fill / Stroke)
                                                    │
                                                    ▼
                                         [ Vello Compute Shader ]
                                                    │
                                                    ▼
                                         [ Offscreen wgpu::Texture ]

## Details from Gemini 

That is a very sharp realization. The **Typst SVG export pipeline** provides the ideal blueprint for rendering Typst content with Vello.

Typst's internal pipeline compiles markup into a structured **Frame layout**, which can then be serialized into standard 2D vector drawing operations. Rather than outputting SVG text or converting curves on the CPU, you can intercept those drawing commands and feed them directly into Vello's high-performance 2D scene graph.

---

### The Typst-to-Vello Pipeline

```
 [ Typst Markup ] ──► [ Typst Compiler ] ──► [ Typst Layout Frame ]
                                                    │
                                                    ▼ (Iterate Items)
                                         [ Vello Scene Builder ]
                                         (Path / Text / Fill / Stroke)
                                                    │
                                                    ▼
                                         [ Vello Compute Shader ]
                                                    │
                                                    ▼
                                         [ Offscreen wgpu::Texture ]

```

---

### How the Mapping Works

Typst’s `typst::layout::Frame` consists of lightweight items that map 1-to-1 onto Vello primitives:

1. **Vector Paths & Geometries (`FrameItem::Path`):**
* Typst stores paths as Bézier curves and lines (`typst::visualize::Path`).
* You convert these directly into Vello's curve representation (`vello::kurbo::BezPath`) and add them to the `vello::Scene` using fills or strokes.


2. **Text & Mathematical Symbols (`FrameItem::Text`):**
* **Option A (Outlines):** Typst can convert text glyphs directly to vector paths (`typst-svg` style). You feed these path outlines 
  straight into Vello. This avoids managing font atlas textures while preserving perfect resolution independence.
* **Option B (Vello Glyphs):** Extract the glyph ID, font data, and transformation matrix, then draw them using Vello’s 
   native text and font rendering utilities.


3. **Gradients, Fills & Transforms (`FrameItem::Group`):**
* Typst handles transforms (scale, rotation, translation) via affine transformation matrices (`typst::foundation::Transform`).
* Vello natively supports pushing/popping affine transformations (`vello::Scene::push_transform`) and applying linear/radial gradient fills.



---

### Why Intercepting the Layout Frame Beats Converting SVG Strings

* **Zero String Parsing Overhead:** Converting Typst $\to$ SVG String $\to$ XML Parser $\to$ Vello incurs unnecessary CPU overhead. Translating Typst's in-memory `Frame` directly to `vello::Scene` bypasses text serialization completely.
* **Exact Layout Precision:** Typst calculates sub-pixel mathematical typesetting layouts (e.g., fraction bars, exponents, matrices) with extreme accuracy. Intercepting the `Frame` preserves every coordinate without precision loss.
* **Fast Re-rendering:** When text or parameters change, Typst re-layouts the document incrementally, and you push the updated frame straight to Vello's compute shaders.

---

### Implementation Reference Projects

When implementing this, you can look at these open-source Rust crates for exact code patterns:

* **`typst-svg` (official Typst codebase):** Inspect how `typst-svg` iterates through `FrameItem`s to draw paths and text.
* **`typst-as-lib` / `mathlikeanim-rs`:** Examples of wrapping Typst as a native Rust library and extracting vector geometries.

This approach gives you a clean, zero-copy pipeline for converting mathematical formulas into crisp offscreen GPU textures!