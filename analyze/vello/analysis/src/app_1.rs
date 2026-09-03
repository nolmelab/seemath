//! A minimal windowed Vello application.
//!
//! Run it with: `cargo run --bin app_1`

use std::error::Error;
use std::sync::Arc;

use vello::kurbo::{Affine, BezPath, Circle, RoundedRect, Stroke};
use vello::peniko::{Color, Fill, Gradient};
use vello::util::{RenderContext, RenderSurface};
use vello::wgpu::{self, CurrentSurfaceTexture};
use vello::{AaConfig, RenderParams, Renderer, RendererOptions, Scene};
use winit::application::ApplicationHandler;
use winit::dpi::LogicalSize;
use winit::event::WindowEvent;
use winit::event_loop::{ActiveEventLoop, EventLoop};
use winit::window::{Window, WindowId};

#[cfg(target_os = "linux")]
use winit::platform::x11::EventLoopBuilderExtX11;

enum AppState {
    Suspended(Option<Arc<Window>>),
    Active {
        window: Arc<Window>,
        surface: Box<RenderSurface<'static>>,
        surface_is_valid: bool,
    },
}

struct App {
    context: RenderContext,
    renderers: Vec<Option<Renderer>>,
    scene: Scene,
    state: AppState,
}

impl App {
    fn new() -> Self {
        Self {
            context: RenderContext::new(),
            renderers: Vec::new(),
            scene: Scene::new(),
            state: AppState::Suspended(None),
        }
    }

    fn draw(&mut self) {
        let AppState::Active {
            window,
            surface,
            surface_is_valid,
        } = &mut self.state
        else {
            return;
        };

        if !*surface_is_valid {
            return;
        }

        self.scene.reset();
        build_scene(&mut self.scene);

        let device = &self.context.devices[surface.dev_id];
        self.renderers[surface.dev_id]
            .as_mut()
            .expect("renderer was initialized with the surface")
            .render_to_texture(
                &device.device,
                &device.queue,
                &self.scene,
                &surface.target_view,
                &RenderParams {
                    base_color: Color::new([0.055, 0.065, 0.09, 1.0]),
                    width: surface.config.width,
                    height: surface.config.height,
                    antialiasing_method: AaConfig::Msaa16,
                },
            )
            .expect("Vello failed to render the scene");

        let surface_texture = match surface.surface.get_current_texture() {
            CurrentSurfaceTexture::Success(texture) => texture,
            CurrentSurfaceTexture::Outdated | CurrentSurfaceTexture::Suboptimal(_) => {
                self.context.configure_surface(surface);
                window.request_redraw();
                return;
            }
            CurrentSurfaceTexture::Occluded | CurrentSurfaceTexture::Timeout => {
                window.request_redraw();
                return;
            }
            CurrentSurfaceTexture::Lost => panic!("window surface was lost"),
            CurrentSurfaceTexture::Validation => panic!("window surface validation failed"),
        };

        let mut encoder = device
            .device
            .create_command_encoder(&wgpu::CommandEncoderDescriptor {
                label: Some("Vello surface blit"),
            });
        let destination = surface_texture
            .texture
            .create_view(&wgpu::TextureViewDescriptor::default());
        surface.blitter.copy(
            &device.device,
            &mut encoder,
            &surface.target_view,
            &destination,
        );
        device.queue.submit([encoder.finish()]);
        surface_texture.present();
        device.device.poll(wgpu::PollType::Poll).unwrap();
    }
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        let AppState::Suspended(cached_window) = &mut self.state else {
            return;
        };

        println!("Resuming Vello app");

        let window = cached_window.take().unwrap_or_else(|| {
            let attributes = Window::default_attributes()
                .with_title("Vello minimal feature demo")
                .with_inner_size(LogicalSize::new(800, 600));
            Arc::new(event_loop.create_window(attributes).expect("create window"))
        });

