require 'rails/generators'

module Abyme
  module Generators
    # class ControllerGenerator < Rails::Generators::Base
    class ControllerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def insert_abyme_attributes_in_strong_params
        insert_into_file(
          controller_file_path,
          "abyme_attributes, ",
          after: /_params\s*(.*)permit\(\s*/
        )
      end

      private

      def controller_file_path
        Rails.root.join('app', 'controllers', "#{name.pluralize}_controller.rb")
      end
    end
  end
end
