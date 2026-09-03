//! A minimal windowed Vello application.
//!
//! Run it with: `cargo run --bin app_2`

use std::error::Error;
use std::sync::Arc;

use vello::kurbo::{Affine, BezPath, Circle, RoundedRect, Stroke};
use vello::peniko::{Color, Fill, Gradient};
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
        surface: wgpu::Surface<'static>,
        config: wgpu::SurfaceConfiguration,
        target_texture: wgpu::Texture,
        target_view: wgpu::TextureView,
        blitter: wgpu::util::TextureBlitter,
        surface_is_valid: bool,
    },
}

struct App {
    instance: wgpu::Instance,
    adapter: Option<wgpu::Adapter>,
    device: Option<wgpu::Device>,
    queue: Option<wgpu::Queue>,
    renderers: Option<Renderer>,
    scene: Scene,
    state: AppState,
}

impl App {
    fn new() -> Self {
        Self {
            instance: wgpu::Instance::new(
                wgpu::InstanceDescriptor::new_without_display_handle_from_env(),
            ),
            adapter: None,
            device: None,
            queue: None,
            renderers: None,
            scene: Scene::new(),
            state: AppState::Suspended(None),
        }
    }

    fn draw(&mut self) {
        let AppState::Active {
            window,
            surface,
            config,
            target_view,
            blitter,
            surface_is_valid,
            ..
        } = &mut self.state
        else {
            return;
        };

        if !*surface_is_valid {
            return;
        }

        self.scene.reset();
        build_scene(&mut self.scene);

        let device = self.device.as_ref().expect("device initialized");
        let queue = self.queue.as_ref().expect("queue initialized");
        self.renderers
            .as_mut()
            .expect("renderer initialized")
            .render_to_texture(
                device,
                queue,
                &self.scene,
                target_view,
                &RenderParams {
                    base_color: Color::new([0.055, 0.065, 0.09, 1.0]),
                    width: config.width,
                    height: config.height,
                    antialiasing_method: AaConfig::Msaa16,
                },
            )
            .expect("Vello failed to render the scene");

        let surface_texture = match surface.get_current_texture() {
            CurrentSurfaceTexture::Success(texture) => texture,
            CurrentSurfaceTexture::Outdated | CurrentSurfaceTexture::Suboptimal(_) => {
                surface.configure(device, config);
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

        let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
            label: Some("Vello surface blit"),
        });
        let destination = surface_texture
            .texture
            .create_view(&wgpu::TextureViewDescriptor::default());
        blitter.copy(device, &mut encoder, target_view, &destination);
        queue.submit([encoder.finish()]);
        surface_texture.present();
        device.poll(wgpu::PollType::Poll).unwrap();
    }
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        let AppState::Suspended(cached_window) = &mut self.state else {
            return;
        };

        let window = cached_window.take().unwrap_or_else(|| {
            let attributes = Window::default_attributes()
                .with_title("Vello minimal feature demo")
                .with_inner_size(LogicalSize::new(800, 600));
            Arc::new(event_loop.create_window(attributes).expect("create window"))
        });

        let size = window.inner_size();
        let surface = self
            .instance
            .create_surface(window.clone())
            .expect("create wgpu surface");

        let adapter =
            pollster::block_on(self.instance.request_adapter(&wgpu::RequestAdapterOptions {
                power_preference: wgpu::PowerPreference::HighPerformance,
                compatible_surface: Some(&surface),
                force_fallback_adapter: false,
            }))
            .expect("request wgpu adapter");

        let (device, queue) =
            pollster::block_on(adapter.request_device(&wgpu::DeviceDescriptor::default()))
                .expect("request wgpu device");

        let format = surface
            .get_capabilities(&adapter)
            .formats
            .into_iter()
            .find(|f| {
                matches!(
                    f,
                    wgpu::TextureFormat::Rgba8Unorm | wgpu::TextureFormat::Bgra8Unorm
                )
            })
            .expect("surface format");

        let config = wgpu::SurfaceConfiguration {
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            format,
            width: size.width,
            height: size.height,
            present_mode: wgpu::PresentMode::AutoVsync,
            desired_maximum_frame_latency: 2,
            alpha_mode: wgpu::CompositeAlphaMode::Auto,
            view_formats: vec![],
        };

        surface.configure(&device, &config);
        let target = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Vello target"),
            size: wgpu::Extent3d {
                width: size.width.max(1),
                height: size.height.max(1),
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8Unorm,
            usage: wgpu::TextureUsages::STORAGE_BINDING | wgpu::TextureUsages::TEXTURE_BINDING,
            view_formats: &[],
        });

        let target_view = target.create_view(&wgpu::TextureViewDescriptor::default());
        self.renderers = Some(
            Renderer::new(&device, RendererOptions::default()).expect("create Vello renderer"),
        );

        self.adapter = Some(adapter);
        self.device = Some(device);
        self.queue = Some(queue);
        let blitter = wgpu::util::TextureBlitter::new(self.device.as_ref().unwrap(), format);
        self.state = AppState::Active {
            window: window.clone(),
            surface,
            config,
            target_texture: target,
            target_view,
            blitter,
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
            config,
            target_texture,
            target_view,
            surface_is_valid,
            ..
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
                    let device = self.device.as_ref().unwrap();
                    config.width = size.width;
                    config.height = size.height;
                    surface.configure(device, config);
                    *target_texture = device.create_texture(&wgpu::TextureDescriptor {
                        label: Some("Vello target"),
                        size: wgpu::Extent3d {
                            width: size.width,
                            height: size.height,
                            depth_or_array_layers: 1,
                        },
                        mip_level_count: 1,
                        sample_count: 1,
                        dimension: wgpu::TextureDimension::D2,
                        format: wgpu::TextureFormat::Rgba8Unorm,
                        usage: wgpu::TextureUsages::STORAGE_BINDING
                            | wgpu::TextureUsages::TEXTURE_BINDING,
                        view_formats: &[],
                    });
                    *target_view =
                        target_texture.create_view(&wgpu::TextureViewDescriptor::default());
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
