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
      
      BASE_CONTROL_OPTIONS = [:label, :help_block, :placeholder, :input_group]
      
      LABEL_OPTIONS = [:invisible_label, :label, :label_class, :label_col, :label_offset_col]
      
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
            options[:invisible_label] = true if options[:layout] == :inline
            options[:placeholder] ||= options[:label] || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if options[:placeholder] || options[:invisible_label]
            bootstrap_help_block = help_block options
            bootstrap_label_tag = label method_name, options[:label], options
            options[:class] = ["form-control", options[:control_class]].compact.join(" ")
            bootstrap_helper_tag = input_group_for_base_controls(options) { super method_name, options }
            [bootstrap_label_tag, bootstrap_helper_tag, bootstrap_help_block].join.html_safe
          end
        end
      end
      
      CHECK_BOX_AND_RADIO_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect{ |a| a.is_a?(Hash) } || {}
          options = get_base_form_options options
          content_tag(:div, class: "checkbox") do
            #Add options.slice(*BASE_CONTROL_OPTIONS.push(*BASE_FORM_OPTIONS))
            bootstrap_help_block = help_block options
            label_content = [super(method_name, options.except(*LABEL_OPTIONS)), options[:label]].join.html_safe
            bootstrap_label_tag = label method_name, label_content, options
            [bootstrap_label_tag, bootstrap_help_block].join.html_safe
          end
        end
      end
      
      private
      
      def input_group_for_base_controls(options = nil)
        if options[:input_group]
          position, type, value, size = options[:input_group][:type].to_s.sub(/_\w+/, ""), options[:input_group][:type].to_s.sub(/\w+_/, ""), options[:input_group][:value], options[:input_group][:size] if options[:input_group]
          size = "input-group-#{size}" if size
          content_tag(:div, class: ["input-group", size].compact.join(" ")) do
            spen_left = spen_for_input_group(type, value) if position == "left"
            spen_right = spen_for_input_group(type, value) if position == "right"
            options.delete(:input_group)
            [spen_left, yield, spen_right].join.html_safe
          end
        else
          yield
        end
      end
      
      def spen_for_input_group(type = nil, value = nil)
        if type == "char"
          content_tag :spen, value, class: "input-group-addon"
        else
          #content_tag(:spen, class: "input-group-addon") { }
        end
      end
      
      def get_base_form_options(options = nil)
        options ||= {}
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
        horizontal = "control-label #{ grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system]) }" if options[:layout] == :horizontal
        horizontal = [horizontal, "#{ grid_system_offset_class(options[:label_offset_col], options[:grid_system]) }"].compact.join(" ") if options[:offset_label_col]
        options[:class] = [options[:label_class], invisible, horizontal].compact.join(" ")
        options.delete_if do |k, v| 
          LABEL_OPTIONS.include? k || v.empty?
        end
      end
      
      def help_block(options = nil)
        content = options.delete(:help_block)
        content_tag :p, content, class: "help-block" if content
      end
      
      def has_error?(method_name, options = nil)
        @object.respond_to?(:errors) && !(field.nil? || @object.errors[method_name].empty?) and !(options[:error_disable])
      end

      def error_message(method_name)
        @object.errors[method_name].collect { |msg| concat(content_tag(:li, msg)) } if has_error?(method_name)
      end
    end
  end
end