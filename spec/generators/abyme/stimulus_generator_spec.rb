require 'rails_helper'
require 'generators/abyme/stimulus/stimulus_generator'

RSpec.describe Abyme::Generators::StimulusGenerator, type: :generator do
  p File.expand_path("../dummy/", __dir__)
  destination File.expand_path("../../dummy/", __dir__)

  it "registers the Stimulus controller in controllers index" do
    copy_controller_index_file
    run_generator
    assert_file "app/javascript/controllers/index.js",
      /AbymeController/
    remove_controller_index_file
  end

  def copy_controller_index_file
    FileUtils.copy_file('spec/fixtures/index.js', File.join(destination_root, 'app/javascript/controllers/index.js'))
  end

  def remove_controller_index_file
    file_path = File.join(destination_root, 'app/javascript/controllers/index.js')
    File.delete(file_path) if File.exist?(file_path)
  end
end