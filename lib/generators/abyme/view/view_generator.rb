require "rails/generators"

module Abyme
  module Generators
    class ViewGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :association, type: :string, required: true, banner: "association association"
      argument :attributes, type: :array, default: [], banner: "field field"

      # :nocov:
      def create_partial_file
        create_file partial_file_path
        if defined?(SimpleForm)
          insert_fields(:simple_form)
        else
          insert_fields
        end
      end
      # :nocov:

      private

      def partial_file_path
        Rails.root.join("app", "views", "abyme", "_#{association.downcase.singularize}_fields.html.erb")
      end

      # :nocov:
      def insert_fields(builder = nil)
        return unless File.exist? partial_file_path
        if builder == :simple_form
          insert_into_file(partial_file_path, simple_form_fields)
        else
          insert_into_file(partial_file_path, "<%# Insert #{association.downcase} fields below %>\n" << default_keys)
        end
      end
      # :nocov:

      def simple_form_fields
        inputs = if attributes.include?("all_attributes")
          rejected_keys(association.classify.constantize.new.attributes.keys).map do |key|
            "<%= f.input :#{key} %>"
          end
        else
          attributes.map do |key|
            "<%= f.input :#{key} %>"
          end
        end
        inputs.prepend(header)
        inputs.push(default_keys).join("\n")
      end

      def rejected_keys(keys)
        keys.reject { |key| ["id", "created_at", "updated_at"].include?(key) || key.match(/_id/) }
      end

      def header
        "<%# Partial for #{association.downcase.singularize} fields %>\n"
      end

      def default_keys
        %(
<%= f.hidden_field :_destroy %>
<%= remove_associated_record content: "Remove #{association.downcase.singularize}" %>
        )
      end
    end
  end
end
