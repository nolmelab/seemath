# step 1. analyze and experiment 

## Goal

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

## Plan 

- Understand Vello. 
- Render Vello 2d graphics on 3d surfaces.

