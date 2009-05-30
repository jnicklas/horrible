module Horrible
  module Widget

    attr_reader :env

    def self.included(base)
      super
      base.extend(ClassMethods)
    end

    def initialize
      @responses = {}
    end

    def action(&block)
      id = block.object_id.to_s
      @responses[id] = block
      "/call/#{id}"
    end

    def request
      Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def html
      yield(Builder::XmlMarkup.new).to_s
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
          start
        end
      else
        Fiber.yield([404, {}, "Page not found"])
      end
    end

    def start
      respond_with { to_html }
    end

    def to_html
      ""
    end

    def respond_with
      @responses = {}
      raise ArgumentError, "no block" unless block_given?
      Fiber.yield([200, {}, yield])
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
            widget.resume(@env)
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