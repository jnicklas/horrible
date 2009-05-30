# Hardcore string reversing! OMFG!
require ::File.join(::File.dirname(__FILE__), '..', 'lib', 'horrible')

class Calculator
  include Horrible::Widget
  
  attr_accessor :string

  def reverse
    self.string = params["string"].reverse
  end

  def to_html
    html do |html|
      html.form(:method => 'POST', :action => lambda { reverse }) do
        html.input(:type => 'text', :name => 'string', :value => :string)
        html.input(:type => 'submit', :value => 'Reverse!')
      end
    end
  end
end

use Rack::Session::Cookie
run Calculator
