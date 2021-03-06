# Hardcore string reversing! OMFG!
require 'rubygems'
require 'horrible'

class Calculator
  include Horrible::Widget
  
  attr_accessor :string

  def reverse
    self.string = params["string"].reverse if params["string"]
  end

  def to_html
    builder do |html|
      html.form(:method => 'POST', :action => action { reverse }) do
        html.input(:type => 'text', :name => 'string', :value => string)
        html.input(:type => 'submit', :value => 'Reverse!')
      end
    end
  end
end

use Rack::Session::Cookie
run Calculator
