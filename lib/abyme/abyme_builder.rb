module Abyme
  class AbymeBuilder < ActionView::Base
    include ActionView

    # If a block is given to the #abymize helper
    # it will instanciate a new AbymeBuilder
    # and pass to it the association name (Symbol)
    # the form object, lookup_context optionaly a partial path
    # then yield itself to the block

    def initialize(association:, form:, context:, partial:, locals:, &block)
      @association = association
      @form = form
      @context = context
      @lookup_context = context.lookup_context
      @partial = partial
      @locals = locals || {}
      yield(self) if block
    end

    # RECORDS

    # calls the #persisted_records_for helper method
    # passing association, form and options to it

    def records(options = {})
      locals = merge_locals(options[:locals])
      persisted_records_for(@association, @form, options) do |fields_for_association|
        render_association_partial(@association, fields_for_association, @partial, locals, @context)
      end
    end

    # NEW_RECORDS

    # calls the #new_records_for helper method
    # passing association, form and options to it
    def new_records(options = {}, &block)
      locals = merge_locals(options[:locals])
      new_records_for(@association, @form, options) do |fields_for_association|
        render_association_partial(@association, fields_for_association, @partial, locals, @context)
      end
    end

    private

    def merge_locals(passed_locals)
      passed_locals ? @locals.merge(passed_locals) : @locals
    end
  end
end
