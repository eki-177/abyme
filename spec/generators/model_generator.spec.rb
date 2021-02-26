require 'rails_helper'
require 'generator_spec'
require 'generators/abyme/controller/controller_generator'

RSpec.describe Abyme::Generators::ModelGenerator, type: :generator do
  destination File.expand_path("../dummy/", __dir__)
  arguments %w(tasks)

  before(:all) do
    copy_tasks_controller
    copy_rails_bin
  end

  before(:each) do
    run_generator
  end

  after(:each) do
    remove_tasks_controller
  end

  it "adds abyme_attributes to strong params" do
    assert_file "app/controllers/tasks_controller.rb", /abyme_attributes/
  end

  def copy_rails_bin
    FileUtils.copy_file('spec/fixtures/rails', File.join(destination_root, 'bin/rails'))
  end

  def copy_tasks_controller
    FileUtils.copy_file('spec/fixtures/tasks_controller.rb', File.join(destination_root, 'app/controllers/tasks_controller.rb'))
  end

  def remove_tasks_controller
    file_path = File.join(destination_root, 'app/controllers/tasks_controller.rb')
    File.delete(file_path) if File.exist?(file_path)
  end
end