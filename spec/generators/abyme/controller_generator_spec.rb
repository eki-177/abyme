require "rails_helper"
require "generators/abyme/controller/controller_generator"

RSpec.describe Abyme::Generators::ControllerGenerator, type: :generator do
  p File.expand_path("../dummy/", __dir__)
  destination File.expand_path("../../dummy/", __dir__)
  arguments %w[tests]

  before(:all) do
    copy_tests_controller
    # copy_rails_bin
  end

  before(:each) do
    run_generator
  end

  after(:each) do
    remove_tests_controller
  end

  it "adds abyme_attributes to strong params" do
    assert_file "app/controllers/tests_controller.rb",
      /params\.require\(:test\)\.permit\(abyme_attributes, :title, :description\)/
  end

  # def copy_rails_bin
  #   FileUtils.copy_file('spec/fixtures/rails', File.join(destination_root, 'bin/rails'))
  # end

  def copy_tests_controller
    FileUtils.copy_file("spec/fixtures/tests_controller.rb", File.join(destination_root, "app/controllers/tests_controller.rb"))
  end

  def remove_tests_controller
    file_path = File.join(destination_root, "app/controllers/tests_controller.rb")
    File.delete(file_path) if File.exist?(file_path)
  end
end
