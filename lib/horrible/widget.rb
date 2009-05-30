module Horrible
  module Widget

    def self.included(base)
      super
      base.extend(ClassMethods)
    end

    def initialize
      @responses = {}
    end

    def define_response(block)
      id = block.object_id.to_s
      @responses[id] = block
      id
    end

    def html(&block)
      html = Horrible::HTML.new(self)
      yield html
      html.to_s
    end

    def resume(env)
      @env = env
      if env["PATH_INFO"] == '/'
        start
      elsif response_id = env["PATH_INFO"][%r(/call/([0-9]+)), 1]
        if @responses[response_id] 
          @responses[response_id].call
          respond_with { to_html }
        else
          Fiber.yield([404, {}, "There is no such action"])
        end
      else
        Fiber.yield([404, {}, "Page not found"])
      end
    end

    def start
      respond_with { to_html }
    end

    def respond_with
      @responses = {}
      raise ArgumentError, "no block" unless block_given?
      Fiber.yield([200, {}, yield])
    end

    module ClassMethods    
      def continuations
        @continuations ||= Continuations.new(lambda {
          widget = self.new
          loop do
            widget.resume(@env)
          end
        })
      end

      def call(env)
        @env = env
        continuations.call(env)
      end
    end

  end
end