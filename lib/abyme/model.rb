module Abyme
  module Model
    extend ActiveSupport::Concern

    included do
      cattr_reader :abyme_params
      @@abyme_params = {}
    end

    class_methods do
      def abymize(association, attributes = {}, options = {})
        default_options = {reject_if: :all_blank, allow_destroy: true}
        accepts_nested_attributes_for association, default_options.merge(options)
        @@abyme_params["#{association}_attributes".to_sym] = nested_attributes(association, attributes)
        # p "On #{self}, abymized params for #{association}: #{@@abyme_params["#{association}_attributes".to_sym]}"
      end

      private

      def nested_attributes(association, attributes)
        model = association.to_s.classify.constantize
        model.connection
        nested_params = model.abyme_params if model.respond_to? :abyme_params # If nested model is abymized
        authorized_attributes = [:_destroy, :id] # Default
        if attributes[:permit] == :all_attributes
          authorized_attributes += add_all_attributes(model)
          authorized_attributes << nested_params unless (nested_params.blank? || authorized_attributes.include?(nested_params))
        else
          attributes[:permit] << nested_params unless (nested_params.blank? || authorized_attributes.include?(nested_params))
          authorized_attributes += attributes[:permit]
        end
        authorized_attributes
      end

      def add_all_attributes(model)
        model.column_names.map(&:to_sym).reject { |attr| [:id, :created_at, :updated_at].include?(attr) }
      end
    end

  end
end