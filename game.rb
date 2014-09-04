require 'glfw3'
require 'opengl'

include GL

# Initialize GLFW 3
Glfw.init
Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, 3)
Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, 2)
Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1);
Glfw::Window.window_hint(Glfw::RESIZABLE, 0);


class Glfw::Monitor
    def size
        video_mode.width * video_mode.height
    end
end

largest_monitor = Glfw::Monitor.monitors.max_by { |monitor| monitor.size }

# Create a window
window = Glfw::Window.new(800, 600, "Foobar", largest_monitor, nil)


# Set some callbacks
window.set_key_callback do |window, key, code, action, mods|
  window.should_close = true if key == Glfw::KEY_ESCAPE
end

window.set_close_callback do |window|
  window.should_close = true
end

# Make the window's context current
window.make_context_current
loop do
  # And do stuff
  Glfw.wait_events
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  window.swap_buffers
  break if window.should_close?
end

Glfw.terminate
