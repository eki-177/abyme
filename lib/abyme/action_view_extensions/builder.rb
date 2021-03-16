module Abyme
  module ActionViewExtensions
    module Builder
      def abyme_for(association, options = {}, &block)
        @template.abyme_for(association, self, options, &block)
      end

      alias :abymize :abyme_for
    end
  end
end

module ActionView::Helpers
  class FormBuilder
    include Abyme::ActionViewExtensions::Builder
  end
end