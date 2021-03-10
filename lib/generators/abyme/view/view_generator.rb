require 'rails/generators'

module Abyme
  module Generators
    class ViewGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :attributes, type: :array, default: [], banner: "field field"

      def create_partial_file
        create_file partial_file_path

        if defined?(SimpleForm)
          insert_fields(:simple_form)
        else
          insert_fields(nil)
        end
      end

      private

      def partial_file_path
        Rails.root.join('app', 'views', 'abyme', "_#{name.downcase}_fields.html.erb")
      end

      def insert_fields(builder)
        if builder == :simple_form
          insert_into_file(partial_file_path, simple_form_fields)
        else
          insert_into_file(partial_file_path, "<%# #{name.downcase} fields here %>")
        end
      end

      def simple_form_fields
        if attributes.map(&:name).include?('all')
          rejected_keys(name.classify.constantize.new.attributes.keys).map do |key|
            "<%= f.input :#{key} %>"
          end.push("<%= remove_association %>").join("\n")
        else
          attributes.map(&:name).map do |key|
            "<%= f.input :#{key} %>"
          end.push("<%= remove_association %>").join("\n")
        end
      end

      def rejected_keys(keys)
        keys.reject { |key| ['id', 'created_at', 'updated_at'].include?(key) || key.match(/_id/) }
      end
    end
  end
end
