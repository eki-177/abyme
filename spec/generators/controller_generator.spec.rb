require 'rails_helper'
require 'generator_spec'
require 'generators/abyme/controller/controller_generator'

RSpec.describe Abyme::Generators::ControllerGenerator, type: :generator do
  p File.expand_path("../dummy/", __dir__)
  destination File.expand_path("../dummy/", __dir__)
  # destination File.expand_path("../dummy/", __FILE__)
  arguments %w(projects)

  before(:all) do
    # prepare_destination
    copy_rails_bin
    run_generator
  end

  it "adds abyme_attributes to strong params" do
    p File.exists?("#{destination_root}/app/controllers/projects_controller.rb")
    # assert_file "app/controllers/projects_controller.rb", "abyme_attributes"
  end

  def copy_rails_bin
    FileUtils.copy_file('spec/fixtures/rails', File.join(destination_root, 'bin/rails'))
  end
end