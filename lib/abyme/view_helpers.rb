module Abyme
  module ViewHelpers

    def abymize(association, form, options = {}, &block)
      content_tag(:div, data: { controller: 'abyme' }, id: "abyme--#{association}") do
        if block_given?
          yield(Abyme::AbymeBuilder.new(association: association, form: form, lookup_context: self.lookup_context))
        else
          model = association.to_s.singularize.classify.constantize
          concat(persisted_records_for(association, form, options))
          concat(new_records_for(association, form, options)) 
          concat(add_association(content: options[:add] || "Add #{model}"))
        end
      end
    end

    def new_records_for(association, form, options = {}, &block)
      content_tag(:div, data: { target: 'abyme.associations', association: association, abyme_position: options[:position] || :end }) do
        content_tag(:template, class: "abyme--#{association.to_s.singularize}_template", data: { target: 'abyme.template' }) do
          form.fields_for association, association.to_s.classify.constantize.new, child_index: 'NEW_RECORD' do |f|
            content_tag(:div, basic_markup(options[:html])) do
              if block_given?
                # Here, f is the fields_for ; f.object becomes association.new rather than the original form.object
                yield(f)
              else
                render "shared/#{association.to_s.singularize}_fields", f: f
              end
            end
          end
        end
      end
    end
  
    def persisted_records_for(association, form, options = {})
      if options[:collection]
        records = options[:collection]
      else
        records = form.object.send(association)
      end
      
      if options[:order].present?
        records = records.order(options[:order])
        
        # GET INVALID RECORDS
        invalids = form.object.send(association).reject(&:persisted?)
        
        if invalids.any?
          records = records.to_a.concat(invalids)
        end
      end

      form.fields_for(association, records) do |f|
        content_tag(:div, basic_markup(options[:html])) do
          if block_given?
            yield(f)
          else
            render "shared/#{association.to_s.singularize}_fields", f: f
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

    def basic_markup(html)

      if html && html[:class]
        html[:class] = 'abyme--fields ' + html[:class]
      else
        html ||= {}
        html[:class] = 'abyme--fields'
      end

      return html
    end

  end
end