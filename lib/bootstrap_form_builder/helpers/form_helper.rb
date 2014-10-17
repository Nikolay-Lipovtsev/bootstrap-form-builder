module BootstrapFormBuilder
  module Helpers
    module FormHelper
      # Options for form
      #
      # :layout
      # :builder
      # :disabled
      #
      # Common form options for all controls in form:
      #
      # :label_col
      # :control_col
      # :offset_control_col
      # :invisible_label
      # :grid_system
      # :label_disabled
      # :label_offset_col
      #
      # For example, to render a form with invisible labels
      # The HTML generated for this would be (modulus formatting):
      def bootstrap_form_for(object, options = {}, &block)
        options[:html] ||= {}
        options[:html][:role] = "form"
        options[:builder] ||= BootstrapFormBuilder::Helpers::FormBuilder
        options[:html][:class] = [options[:html][:class], "form-#{options[:layout].to_s}"].compact.join(" ") if options[:layout]
        
        disabled(options) { form_for object, options, &block }
      end
      
      private
      
      def disabled(options = {})
        options[:disabled] ? content_tag(:fieldset, "", disabled: true) { yield } : yield
      end
    end 
     
    class FormBuilder < ActionView::Helpers::FormBuilder
      
      BASE_FIELD_HELPERS = %w{color_field date_field datetime_field datetime_local_field
                              email_field month_field number_field password_field phone_field
                              range_field search_field telephone_field text_area text_field time_field
                              url_field week_field}

      CHECK_BOX_AND_RADIO_HELPERS = %w{check_box radio_button}
      
      BASE_FORM_OPTIONS = [:layout, :label_col, :invisible_label, :control_col, :offset_control_col, :grid_system]
      
      def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
        fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
        BASE_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
        fields_for_without_bootstrap record_name, record_object, fields_options, &block
      end

      alias_method_chain :fields_for, :bootstrap
      
      def label(method, content_or_options = nil, options = {}, &block)
        content_or_options, options = options, nil if block_given?
        options = class_for_base_labeles options
        super(method, (content_or_options || options), options, &block) unless options[:label_disabled]
      end
      
      BASE_FIELD_HELPERS.each do |helper|
        define_method(helper) do |field, *args|
          options = args.detect{ |a| a.is_a?(Hash) } || {}
          options = get_base_form_options options
          box_for_base_controls(options) do
            options[:control_col] ||= default_date_col if helper == "date_field"
            options[:placeholder] ||= I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{field}") if options[:placeholder] || options[:invisible_label]
            options[:class] = ["form-control", options[:class]].compact.join(" ")
            super field, options
          end
        end
      end
      
      private
      
      def get_base_form_options(options = {})
        BASE_FORM_OPTIONS.each { |name| options[name] ||= @options[name] if @options[name] }
      end
      
      def box_for_base_controls(options = {})
        content_tag(:div, class: "form-group") { yield }
      end
      
      def class_for_base_labeles(options = {})
        options ||= {}
        invisible = "sr-only" if options[:invisible_label]
        horizontal = "#{ grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system]) } control-label" if options[:layout] == :horizontal
        horizontal << " #{ grid_system_offset_class(options[:label_offset_col], options[:grid_system]) }" if options[:label_offset_col]
        options[:class] = [options[:class], invisible, horizontal].compact.join(" ")
        options.delete_if{ |k, v| [:invisible_label, :label_col, :label_offset_col].include? k }
      end
      
      def has_error?(field, options = {})
        @object.respond_to?(:errors) && !(field.nil? || @object.errors[field].empty?) and !(options[:error_disable])
      end

      def error_message(field)
        if has_error?(field)
          @object.errors[field].collect { |msg| concat(content_tag(:li, msg)) }
        end
      end
    end
  end
end