        let size = window.inner_size();
        let surface = pollster::block_on(self.context.create_surface(
            window.clone(),
            size.width,
            size.height,
            wgpu::PresentMode::AutoVsync,
        ))
        .expect("create Vello render surface");

        self.renderers
            .resize_with(self.context.devices.len(), || None);
        self.renderers[surface.dev_id].get_or_insert_with(|| {
            Renderer::new(
                &self.context.devices[surface.dev_id].device,
                RendererOptions::default(),
            )
            .expect("create Vello renderer")
        });

        self.state = AppState::Active {
            window: window.clone(),
            surface: Box::new(surface),
            surface_is_valid: size.width > 0 && size.height > 0,
        };
        window.request_redraw();
    }

    fn suspended(&mut self, _event_loop: &ActiveEventLoop) {
        if let AppState::Active { window, .. } = &self.state {
            self.state = AppState::Suspended(Some(window.clone()));
        }
    }

    fn window_event(
        &mut self,
        event_loop: &ActiveEventLoop,
        window_id: WindowId,
        event: WindowEvent,
    ) {
        let AppState::Active {
            window,
            surface,
            surface_is_valid,
        } = &mut self.state
        else {
            return;
        };
        if window.id() != window_id {
            return;
        }

        match event {
            WindowEvent::CloseRequested => event_loop.exit(),
            WindowEvent::Resized(size) => {
                *surface_is_valid = size.width > 0 && size.height > 0;
                if *surface_is_valid {
                    self.context
                        .resize_surface(surface, size.width, size.height);
                    window.request_redraw();
                }
            }
            WindowEvent::RedrawRequested => self.draw(),
            _ => {}
        }
    }
}

/// Builds a scene showing solid and gradient fills, strokes, Bézier paths,
/// alpha layers, and affine transforms.
fn build_scene(scene: &mut Scene) {
    let card = RoundedRect::new(55.0, 55.0, 745.0, 545.0, 28.0);
    let background = Gradient::new_linear((55.0, 55.0), (745.0, 545.0)).with_stops([
        Color::new([0.10, 0.25, 0.55, 1.0]),
        Color::new([0.48, 0.12, 0.55, 1.0]),
    ]);
    scene.fill(Fill::NonZero, Affine::IDENTITY, &background, None, &card);
    scene.stroke(
        &Stroke::new(3.0),
        Affine::IDENTITY,
        Color::new([0.75, 0.85, 1.0, 0.9]),
        None,
        &card,
    );

    let circle = Circle::new((235.0, 260.0), 105.0);
    let glow = Gradient::new_radial((210.0, 230.0), 130.0).with_stops([
        Color::new([1.0, 0.78, 0.22, 1.0]),
        Color::new([1.0, 0.20, 0.36, 0.9]),
    ]);
    scene.fill(Fill::NonZero, Affine::IDENTITY, &glow, None, &circle);

    let mut wave = BezPath::new();
    wave.move_to((365.0, 205.0));
    wave.curve_to((455.0, 80.0), (570.0, 390.0), (685.0, 205.0));
    wave.curve_to((600.0, 480.0), (455.0, 330.0), (365.0, 410.0));
    wave.close_path();
    scene.fill(
        Fill::NonZero,
        Affine::rotate_about(-0.08, (525.0, 300.0)),
        Color::new([0.25, 0.95, 0.78, 0.82]),
        None,
        &wave,
    );
    scene.stroke(
        &Stroke::new(8.0),
        Affine::IDENTITY,
        Color::new([0.92, 0.98, 1.0, 1.0]),
        None,
        &wave,
    );
}

fn main() -> Result<(), Box<dyn Error>> {
    let mut event_loop_builder = EventLoop::builder();

    // WSLg exposes both Wayland and XWayland. Winit normally prefers Wayland,
    // so select X11 explicitly to use the working XWayland path.
    #[cfg(target_os = "linux")]
    event_loop_builder.with_x11();

    let event_loop = event_loop_builder.build()?;
    event_loop.run_app(&mut App::new())?;
    Ok(())
}
