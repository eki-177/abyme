module Abyme
  module Model
    @permitted_attributes ||= {}

    def self.add(class_name, association, attributes)
      @permitted_attributes[class_name]["#{association}_attributes".to_sym] = build_attributes_list(association, attributes)
    end

    def self.included(klass)
      @permitted_attributes[klass.name] ||= {}
      klass.extend ClassMethods
    end

    module ClassMethods
      def abymize(association, attributes = {}, options = {})
        default_options = {reject_if: :all_blank, allow_destroy: true}
        accepts_nested_attributes_for association, default_options.merge(options)
        Abyme::Model.add(self.name, association, attributes) if attributes[:permit]
      end

      def abyme_attributes
        Abyme::Model.instance_variable_get(:@permitted_attributes)[self.name]
      end
    end

    private

    # TODO: Remove _destroy from default attributes if allow_destroy is false
    def self.build_attributes_list(association, attributes)
      model = association.to_s.classify.constantize
      nested_attributes = model.abyme_attributes if model.respond_to? :abyme_attributes # If nested model is abymized
      authorized_attributes = [:_destroy, :id] # Default
      if attributes[:permit] == :all_attributes
        authorized_attributes += add_all_attributes(model)
        insert_nested_attributes(authorized_attributes, nested_attributes)
      else
        insert_nested_attributes(attributes[:permit], nested_attributes)
        authorized_attributes += attributes[:permit]
      end
      authorized_attributes
    end

    def self.insert_nested_attributes(destination, attributes)
      destination << attributes unless (attributes.blank? || destination.include?(attributes))
    end

    def self.add_all_attributes(model)
      model.column_names.map(&:to_sym).reject { |attr| [:id, :created_at, :updated_at].include?(attr) }
    end
  end
end