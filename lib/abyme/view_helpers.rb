module Abyme
  module ViewHelpers

    def abymize(association, form, options = {}, &block)
      content_tag(:div, data: { controller: 'abyme', limit: options[:limit], min_count: options[:min_count] }, id: "abyme--#{association}") do
        if block_given?
          yield(Abyme::AbymeBuilder.new(
            association: association, form: form, lookup_context: self.lookup_context, partial: options[:partial]
            )
          )
        else
          model = association.to_s.singularize.classify.constantize
          concat(persisted_records_for(association, form, options))
          concat(new_records_for(association, form, options)) 
          concat(add_association(content: options[:button_text] || "Add #{model}"))
        end
      end
    end

    def new_records_for(association, form, options = {}, &block)
      options[:wrapper_html] ||= {}
      content_tag(:div, options[:wrapper_html].merge(
        data: { target: 'abyme.associations', association: association, abyme_position: options[:position] || :end }
        )) do
        content_tag(:template, class: "abyme--#{association.to_s.singularize}_template", data: { target: 'abyme.template' }) do
          form.fields_for association, association.to_s.classify.constantize.new, child_index: 'NEW_RECORD' do |f|
            content_tag(:div, basic_fields_markup(options[:fields_html], association).merge(data: { target: 'abyme.fields abyme.newFields' })) do
              # Here, if a block is passed, we're passing the association fields to it, rather than the form itself
              block_given? ? yield(f) : render("abyme/#{association.to_s.singularize}_fields", f: f)
            end
          end
        end
      end
    end
  
    def persisted_records_for(association, form, options = {})
      records = options[:collection] || form.object.send(association)
      options[:wrapper_html] ||= {}
      
      if options[:order].present?
        records = records.order(options[:order])
        # Get invalid records
        invalids = form.object.send(association).reject(&:persisted?)
        records = records.to_a.concat(invalids) if invalids.any?
      end
      
      content_tag(:div, options[:wrapper_html]) do
        form.fields_for(association, records) do |f|
          content_tag(:div, basic_fields_markup(options[:fields_html], association).merge(data: { target: 'abyme.fields' })) do
            block_given? ? yield(f) : render("abyme/#{association.to_s.singularize}_fields", f: f)
          end
        end
      end
    end
  
    def add_association(options = {}, &block)
      action = 'click->abyme#add_association'
      create_button(action, options, &block)
    end
  
    def remove_association(options = {}, &block)
      action = 'click->abyme#remove_association'
      create_button(action, options, &block)
    end

    private
  
    def create_button(action, options, &block)
      options[:html] ||= {}
      options[:tag] ||= :button
      options[:content] ||= 'Add Association'
  
      if block_given?
        content_tag(options[:tag], { data: { action: action } }.merge(options[:html])) do
          capture(&block)
        end
      else
        content_tag(options[:tag], options[:content], { data: { action: action } }.merge(options[:html]))
      end
    end

    def basic_fields_markup(html, association = nil)
      if html && html[:class]
        html[:class] = "abyme--fields #{association.to_s.singularize}-fields #{html[:class]}" 
      else
        html ||= {}
        html[:class] = "abyme--fields #{association.to_s.singularize}-fields"
      end
      html
    end
  end
end