using GLMakie

include("physics.jl")

# Positions of the light bodies (body 1 is the central mass, drawn separately)
body_points(state) = [Point3f(state.pos[1, i], state.pos[2, i], state.pos[3, i])
                      for i in 2:length(state.mass)]
central_point(state) = [Point3f(state.pos[1, 1], state.pos[2, 1], state.pos[3, 1])]
body_speeds(state) = vec(sqrt.(sum(abs2, state.vel[2:end, :], dims = 1)))

function build_scene(state; limit = 550, z_limit = 100)
    points = Observable(body_points(state))
    speeds = Observable(body_speeds(state))
    center = Observable(central_point(state))

    fig = Figure(size = (1920, 1080), backgroundcolor = :black, figure_padding = 0)
    ax = Axis3(fig[1, 1]; aspect = :data, protrusions = 0, perspectiveness = 0.2,
               elevation = π/6, azimuth = 0.6,
               limits = (-limit, limit, -limit, limit, -z_limit, z_limit))
    hidedecorations!(ax)
    hidespines!(ax)

    scatter!(ax, points; color = speeds, colormap = :plasma,
             colorrange = (0, maximum(speeds[])), markersize = 6)
    scatter!(ax, center; color = :yellow, markersize = 60)

    stats = Observable("")
    Label(fig[1, 1], stats; tellwidth = false, tellheight = false,
          halign = :left, valign = :top, color = :white, fontsize = 18)
    return fig, points, speeds, center, stats
end


function visualize(; n = 400, sim_speed = 10.0, steps_per_frame = 10)
    state = rotating_disk(n)
    fig, points, speeds, center, stats = build_scene(state)
    screen = display(fig; framerate = 60.0) 

    fps = 0.0  # smoothed (exponential moving average)
    last = time_ns()
    while isopen(screen)
        now = time_ns()
        frame_time = (now - last) / 1e9
        last = now

        sub_dt = sim_speed * frame_time / steps_per_frame
        for _ in 1:steps_per_frame
            update!(state, sub_dt)
        end
        points[] = body_points(state)
        speeds[] = body_speeds(state)
        center[] = central_point(state)
        yield()

        frame_fps = 1 / max(frame_time, 1e-6)
        fps = fps == 0.0 ? frame_fps : 0.95 * fps + 0.05 * frame_fps
        stats[] = "n = $n   FPS: $(round(Int, fps))   sub_dt: $(round(sub_dt, digits = 4))"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    visualize()
end
