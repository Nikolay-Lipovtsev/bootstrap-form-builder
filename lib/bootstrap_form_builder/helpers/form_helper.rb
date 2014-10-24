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
      # :label_class
      # :control_class
      # :placeholder
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
      
      BASE_CONTROL_HELPERS = %w{color_field date_field datetime_field datetime_local_field email_field month_field 
                                number_field password_field phone_field range_field search_field telephone_field 
                                text_area text_field time_field url_field week_field}

      CHECK_BOX_AND_RADIO_HELPERS = %w{check_box radio_button}
      
      BASE_FORM_OPTIONS = [:invisible_label, :grid_system, :label_class, :label_col, :layout, :control_class, 
                          :control_col, :offset_control_col, :offset_label_col]
      
      BASE_CONTROL_OPTIONS = [:label_text, :help_block, :placeholder]
      
      def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
        fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
        BASE_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
        fields_for_without_bootstrap record_name, record_object, fields_options, &block
      end

      alias_method_chain :fields_for, :bootstrap
      
      delegate :content_tag, :capture, :concat, to: :@template
      
      def label(method_name, content_or_options = nil, options = nil, &block)
        options ||= {}
        content_is_options = content_or_options.is_a? Hash
        options, content_or_options = content_or_options, nil if content_is_options
        unless options[:label_disabled]
          options = class_for_base_labeles options
          options[:label_text]
          content_or_options, options = options, nil if content_is_options
          super method_name, content_or_options, options, &block
        end
      end
      
      BASE_CONTROL_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect{ |a| a.is_a?(Hash) } || {}
          options = get_base_form_options options
          form_group_for_base_controls(options) do
            options = options.slice(*BASE_CONTROL_OPTIONS.push(*BASE_FORM_OPTIONS))
            bootstrap_label_tag = label(method_name, options[:label_text], options) || ""
            options[:placeholder] ||= I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if options[:placeholder] || options[:invisible_label]
            options[:class] = ["form-control", options[:control_class]].compact.join(" ")
            bootstrap_helper_tag = super(method_name, options) || ""
            bootstrap_help_block = help_block(options[:help_block]) || ""
            bootstrap_all = bootstrap_label_tag << bootstrap_helper_tag << bootstrap_help_block
          end
        end
      end
      
      private
    
      def get_base_form_options(options = {})
        BASE_FORM_OPTIONS.each{ |name| options[name] ||= @options[name] if @options[name] }
        options
      end
      
      def form_group_for_base_controls(options = {})
        options[:class] = ["form-group", options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end
      
      def class_for_base_labeles(options = nil)
        options ||= {}
        invisible = "sr-only" if options[:invisible_label]
        horizontal = "#{ grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system]) } control-label" if options[:layout] == :horizontal
        horizontal << " #{ grid_system_offset_class(options[:label_offset_col], options[:grid_system]) }" if options[:offset_label_col]
        options[:class] = [options[:label_class]].compact.join(" ")
        options.delete_if do |k, v| 
          [:invisible_label, :label_class, :label_col, :label_offset_col].include? k
          v.empty?
        end
      end
      
      def help_block(content)
        content_tag :p, content, class: "help-block" if content
      end
      
      def has_error?(method_name, options = {})
        @object.respond_to?(:errors) && !(field.nil? || @object.errors[method_name].empty?) and !(options[:error_disable])
      end

      def error_message(method_name)
        @object.errors[method_name].collect { |msg| concat(content_tag(:li, msg)) } if has_error?(method_name)
      end
    end
  end
end