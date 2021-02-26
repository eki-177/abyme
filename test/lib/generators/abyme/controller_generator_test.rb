require 'test_helper'
require 'generators/controller/controller_generator'

module Abyme
  class ControllerGeneratorTest < Rails::Generators::TestCase
    tests ControllerGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
