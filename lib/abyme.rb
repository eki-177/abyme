require "abyme/version"
require 'abyme/view_helpers'
require 'abyme/engine'

module Abyme
  class Error < StandardError; end
  autoload :Model, 'abyme/model'
end
