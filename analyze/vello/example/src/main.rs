use std::sync::Arc;

use vello::{
    kurbo::{Affine, Circle},
    peniko::{Color, Fill},
    util::{RenderContext, RenderSurface},
    wgpu, AaConfig, RenderParams, Renderer, RendererOptions, Scene,
};
use winit::{
    application::ApplicationHandler,
    event::WindowEvent,
    event_loop::{ActiveEventLoop, ControlFlow, EventLoop},
    window::{Window, WindowId},
};

/// Holds state for our Vello + Winit application
struct App {
    // RenderContext manages wgpu Instance, Adapter, and Device initialization
    context: RenderContext,
    // Vello renderers (one per GPU device)
    renderers: Vec<Option<Renderer>>,
    // Vello helper struct wrapping the surface, swapchain, and target texture
    surface: Option<RenderSurface<'static>>,
    window: Option<Arc<Window>>,
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_none() {
            // 1. Create a winit Window
            let window_attr = Window::default_attributes()
                .with_title("Vello + Winit Minimal Canvas")
                .with_inner_size(winit::dpi::LogicalSize::new(800.0, 600.0));

            let window = Arc::new(event_loop.create_window(window_attr).unwrap());

            let size = window.inner_size();

            // 2. Create a Vello RenderSurface bound to the Window
            let surface_future = self.context.create_surface(
                window.clone(),
                size.width,
                size.height,
                wgpu::PresentMode::AutoNoVsync,
            );

            let surface = pollster::block_on(surface_future).expect("Error creating surface");

            self.renderers
                .resize_with(self.context.devices.len(), || None);
            self.surface = Some(surface);
            window.request_redraw();
            self.window = Some(window);
        }
    }

    fn window_event(
        &mut self,
        event_loop: &ActiveEventLoop,
        _window_id: WindowId,
        event: WindowEvent,
    ) {
        match event {
            WindowEvent::CloseRequested => {
                event_loop.exit();
            }
            WindowEvent::Resized(size) => {
                if let (Some(surface), Some(window)) = (&mut self.surface, &self.window) {
                    if size.width > 0 && size.height > 0 {
                        self.context
                            .resize_surface(surface, size.width, size.height);
                        window.request_redraw();
                    }
                }
            }
            WindowEvent::RedrawRequested => {
                let (Some(surface), Some(window)) = (&mut self.surface, &self.window) else {
                    return;
                };

                let device_handle = &self.context.devices[surface.dev_id];

                // 1. Get or initialize the Vello Renderer for this GPU device
                let renderer = self.renderers[surface.dev_id].get_or_insert_with(|| {
                    Renderer::new(
                        &device_handle.device,
                        RendererOptions {
                            surface_format: Some(surface.format),
                            use_cpu: false,
                            antialiasing_support: vello::AaSupport::all(),
                            num_init_threads: None,
                        },
                    )
                    .expect("Failed to create Vello renderer")
                });

                // 2. Obtain the next surface texture from the OS window swapchain
                let surface_texture = match surface.surface.get_current_texture() {
                    Ok(texture) => texture,
                    Err(wgpu::SurfaceError::Outdated | wgpu::SurfaceError::Lost) => {
                        self.context.resize_surface(
                            surface,
                            surface.config.width,
                            surface.config.height,
                        );
                        window.request_redraw();
                        return;
                    }
                    Err(wgpu::SurfaceError::Timeout) => {
                        window.request_redraw();
                        return;
                    }
                    Err(wgpu::SurfaceError::OutOfMemory) => {
                        eprintln!("The GPU ran out of memory; exiting");
                        event_loop.exit();
                        return;
                    }
                };

                // 3. Build the Vello Vector Scene
                let mut scene = Scene::new();

                // Draw a vibrant mint-green circle in the canvas center
                let circle = Circle::new((400.0, 300.0), 120.0);
                scene.fill(
                    Fill::NonZero,
                    Affine::IDENTITY,
                    Color::rgb8(0, 255, 170),
                    None,
                    &circle,
                );

                // 4. Render Scene into Vello's internal RGBA target texture
                let width = surface.config.width;
                let height = surface.config.height;

                let render_params = RenderParams {
                    base_color: Color::rgb8(20, 20, 25), // Background color
                    width,
                    height,
                    antialiasing_method: AaConfig::Area,
                };

                renderer
                    .render_to_surface(
                        &device_handle.device,
                        &device_handle.queue,
                        &scene,
                        &surface_texture,
                        &render_params,
                    )
                    .expect("Failed to render Vello scene to target texture");

                // Present the rendered frame.
                surface_texture.present();
            }
            _ => {}
        }
    }
}

fn main() {
    let mut event_loop_builder = EventLoop::builder();

    // WSLg's Wayland connection can be reset while wgpu is presenting. WSLg
    // also provides XWayland, which is more reliable for this render path.
    #[cfg(target_os = "linux")]
    if std::env::var_os("WSL_DISTRO_NAME").is_some() {
        use winit::platform::x11::EventLoopBuilderExtX11;
        event_loop_builder.with_x11();
    }

    let event_loop = event_loop_builder
        .build()
        .expect("Failed to create event loop");
    // The scene is static, so wait for window events instead of continuously
    // submitting frames. This is also friendlier to remote compositors such as WSLg.
    event_loop.set_control_flow(ControlFlow::Poll);

    let mut app = App {
        context: RenderContext::new(),
        renderers: vec![],
        surface: None,
        window: None,
    };

    if let Err(error) = event_loop.run_app(&mut app) {
        eprintln!("Window event loop stopped: {error}");
    }
}
