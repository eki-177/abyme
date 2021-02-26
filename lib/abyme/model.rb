module Abyme
  module Model
    module ClassMethods
      def abymize(association, permit: nil, reject: nil, **options)
        default_options = {reject_if: :all_blank, allow_destroy: true}
        nested_attributes_options = default_options.merge(options)
        accepts_nested_attributes_for association, nested_attributes_options
        # Save allow_destroy value for this model/association for later
        save_destroy_option(association, nested_attributes_options[:allow_destroy])
        Abyme::Model.permit_attributes(self.name, association, permit || reject, permit.present?) if permit.present? || reject.present?
      end

      def abyme_attributes
        Abyme::Model.instance_variable_get(:@permitted_attributes)[self.name]
      end

      private

      def save_destroy_option(association, value)
        Abyme::Model.instance_variable_get(:@allow_destroy)[self.name][association] = value
      end
    end

    @permitted_attributes ||= {}
    @allow_destroy        ||= {}

    attr_accessor :allow_destroy
    attr_reader   :permitted_attributes

    def self.permit_attributes(class_name, association, attributes, permit)
      @permitted_attributes[class_name]["#{association}_attributes".to_sym] = AttributesBuilder.new(class_name, association, attributes, permit)
                                                                                               .build_attributes
    end

    def self.included(klass)
      @permitted_attributes[klass.name] ||= {}
      @allow_destroy[klass.name]        ||= {}
      klass.extend ClassMethods
    end

    class AttributesBuilder
      def initialize(model, association, attributes, permit = true)
        @model = model
        @association = association
        @attributes_list = attributes
        @permit = permit
        @association_class = @association.to_s.classify.constantize
      end

      def build_attributes
        nested_attributes = @association_class.abyme_attributes if @association_class.respond_to? :abyme_attributes
        authorized_attributes = build_default_attributes
        if @permit && @attributes_list == :all_attributes
          authorized_attributes = build_all_attributes(authorized_attributes, nested_attributes)
        elsif @permit
          @attributes_list << nested_attributes unless (nested_attributes.blank? || @attributes_list.include?(nested_attributes))
          authorized_attributes += @attributes_list
        else
          authorized_attributes = build_all_attributes(authorized_attributes, nested_attributes)
          authorized_attributes -= @attributes_list
        end
        authorized_attributes
      end

      def destroy_allowed?
        Abyme::Model.instance_variable_get(:@allow_destroy).dig(@model, @association)
      end

      def add_all_attributes
        @association_class.column_names.map(&:to_sym).reject { |attr| [:id, :created_at, :updated_at].include?(attr) }
      end

      def build_all_attributes(authorized_attributes, nested_attributes)
        authorized_attributes += add_all_attributes
        authorized_attributes << nested_attributes unless (nested_attributes.blank? || authorized_attributes.include?(nested_attributes))
        authorized_attributes
      end

      def build_default_attributes
        attributes = [:id]
        attributes << :_destroy if destroy_allowed?
        attributes
      end
    end
  end
end