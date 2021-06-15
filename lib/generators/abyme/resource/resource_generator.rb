require 'rails/generators'

module Abyme
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :association, type: :string, required: true, banner: "association association"
      argument :attributes, type: :array, default: [], banner: "field field"

      def call_generators
        Rails::Generators.invoke "abyme:model", [name, association, *attributes.map(&:name)]
        Rails::Generators.invoke "abyme:controller", [name]
        Rails::Generators.invoke "abyme:view", [association, *attributes.map(&:name)]
      end
    end
  end
end