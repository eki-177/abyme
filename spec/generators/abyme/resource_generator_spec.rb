require "rails_helper"
require "generators/abyme/resource/resource_generator"

RSpec.describe Abyme::Generators::ResourceGenerator, type: :generator do
  destination File.expand_path("../../dummy/", __dir__)

  before(:all) do
    copy_test_model
    copy_tests_controller
    # For a parent model Test that has many attachments
    # run_generator %w[test attachments all_attributes]
    Rails::Generators.invoke "abyme:resource", %w[test attachments all_attributes]
  end

  after(:all) do
    remove_test_view("attachments")
    remove_test_model
    remove_tests_controller
  end

  it "runs all generators for the given association and attributes" do
    # Model configuration OK
    assert_file "app/models/test.rb", /has_many :attachments, as: :attachable\s{3}abymize :attachments, permit: :all_attributes/
    # Controller OK
    assert_file "app/controllers/tests_controller.rb",
      /params\.require\(:test\)\.permit\(abyme_attributes, :title, :description\)/
    # View OK
    assert_file "app/views/abyme/_attachment_fields.html.erb", /<%= f\.hidden_field :_destroy %>/
  end

  private

  def copy_tests_controller
    FileUtils.copy_file("spec/fixtures/tests_controller.rb", File.join(destination_root, "app/controllers/tests_controller.rb"))
  end

  def remove_tests_controller
    file_path = File.join(destination_root, "app/controllers/tests_controller.rb")
    File.delete(file_path) if File.exist?(file_path)
  end

  def copy_test_model
    FileUtils.copy_file("spec/fixtures/test.rb", File.join(destination_root, "app/models/test.rb"))
  end

  def remove_test_model
    file_path = File.join(destination_root, "app/models/test.rb")
    File.delete(file_path) if File.exist?(file_path)
  end

  def remove_test_view(association = "test")
    file_path = File.join(destination_root, "app/views/abyme/_#{association.singularize}_fields.html.erb")
    File.delete(file_path) if File.exist?(file_path)
  end
end
