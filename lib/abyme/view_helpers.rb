require_relative "abyme_builder"

module Abyme
  module ViewHelpers
    # ABYME_FOR

    # this helper will generate the top level wrapper markup
    # with the bare minimum html attributes (data-controller="abyme")
    # it takes the Symbolized name of the association (plural) and the form object
    # then you can pass a hash of options (see exemple below)
    # if no block given it will generate a default markup for
    # #persisted_records_for, #new_records_for & #add_associated_record methods
    # if a block is given it will instanciate a new AbymeBuilder and pass to it
    # the name of the association, the form object and the lookup_context

    # == Options

    # - limit (Integer)
    # you can set a limit for the new association fields to display

    # - min_count (Integer)
    # set the default number of blank fields to display

    # - partial (String)
    # to customize the partial path by default #abyme_for will expect
    # a partial to bbe present in views/abyme

    # - Exemple

    # <%= abyme_for(:tasks, f, limit: 3) do |abyme| %>
    #   ...
    # <% end %>

    # will output this html

    # <div data-controller="abyme" data-limit="3" id="abyme--tasks">
    #   ...
    # </div>

    def abyme_for(association, form, options = {}, &block)
      content_tag(:div, data: {controller: "abyme", limit: options[:limit], min_count: options[:min_count]}, id: "abyme--#{association}") do
        if block
          yield(
            Abyme::AbymeBuilder.new(
              association: association, form: form, context: self, partial: options[:partial]
            )
          )
        else
          # model = association.to_s.singularize.classify.constantize
          model = association.to_s.singularize
          concat(persisted_records_for(association, form, options))
          concat(new_records_for(association, form, options))
          concat(add_associated_record(content: options[:button_text] || "Add #{model}"))
        end
      end
    end

    alias_method :abymize, :abyme_for

    # NEW_RECORDS_FOR

    # this helper is call by the AbymeBuilder #new_records instance method
    # it generates the html markup for new associations fields
    # it takes the association (Symbol) and the form object
    # then a hash of options.

    # - Exemple
    # <%= abyme_for(:tasks, f) do |abyme| %>
    #   <%= abyme.new_records %>
    #   ...
    # <% end %>

    # will output this html

    # <div data-target="abyme.associations" data-association="tasks" data-abyme-position="end">
    #    <template class="abyme--task_template" data-target="abyme.template">
    #       <div data-target="abyme.fields abyme.newFields" class="abyme--fields task-fields">
    #         ... partial html goes here
    #       </div>
    #    </template>
    #    ... new rendered fields goes here
    # </div>

    # == Options
    # - position (:start, :end)
    # allows you to specify whether new fields added dynamically
    # should go at the top or at the bottom
    # :end is the default value

    # - partial (String)
    # to customize the partial path by default #abyme_for will expect
    # a partial to bbe present in views/abyme

    # - fields_html (Hash)
    # allows you to pass any html attributes to each fields wrapper

    # - wrapper_html (Hash)
    # allows you to pass any html attributes to the the html element
    # wrapping all the fields

    def new_records_for(association, form, options = {}, &block)
      options[:wrapper_html] ||= {}

      wrapper_default = {
        data: {
          abyme_target: "associations",
          association: association,
          abyme_position: options[:position] || :end
        }
      }

      fields_default = {data: {target: "abyme.fields abyme.newFields"}}

      content_tag(:div, build_attributes(wrapper_default, options[:wrapper_html])) do
        content_tag(:template, class: "abyme--#{association.to_s.singularize}_template", data: {abyme_target: "template"}) do
          fields_for_builder form, association, form.object.send(association).build, child_index: "NEW_RECORD" do |f|
            content_tag(:div, build_attributes(fields_default, basic_fields_markup(options[:fields_html], association))) do
              # Here, if a block is passed, we're passing the association fields to it, rather than the form itself
              # block_given? ? yield(f) : render(options[:partial] || "abyme/#{association.to_s.singularize}_fields", f: f)
              block ? yield(f) : render_association_partial(association, f, options[:partial])
            end
          end
        end
      end
    end

    # PERSISTED_RECORDS_FOR

    # this helper is call by the AbymeBuilder #records instance method
    # it generates the html markup for persisted associations fields
    # it takes the association (Symbol) and the form object
    # then a hash of options.

    # - Exemple
    # <%= abyme_for(:tasks, f) do |abyme| %>
    #   <%= abyme.records %>
    #   ...
    # <% end %>

    # will output this html

    # <div>
    #   <div data-target="abyme.fields" class="abyme--fields task-fields">
    #     ... partial html goes here
    #   </div>
    # </div>

    # == Options
    # - collection (Active Record Collection)
    # allows you to pass an AR collection
    # by default every associated records will be present

    # - order (Hash)
    # allows you to order the collection
    # ex: order: { created_at: :desc }

    # - partial (String)
    # to customize the partial path by default #abyme_for will expect
    # a partial to bbe present in views/abyme

    # - fields_html (Hash)
    # allows you to pass any html attributes to each fields wrapper

    # - wrapper_html (Hash)
    # allows you to pass any html attributes to the the html element
    # wrapping all the fields

    def persisted_records_for(association, form, options = {})
      records = options[:collection] || form.object.send(association)
      # return if records.empty?

      options[:wrapper_html] ||= {}
      fields_default = {data: {abyme_target: "fields"}}

      if options[:order].present?
        records = records.order(options[:order])
        # by calling the order method on the AR collection
        # we get rid of the records with errors
        # so we have to get them back with the 2 lines below
        invalids = form.object.send(association).reject(&:persisted?)
        records = records.to_a.concat(invalids) if invalids.any?
      end

      content_tag(:div, options[:wrapper_html]) do
        fields_for_builder(form, association, records) do |f|
          content_tag(:div, build_attributes(fields_default, basic_fields_markup(options[:fields_html], association))) do
            block_given? ? yield(f) : render_association_partial(association, f, options[:partial])
          end
        end
      end
    end

    # ADD & REMOVE ASSOCIATION

    # these helpers will call the #create_button method
    # to generate the buttons for add and remove associations
    # with the right action and a default content text for each button

    def add_associated_record(options = {}, &block)
      action = "click->abyme#add_association"
      options[:content] ||= "Add Association"
      create_button(action, options, &block)
    end

    def remove_associated_record(options = {}, &block)
      action = "click->abyme#remove_association"
      options[:content] ||= "Remove Association"
      create_button(action, options, &block)
    end

    alias_method :add_association, :add_associated_record
    alias_method :remove_association, :remove_associated_record

    private

    # FORM BUILDER SELECTION

    # If form builder inherits from SimpleForm, we should use its fields_for helper to keep the wrapper options
    # :nocov:
    def fields_for_builder(form, association, records, options = {}, &block)
      if defined?(SimpleForm) && form.instance_of?(SimpleForm::FormBuilder)
        form.simple_fields_for(association, records, options, &block)
      else
        form.fields_for(association, records, options, &block)
      end
    end
    # :nocov:

    # CREATE_BUTTON

    # this helper is call by either add_associated_record or remove_associated_record
    # by default it will generate a button tag.

    # == Options
    # - content (String)
    # allows you to set the button text

    # - tag (Symbol)
    # allows you to set the html tag of your choosing
    # default if :button

    # - html (Hash)
    # to pass any html attributes you want.

    def create_button(action, options, &block)
      options[:html] ||= {}
      options[:tag] ||= :button

      if block
        content_tag(options[:tag], {data: {action: action}}.merge(options[:html])) do
          capture(&block)
        end
      else
        content_tag(options[:tag], options[:content], {data: {action: action}}.merge(options[:html]))
      end
    end

    # BASIC_FIELDS_MARKUP

    # generates the default html classes for fields
    # add optional classes if present

    def basic_fields_markup(html, association = nil)
      if html && html[:class]
        html[:class] = "abyme--fields #{association.to_s.singularize}-fields #{html[:class]}"
      else
        html ||= {}
        html[:class] = "abyme--fields #{association.to_s.singularize}-fields"
      end
      html
    end

    # BUILD_ATTRIBUTES

    # add optionals html attributes without overwritting
    # the default or already present ones

    def build_attributes(default, attr)
      # Add new data attributes values to the default ones (only values)
      if attr[:data]
        default[:data].each do |key, value|
          default[:data][key] = "#{value} #{attr[:data][key]}".strip
        end
        # Add new data attributes (keys & values)
        default[:data] = default[:data].merge(attr[:data].reject { |key, _| default[:data][key] })
      end
      # Merge data attributes to the hash of html attributes
      default.merge(attr.reject { |key, _| key == :data })
    end

    # RENDER PARTIAL

    # renders a partial based on the passed path, or will expect a partial to be found in the views/abyme directory.

    def render_association_partial(association, form, partial = nil, context = nil)
      partial_path = partial || "abyme/#{association.to_s.singularize}_fields"
      context ||= self
      context.render(partial: partial_path, locals: {f: form})
    end
  end
end
