require 'glfw3'
require 'opengl-core'
require 'snow-data'

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

vertices = [ 0.0,  0.5, # Vertex 1 (X, Y)
     0.5, -0.5, # Vertex 2 (X, Y)
    -0.5, -0.5].pack("F*")

# Make the window's context current
window.make_context_current

GLObject = Snow::CStruct.new { uint32_t :name }

vao = GLObject.new
glGenVertexArrays(1, vao.address)
glBindVertexArray(vao.name)

vbo = GLObject.new
glGenBuffers(1, vbo.address)
glBindBuffer(GL_ARRAY_BUFFER, vbo.name)
glBufferData(GL_ARRAY_BUFFER, vertices.size, vertices, GL_STATIC_DRAW);


vert_shader_array = [File.read("first.vert")].pack("p")
vertexShader = glCreateShader(GL_VERTEX_SHADER)
glShaderSource(vertexShader, 1, vert_shader_array, nil)
glCompileShader(vertexShader)

SignedIntObject = Snow::CStruct.new { int32_t :name }
status = SignedIntObject.new
glGetShaderiv(vertexShader, GL_COMPILE_STATUS, status.address)
puts "Vert Shader Success?" + status.name.to_s


fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
glShaderSource(fragmentShader,1, [File.read("first.frag")].pack("p"), nil)
glCompileShader(fragmentShader)
glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, status.address)
puts "Frag Shader Success?" + status.name.to_s

shaderProgram = glCreateProgram()
glAttachShader(shaderProgram, vertexShader)
glAttachShader(shaderProgram, fragmentShader)
glBindFragDataLocation(shaderProgram, 0, "outColor")

glLinkProgram(shaderProgram)
glUseProgram(shaderProgram)




posAttrib = glGetAttribLocation(shaderProgram, "position")
glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 0, 0)
glEnableVertexAttribArray(posAttrib);



loop do
  # And do stuff
  Glfw.wait_events
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  puts "Loop"
  glDrawArrays(GL_TRIANGLES, 0, 3);
  window.swap_buffers
  puts glGetError
  break if window.should_close?
end

Glfw.terminate
