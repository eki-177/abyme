require 'rails/generators'

module Abyme
  module Generators
    class ViewGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :association, type: :string, required: true, banner: "association association"
      argument :attributes, type: :array, default: [], banner: "field field"

      def create_partial_file
        create_file partial_file_path
        if defined?(SimpleForm)
          insert_fields(:simple_form)
        else
          insert_fields
        end
      end

      private

      def partial_file_path
        Rails.root.join('app', 'views', 'abyme', "_#{association.downcase}_fields.html.erb")
      end

      def insert_fields(builder = nil)
        if builder == :simple_form
          insert_into_file(partial_file_path, simple_form_fields)
        else
          insert_into_file(partial_file_path, "<%# #{association.downcase} fields here %>")
        end
      end

      def simple_form_fields
        if attributes.map(&:name).include?('all')
          inputs = rejected_keys(association.classify.constantize.new.attributes.keys).map do |key|
            "<%= f.input :#{key} %>"
          end
        else
          inputs = attributes.map(&:name).map do |key|
            "<%= f.input :#{key} %>"
          end
        end
        inputs.push(default_keys).join("\n")
      end

      def rejected_keys(keys)
        keys.reject { |key| ['id', 'created_at', 'updated_at'].include?(key) || key.match(/_id/) }
      end

      def default_keys
        %{
          <%= f.hidden_field :_destroy %>
          <%= remove_associated_record content: "Remove #{association.downcase}" %>
        }
      end
    end
  end
end
