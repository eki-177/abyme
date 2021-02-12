module Abyme
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def abymize(association, options = {})
        default_options = {reject_if: :all_blank, allow_destroy: true}
        accepts_nested_attributes_for association, default_options.merge(options)
      end
    end
  end
end