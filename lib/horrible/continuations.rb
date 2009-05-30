# Thanks to Josh Peek!

class Continuations
  def initialize(app)
    require 'fiber'
    @app, @pool = app, {}
  end
  
  def pool
    @pool
  end

  def call(env)
    session = env['rack.session'] ||= {}
    fiber = lookup_fiber(session)
    response = fiber.resume
    sweep_fiber!(session, fiber)
    response
  end

  private
    def lookup_fiber(session)
      fiber_id = session[:signup_fiber_id]
      unless fiber = @pool[fiber_id]
        fiber = Fiber.new(&@app)
        @pool[fiber.object_id] = fiber
        session[:signup_fiber_id] = fiber.object_id
      end
      fiber
    end

    def sweep_fiber!(session, fiber)
      unless fiber.alive?
        @pool.delete(fiber.object_id)
        session.delete(:signup_fiber_id)
      end
      nil
    end
end