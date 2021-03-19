require 'rails/generators'

module Abyme
  module Generators
    class StimulusGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_to_stimulus
        insert_into_file(stimulus_file_path, "\nimport { AbymeController } from 'abyme';\n")
        insert_into_file(stimulus_file_path, "application.register('abyme', AbymeController);")
      end

      private

      def stimulus_file_path
        Rails.root.join('app', 'javascript', 'controllers', 'index.js')
      end

    end
  end
end