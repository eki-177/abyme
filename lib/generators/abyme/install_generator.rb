require 'rails/generators'
require 'json'

module Abyme
  module Generators
    class InstallGenerator < Rails::Generators::Base
    	source_root File.expand_path("templates", __dir__)

      def setup
      	# Creating stimulus abyme_controller.js file
      	# ==========================================
        template "abyme_controller.js", "app/javascript/controllers/abyme_controller.js"
        add_stimulus
      end

      def add_stimulus
      	# Checking if stimulus is present in package.json => yarn add if it's not
      	# =======================================================================
      	package = JSON.parse(File.open('package.json').read)
      	exec('yarn add stimulus') if !package['dependencies'].keys.include?('stimulus')
      end

    end
  end
end