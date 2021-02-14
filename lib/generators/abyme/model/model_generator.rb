require 'rails/generators'

module Abyme
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :association, type: :string, required: true, banner: "association association"
      argument :attributes, type: :array, default: [], banner: "field field"

      def insert_abyme_config_in_model
        insert_abyme_configuration unless model_configured?
        insert_abymized_association
      end

      private

      def insert_abymized_association
        insert_into_file(model_file_path, after: /(^\s*(has_many|has_one|belongs_to)\s*:#{Regexp.quote(association)}.*$)/ ) do
          "\n#{insert_indentation}abymize :#{association}#{inject_abyme_attributes}\n"
        end
      end

      def insert_abyme_configuration
        if namespaced_model
          model = namespaced_model[2]
          namespace = namespaced_model[1]
          insert_into_file(model_file_path, after: /(^\s*class.*#{Regexp.quote(model)}.*$)/) do
            "\n    include Abyme::Model\n"
          end
        else
          inject_into_class(model_file_path, class_name, "  include Abyme::Model\n\n")
        end
      end

      def assign_names!(name)
        # Remove abyme namespace
        name.gsub!(/abyme_/, "")
        super
      end

      def namespaced_model
        class_name.match(/(.*)[\/::](.*)/)
      end

      def model_file_path
        Rails.root.join('app', 'models', "#{name}.rb")
      end

      def inject_abyme_attributes
        return '' if attributes.empty?
        return ", permit: :all_attributes" if attributes.map(&:name).include?('all')

        ", permit: [#{symbolized_attributes.join(', ')}]"  
      end
      
      def symbolized_attributes
        attributes.map {|attr| ":#{attr.name.downcase}" }
      end

      def model_configured?
        File.read(model_file_path).match?(/Abyme::Model/)
      end

      def insert_indentation
        namespaced_model ? "    " : "  "
      end
    end
  end
end
