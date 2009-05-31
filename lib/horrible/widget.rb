module Horrible
  module Widget

    attr_reader :env

    def self.included(base)
      super
      base.extend(ClassMethods)
    end

    def action(&block)
      id = block.object_id.to_s
      @responses ||= {}
      @responses[id] = block
      "/call/#{id}"
    end

    def request
      Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def builder
      yield(Builder::XmlMarkup.new).to_s
    end

    def resume(env)
      @env = env
      if env["PATH_INFO"] == '/'
        return respond_with { to_html }
      elsif response_id = env["PATH_INFO"][%r(/call/([0-9]+)), 1]
        if @responses and @responses[response_id] 
          @responses[response_id].call
          return respond_with { to_html }
        else
          return respond_with { to_html }
        end
      else
        return respond_with(404) { "Page not found" }
      end
    end

    def to_html
      ""
    end

    def respond_with(status=200, headers={})
      @responses = {}
      [status, headers, yield]
    end

    module ClassMethods    
      def continuations
        # Thread safety: fiber has to be resumed from the same thread.
        # Is there any workaround, otherwise that would make Horrible
        # fundamentally no threadsafe.
        @continuations ||= Continuations.new(lambda {
          widget = self.new
          loop do
            Horrible.logger.info "[HORRIBLE] Executing action."
            Fiber.yield(widget.resume(@env))
          end
        })
      end

      def mutex
        @mutex ||= Mutex.new
      end

      def call(env)
        # FIXME: this is a nasty hack, and most likely not threadsafe.
        # Not sure how to fix this :(
        mutex.synchronize do
          @env = env
          continuations.call(env)
        end
      end
    end

  end
end