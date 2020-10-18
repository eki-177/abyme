require_relative "abyme_builder"

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

      wrapper_default = { 
        data: { 
          target: 'abyme.associations', 
          association: association, 
          abyme_position: options[:position] || :end 
        } 
      }

      fields_default = { data: { target: 'abyme.fields abyme.newFields' } }

      content_tag(:div, build_attributes(wrapper_default, options[:wrapper_html])) do
        content_tag(:template, class: "abyme--#{association.to_s.singularize}_template", data: { target: 'abyme.template' }) do
          form.fields_for association, association.to_s.classify.constantize.new, child_index: 'NEW_RECORD' do |f|
            content_tag(:div, build_attributes(fields_default, basic_fields_markup(options[:fields_html], association))) do
              # Here, if a block is passed, we're passing the association fields to it, rather than the form itself
              block_given? ? yield(f) : render(options[:partial] || "abyme/#{association.to_s.singularize}_fields", f: f)
            end
          end
        end
      end
    end
  
    def persisted_records_for(association, form, options = {})
      records = options[:collection] || form.object.send(association)
      options[:wrapper_html] ||= {}
      fields_default = { data: { target: 'abyme.fields' } }
      
      if options[:order].present?
        records = records.order(options[:order])
        # Get invalid records
        invalids = form.object.send(association).reject(&:persisted?)
        records = records.to_a.concat(invalids) if invalids.any?
      end 
      
      content_tag(:div, options[:wrapper_html]) do
        form.fields_for(association, records) do |f|
          content_tag(:div, build_attributes(fields_default, basic_fields_markup(options[:fields_html], association))) do
            block_given? ? yield(f) : render(options[:partial] || "abyme/#{association.to_s.singularize}_fields", f: f)
          end
        end
      end
    end
  
    def add_association(options = {}, &block)
      action = 'click->abyme#add_association'
      options[:content] ||= 'Add Association'
      create_button(action, options, &block)
    end
  
    def remove_association(options = {}, &block)
      action = 'click->abyme#remove_association'
      options[:content] ||= 'Remove Association'
      create_button(action, options, &block)
    end

    private
  
    def create_button(action, options, &block)
      options[:html] ||= {}
      options[:tag] ||= :button
  
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

    def build_attributes(default, attr)
      # ADD NEW DATA ATTRIBUTES VALUES TO THE DEFAULT ONES (ONLY VALUES)
      if attr[:data]
        default[:data].each do |key, value|
          default[:data][key] = "#{value} #{attr[:data][key]}".strip
        end
      # ADD NEW DATA ATTRIBUTES (KEYS & VALUES)
        default[:data] = default[:data].merge(attr[:data].reject { |key, _| default[:data][key] })
      end
      # MERGE THE DATA ATTRIBUTES TO THE HASH OF HTML ATTRIBUTES
      default.merge(attr.reject { |key, _| key == :data })
    end
  end
end