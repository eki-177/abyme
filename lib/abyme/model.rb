module Abyme
  module Model
    extend ActiveSupport::Concern

    included do
      cattr_accessor :abyme_params
      @@abyme_params = {}
    end

    class_methods do
      def abymize(association, attributes = {}, options = {})
        default_options = {reject_if: :all_blank, allow_destroy: true}
        accepts_nested_attributes_for association, default_options.merge(options)
        self.abyme_params["#{association}_attributes"] = attributes[:allow]
      end
    end

  end
end