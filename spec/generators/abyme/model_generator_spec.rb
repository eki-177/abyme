require 'rails_helper'
require 'generators/abyme/model/model_generator'

RSpec.describe Abyme::Generators::ModelGenerator, type: :generator do
  destination File.expand_path("../../dummy/", __dir__)

  before(:all) do
    copy_test_model
  end

  context "with no arguments" do
    before(:all) do 
      copy_test_model
      run_generator %w[test participants]
    end

    after(:all) { remove_test_model }

    it "adds configuration to parent model" do
      assert_file "app/models/test.rb", /class Test < ApplicationRecord\s{3}include Abyme::Model/
    end

    it "adds abymize for target model without any attribute" do
      assert_file "app/models/test.rb", /has_many :participants\s{3}abymize :participants/
    end

    it "doesn't add configuration twice if executed for another target model" do
      run_generator %w[test comments]
      assert_file "app/models/test.rb", /class Test < ApplicationRecord\s{3}include Abyme::Model\s*has_many/
    end
  end

  context "with keyword arguments" do
    before(:each) { copy_test_model }
    after(:each) { remove_test_model }

    it "adds abymize for target model with specified attributes" do
      run_generator %w[test participants email name]
      assert_file "app/models/test.rb", /has_many :participants\s{3}abymize :participants, permit: \[:email, :name\]/
    end

    it "adds abymize for target model with all attributes" do
      run_generator %w[test participants all_attributes]
      assert_file "app/models/test.rb", /has_many :participants\s{3}abymize :participants, permit: :all_attributes/
    end
  end

  context "with a namespaced model" do
    before(:all) do
      prepare_namespaced_model
      run_generator %w[admin/test participants email name]
    end

    after(:all) { remove_test_model }

    it "adds configuration to parent model" do
      assert_file "app/models/admin/test.rb", /module Admin\s*class Test < ApplicationRecord\s*include Abyme::Model/
    end

    it "adds abymize for target model with specified attributes" do
      assert_file "app/models/admin/test.rb", /has_many :participants\s*abymize :participants, permit: \[:email, :name\]/
    end
  end

  def copy_test_model
    FileUtils.copy_file('spec/fixtures/test.rb', File.join(destination_root, "app/models/test.rb"))
  end

  def prepare_namespaced_model
    FileUtils.mkdir_p(File.join(destination_root, 'app/models', "admin"))
    FileUtils.copy_file('spec/fixtures/admin/test.rb', File.join(destination_root, "app/models/admin/test.rb"))
  end

  def remove_test_model
    file_path = File.join(destination_root, 'app/models/test.rb')
    File.delete(file_path) if File.exist?(file_path)
  end
end