require "abyme/version"
require 'abyme/view_helpers'
require 'abyme/engine'
require 'abyme/action_view_extensions/builder'

module Abyme
  class Error < StandardError; end
  autoload :Model, 'abyme/model'
end
