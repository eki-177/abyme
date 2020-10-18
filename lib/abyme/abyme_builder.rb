module Abyme
  class AbymeBuilder < ActionView::Base
    include ActionView

    # If a block is given to the #abymize helper 
    # it will instanciate a new AbymeBuilder 
    # and pass to it the association name (Symbol)
    # the form object, lookup_context
    # optionaly a partial path 

    def initialize(association:, form:, lookup_context:, partial:, &block)
      @association = association
      @form = form
      @lookup_context = lookup_context
      @partial = partial
      yield(self) if block_given?
    end
  
    def records(options = {})
      persisted_records_for(@association, @form, options) do |fields_for_association|
        render_association_partial(fields_for_association, options)
      end
    end
    
    def new_records(options = {}, &block)
      new_records_for(@association, @form, options) do |fields_for_association|
        render_association_partial(fields_for_association, options)
      end
    end
  
    private

    def render_association_partial(fields, options)
      partial = @partial || options[:partial] || "abyme/#{@association.to_s.singularize}_fields"
      ActionController::Base.render(partial: partial, locals: { f: fields })
    end
  end
end