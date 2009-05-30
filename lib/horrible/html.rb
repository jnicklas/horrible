# Output some HTML, the only tricky part is how it uses
# Widget#define_response to add a response lambda which is
# invoked later.
module Horrible
  class HTML
    def initialize(widget)
      @widget = widget
      @html = ""
    end
    
    %w(span p a div form input em strong).each do |tag|
      class_eval <<-RUBY
        def #{tag}(options={}, &block)
          tag("#{tag}", options, &block)
        end
      RUBY
    end

    def to_s
      @html
    end

  private

    def tag(type, options={}, &block)
      text = get_value(options.delete(:text))
      if block
        html = HTML.new(@widget)
        block.call(html)
        text += html.to_s
      end

      options = options.map do |key, value|
        %(#{key}="#{get_value(value)}")
      end.join(" ")

      @html += "<#{type} #{options}>#{text}</#{type}>"
    end

    def get_value(value)
      case value
      when Proc
        id = @widget.define_response(value)
        "/call/#{id}"
      when Symbol
        @widget.send(value)
      else
        value.to_s
      end
    end

  end
end