# search 

## https://github.com/MathItYT/mathlikeanim-rs

- It is not finished and has very basic functionality. 
- The idea is similar with mine, Rust, typst, and Manim. 

## https://github.com/linebender/vello

- It is a powerful 2D vector rendering engine.
- If I can extend it to render on 3D surfaces, then it can be a complete solution.

# think 

## Typst -> Vello -> 3D Surface 

[ Typst 수식 / 기하 도형 ] 
       │ (2D 벡터 패스 데이터)
       ▼
[ Vello (2D Render Pipeline) ] ──► GPU Compute Shader로 초고속 2D 벡터 라스터화
       │ (Render Target: Offscreen Texture / Storage Image)
       ▼
[ wgpu 3D World Scene ]        ──► Vello가 그린 텍스처를 3D 메쉬(Quad/Mesh)에 바인딩
       │ (Camera Transform: MVP Matrix)
       ▼
[ 3D 무한 캔버스 (Screen) ]    ──► 자유로운 회전, 입체적 깊이감($Z$축), 줌 레벨 표현

## Iced -> Vello 

[ iced UI Engine ] ──(Render Commands)──► [ iced_vello / vello_iced ] ──► [ wgpu Compute Shader ]
(Widget, State, Event)                      (Vello Scene Graph 변환)       (GPU Offscreen/Screen)

## Plan 1 - Rendering 

Step 1: Experiments with Vello and Lyon (Core Analysis)Lyon: 
    Focus on lyon_tessellation::FillTessellator and StrokeTessellator. 
    Inspect how it converts Bézier curves into vertex buffers, and see how easy it is 
    to attach custom vertex attributes like UV coordinates $(u, v)$ for gradients.

    Vello: Study how vello::Renderer dispatches compute pipelines and writes 
    to an offscreen wgpu::Texture. Understand how it manages the scene graph (vello::Scene).
    
Step 2: Simple 3D Renderer for Lyon MeshesSet up a minimal wgpu pipeline using winit for windowing.
    Take Lyon's 2D vertices $(x, y)$, pass them through a wgpu Vertex Shader, and apply 
    a 3D Model-View-Projection (MVP) matrix to position them in 3D space.
    Add a basic Fragment Shader that interpolates vertex UVs to render linear or radial 
    gradients natively on the 3D surface.
    
Step 3: Integrating Vello Compute Shaders on a 3D Surface. 
    The Integration Strategy:Render the Vello scene into a wgpu::TextureView target.
    Pass that texture as a BindGroup sampler into your 3D mesh pipeline.
    Sample the texture in your Fragment Shader mapped onto your 3D geometry.
    The Fallback Strategy: If dynamic texture re-scaling or offscreen binding 
    creates unexpected performance bottlenecks or complexity, seamlessly pivot 
    to your Step 2 Lyon pipeline without losing progress.

### Architecture 

Typst / Vello Layer (2D Vector Cards):

- Each Typst document, math proof, or commentary block is rendered via Vello 
  into its own offscreen wgpu::Texture (a virtual "card" or "canvas").
- Because it is pure Vello, the math notation, text layout, and 2D vector styling 
  remain crisp, anti-aliased, and beautifully formatted.

3D Mesh & Graph Layer (Spatial Engine):

- Your lightweight 3D renderer manages 3D coordinate axes, parametric surfaces, 
  wireframes, vector fields, and 3D curves.
- It treats the offscreen Vello textures as standard 2D materials mapped 
  onto floating 3D quads (billboards, curved panels, or spatial nodes).

Spatial Presentation & Layouts:

- You can arrange your Typst proof cards in 3D space around the 3D surface they describe!
- For instance, a 3D surface plot can sit in the center of your workspace, surrounded 
  by floating Typst cards that explain specific local derivatives, integral boundaries, 
  or proof steps, all linked by 3D connector lines.

This will be a great fun!
