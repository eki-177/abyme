module Abyme
  module Model
    module ClassMethods
      def abymize(association, permit: nil, reject: nil, **options)
        default_options = {reject_if: :all_blank, allow_destroy: true}
        nested_attributes_options = default_options.merge(options)
        accepts_nested_attributes_for association, nested_attributes_options
        Abyme::Model.instance_variable_get(:@allow_destroy)[self.name][association] = nested_attributes_options[:allow_destroy]
        Abyme::Model.add(self.name, association, permit) if permit.present?
      end

      def abyme_attributes
        Abyme::Model.instance_variable_get(:@permitted_attributes)[self.name]
      end
    end

    @permitted_attributes ||= {}
    @allow_destroy        ||= {}

    attr_accessor :allow_destroy
    attr_reader   :permitted_attributes

    def self.add(class_name, association, attributes)
      @permitted_attributes[class_name]["#{association}_attributes".to_sym] = build_attributes_list(class_name, association, attributes)
    end

    def self.included(klass)
      @permitted_attributes[klass.name] ||= {}
      @allow_destroy[klass.name]        ||= {}
      klass.extend ClassMethods
    end

    private

    # TODO: Remove _destroy from default attributes if allow_destroy is false
    def self.build_attributes_list(model, association, attributes_list)
      association_class = association.to_s.classify.constantize
      # If nested association is abymized itself
      nested_attributes = association_class.abyme_attributes if association_class.respond_to? :abyme_attributes
      authorized_attributes = build_default_attributes(model, association)
      if attributes_list == :all_attributes
        authorized_attributes += add_all_attributes(association_class)
        authorized_attributes << nested_attributes unless (nested_attributes.blank? || authorized_attributes.include?(nested_attributes))
      else
        attributes_list << nested_attributes unless (nested_attributes.blank? || nested_attributes.key?("#{association}_attributes".to_sym))
        authorized_attributes += attributes_list
      end
      authorized_attributes
    end

    def self.destroy_allowed?(model, association)
      @allow_destroy.dig(model, association)
    end

    def self.add_all_attributes(model)
      model.column_names.map(&:to_sym).reject { |attr| [:id, :created_at, :updated_at].include?(attr) }
    end

    def self.build_default_attributes(model, association)
      attributes = [:id]
      attributes << :_destroy if destroy_allowed?(model, association)
      attributes
    end
  end
end