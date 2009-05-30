# Weee, incrementation, the classic Seaside example...
require ::File.join(::File.dirname(__FILE__), '..', 'lib', 'horrible')

class Calculator
  include Horrible::Widget
  
  def initialize
    @value = 0
  end

  def to_html
    html do |html|
      html.p(@value)
      html.p do
        html.a '++', :href => action { @value += 1 }
      end
    end
  end
end

use Rack::Session::Cookie
run Calculator
