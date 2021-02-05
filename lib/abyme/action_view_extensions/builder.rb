# require_relative '../view_helpers'

module Abyme
  module ActionViewExtensions
    module Builder
      def abyme_for(association, options = {}, &block)
        @template.abymize(association, self, options, &block)
      end
    end
  end
end

module ActionView::Helpers
  class FormBuilder
    include Abyme::ActionViewExtensions::Builder
  end
end