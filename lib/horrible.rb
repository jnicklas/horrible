require File.join(File.dirname(__FILE__), 'horrible', 'continuations')
require File.join(File.dirname(__FILE__), 'horrible', 'widget')
require 'logger'
require 'rubygems'
require 'builder'

module Horrible
  VERSION = "0.0.1"
  
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end

Horrible::Widget.to_s