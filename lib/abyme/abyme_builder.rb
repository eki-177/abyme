module Abyme
  class AbymeBuilder < ActionView::Base
    include ActionView

    def initialize(association:, form:, lookup_context:, &block)
      @association = association
      @form = form
      @lookup_context = lookup_context
      yield(self) if block_given?
    end
  
    def records(options = {})
      persisted_records_for(@association, @form, options) do |form|
        render_association_partial(form, options)
      end
    end
    
    def new_records(options = {}, &block)
      new_records_for(@association, @form, options) do |form|
        render_association_partial(form, options)
      end
    end
  
    # def add_association(options = {}, &block)
    #   action = 'click->abyme#add_association'
    #   create_button(action, options, &block)
    # end
  
    # def remove_association(options = {}, &block)
    #   action = 'click->abyme#remove_association'
    #   create_button(action, options, &block)
    # end
  
    private

    def render_association_partial(form, options)
      partial = options[:partial] || "shared/#{@association.to_s.singularize}_fields"
      # ActionController::Base.render(partial: "shared/#{@association.to_s.singularize}_fields", locals: { f: form })
      ActionController::Base.render(partial: partial, locals: { f: form })
    end
    
    # def create_button(action, options, &block)
    #   options[:attributes] = {} if options[:attributes].nil?
    #   options[:tag] = :button if options[:tag].nil?
  
    #   if block_given?
    #     concat content_tag(options[:tag], { data: { action: action }}.merge(options[:attributes])) do
    #       # capture(&block)
    #       yield
    #     end
    #   else
    #     render content_tag(options[:tag], options[:content], {data: { action: action }}.merge(options[:attributes]))
    #   end
    # end
  
    # def formatize(association)
    #   association.class.name.tableize
    # end

  end
end