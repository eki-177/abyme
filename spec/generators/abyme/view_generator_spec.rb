require "rails_helper"
require "generators/abyme/view/view_generator"

RSpec.describe Abyme::Generators::ViewGenerator, type: :generator do
  destination File.expand_path("../../dummy/", __dir__)

  context "with no arguments or when SimpleForm is not defined" do
    before(:all) do
      run_generator %w[test]
    end

    after(:all) { remove_test_view }

    it "creates an aptly named partial file with basic boilerplate fields" do
      assert_file "app/views/abyme/_test_fields.html.erb", /<%= f\.hidden_field :_destroy %>/
    end
  end

  context "when SimpleForm is defined" do
    before(:all) do
      SimpleForm = Class.new unless defined?(SimpleForm)
    end

    after(:all) { Object.send(:remove_const, :SimpleForm) }

    describe "with attributes passed as additional arguments" do
      it "creates an aptly named partial file with required fields" do
        run_generator %w[test participants email name]
        assert_file "app/views/abyme/_test_fields.html.erb", /<%= f\.input :participants %>\s*<%= f\.input :email %>\s<%= f\.input :name %>/
        remove_test_view
      end
    end
    describe "with 'all_attributes' passed as an option" do
      it "adds fields for all attributes" do
        # run_generator %w[attachment all_attributes]
        remove_test_view("attachment")
        Rails::Generators.invoke "abyme:view", %w[attachment all_attributes]
        assert_file "app/views/abyme/_attachment_fields.html.erb", /<%= f\.input :attachable_type %>\s<%= f\.input :name %>/
        remove_test_view("attachment")
      end
    end
  end

  def remove_test_view(association = "test")
    file_path = File.join(destination_root, "app/views/abyme/_#{association.singularize}_fields.html.erb")
    File.delete(file_path) if File.exist?(file_path)
  end
end
