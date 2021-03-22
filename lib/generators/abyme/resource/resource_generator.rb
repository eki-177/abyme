require 'rails/generators'

module Abyme
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :association, type: :string, required: true, banner: "association association"
      argument :attributes, type: :array, default: [], banner: "field field"

      def call_generators
        generate "abyme:model #{name} #{association} #{attributes.map(&:name).join(' ')}"
        generate "abyme:controller #{name.pluralize.capitalize}"
        generate "abyme:view #{association} #{attributes.map(&:name).join(' ')}"
      end
    end
  end
end