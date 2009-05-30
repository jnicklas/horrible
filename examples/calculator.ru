# A simple calculator
# I know it doesn't actually work like a calculator, but you get the idea...
require ::File.join(::File.dirname(__FILE__), '..', 'lib', 'horrible')

class Calculator
  include Horrible::Widget
  
  attr_accessor :current, :total

  def initialize
    super
    self.total = 0
    self.current = 0
  end

  def press(number)
    self.current = (self.current.to_s + number.to_s).to_i
  end

  def add
    self.total += current
    self.current = 0
  end

  def equals
    self.current = total
  end

  def clear
    self.total = 0
    self.current = 0
  end

  def to_html
    html do |html|
      html.div(:class => "calculator") do |html|
        html.p do |html|
          html.a(:class => "current", :text => :current)
        end
        (0..9).each do |num|
          html.p do |html|
            html.a(:text => num.to_s, :href => lambda { press(num) })
          end
        end
        html.p do |html|
          html.a(:text => "+", :href => lambda { add })
          html.span(:text => " | ")
          html.a(:text => "=", :href => lambda { equals })
          html.span(:text => " | ")
          html.a(:text => "AC", :href => lambda { clear })
        end
      end
    end
  end
end

use Rack::Session::Cookie
run Calculator
