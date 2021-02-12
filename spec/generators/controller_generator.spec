require 'rails_helper'
require 'generator_spec'
require 'generators/smashing_documentation/install_generator'

RSpec.describe Abyme::Generators::ControllerGenerator, type: :generator do
  it "adds abyme_attributes to strong params" do
    run_generator
    expect(User).to receive(:taco_delivery)
  end