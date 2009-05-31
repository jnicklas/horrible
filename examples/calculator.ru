# A simple calculator
# I know it doesn't actually work like a calculator, but you get the idea...
require 'rubygems'
require 'horrible'

class Calculator
  include Horrible::Widget
  
  attr_accessor :current, :total

  def initialize
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
    builder do |html|
      html.div(:class => "calculator") do
        html.p do
          html.a(current, :class => "current")
        end
        html.p do
          (0..9).each do |num|
            html.a(num.to_s, :href => action { press(num) })
            html << " "
          end
        end
        html.p do
          html.a("+", :href => action { add })
          html << " | "
          html.a("=", :href => action { equals })
          html << " | "
          html.a("AC", :href => action { clear })
        end
      end
    end
  end
end

use Rack::Session::Cookie
run Calculator
