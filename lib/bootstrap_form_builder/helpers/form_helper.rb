require "bootstrap_form_builder/helpers/form_tag_helper"
require "bootstrap_form_builder/helpers/grid_system_helper"

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
        options[:disabled] ? content_tag(:fieldset, disabled: true) { yield } : yield
      end
    end
    
    class FormBuilder < ActionView::Helpers::FormBuilder
      
      include BootstrapFormBuilder::Helpers::FormTagHelper
      include BootstrapFormBuilder::Helpers::GridSystemHelper
      
      BASE_CONTROL_HELPERS = %w{color_field date_field datetime_field datetime_local_field email_field month_field 
                                number_field password_field phone_field range_field search_field telephone_field 
                                text_area text_field time_field url_field week_field}

      CHECK_BOX_AND_RADIO_HELPERS = %w{check_box radio_button}
      
      BASE_FORM_OPTIONS = [:invisible_label, :grid_system, :label_class, :label_col, :layout, :control_class, 
                          :control_col, :offset_control_col, :offset_label_col]
    
      BASE_CONTROL_OPTIONS = [:input_group, :label, :help_block, :placeholder]
    
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
        options_for_base_controls options unless @options_is_set
        unless @label_disabled
          @label_class = [@label_class, "sr-only"].compact.join(" ") if @invisible_label
          options[:class] = @label_class if @label_class
          content_or_options, options = options, nil if content_is_options
          super method_name, content_or_options, options, &block
        end
      end
    
      BASE_CONTROL_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect { |a| a.is_a?(Hash) } || {}
          options_for_base_controls options
          form_group_for_base_controls(helper) do
            @label_class = [@label_class, "control-label #{grid_system_class((@label_col || default_horizontal_label_col), @grid_system)}"].compact.join(" ") if @layout == :horizontal
            @label_class = [@label_class, "#{grid_system_offset_class(@offset_label_col, @grid_system)}"].compact.join(" ") if @offset_label_col
            @invisible_label = true if @layout == :inline
            options[:placeholder] ||= @label || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if @placeholder || @invisible_label
            options[:class] = ["form-control", @control_class, @size].compact.join(" ")
            bootstrap_helper_tag = control_col_block(helper) { input_group_for_base_controls { super(method_name, options) << (icon_tag || "") }}
            [label(method_name, @label), bootstrap_helper_tag, help_block].join.html_safe
          end
        end
      end
    
      CHECK_BOX_AND_RADIO_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect { |a| a.is_a?(Hash) } || {}
          options_for_base_controls options
          form_group_for_base_controls(helper) do
            control_col_block(helper) do
              content_tag(:div, class: helper.to_s.gsub("_", "").gsub("button", "")) do
                content = [super(method_name), @label].join.html_safe
                bootstrap_helper_tag = label method_name, content
                [bootstrap_helper_tag, help_block].join.html_safe
              end
            end
          end
        end
      end
      
      def control_static(content_or_options = nil, options = nil, &block)
        options = content_or_options
        options_for_base_controls options
        form_group_for_base_controls(helper) do
          @label_class = [@label_class, "control-label #{grid_system_class((@label_col || default_horizontal_label_col), @grid_system)}"].compact.join(" ") if @layout == :horizontal
          @label_class = [@label_class, "#{grid_system_offset_class(@offset_label_col, @grid_system)}"].compact.join(" ") if @offset_label_col
          @invisible_label = true if @layout == :inline
          options[:placeholder] ||= @label || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if @placeholder || @invisible_label
          options[:class] = ["form-control", @control_class, @size].compact.join(" ")
          bootstrap_helper_tag = control_col_block(helper) { input_group_for_base_controls { super(method_name, options) << (icon_tag || "") }}
          [label(method_name, @label), bootstrap_helper_tag, help_block].join.html_safe
        end
      end
      
      def button(content_or_options = nil, options = nil, &block)
        @form_group_class = nil
        form_group_for_base_controls("btn") do
          control_col_block("btn") do
            @template.button_tag content_or_options, options, &block
          end
        end
      end
      
      def button_link(name = nil, options = nil, html_options = {}, &block)
        form_group_for_base_controls("btn") do
          control_col_block("btn") do
            @template.button_link_tag name, options, html_options, &block
          end
        end
      end
      
      def submit(value = nil, options = nil)
        form_group_for_base_controls("btn") do
          control_col_block("btn") do
            @template.submit_tag value, options
          end
        end
      end
      
      def button_input(value = nil, options = nil)
        form_group_for_base_controls("btn") do
          control_col_block("btn") do
            @template.button_input_tag value, options
          end
        end
      end
      
      private
    
      def options_for_base_controls(options = nil)
        options ||= {}
        BASE_FORM_OPTIONS.each{ |name| options[name] ||= @options[name] if @options[name] }
        
        options[:disabled] = "disabled" if options[:disabled]
        options[:readonly] = "readonly" if options[:readonly]
        @control_class = options[:control_class]
        @control_col = options[:control_col]
        @size = options[:size] ? "input-#{options[:size]}" : nil
        @form_group_class = options[:class]
        @form_group_size = options[:form_group_size] ? "form-group-#{options[:form_group_size]}" : nil
        @style = options[:style] ? "has-#{options[:style]}" : nil
        @help_block = options[:help_block]
        @icon = options[:icon]
        @input_group = options[:input_group]
        @invisible_label = options[:invisible_label]
        @grid_system = options[:grid_system]
        @label = options[:label]
        @label_class = options[:label_class]
        @label_col = options[:label_col]
        @label_disabled = options[:label_disabled]
        @layout = options[:layout]
        @offset_control_col = options[:offset_control_col]
        @offset_label_col = options[:offset_label_col]
        @options_is_set = true
        @placeholder = options[:placeholder]
      
        options.delete_if { |k, v| [:class, :control_class, :control_col, :size, :form_group_class, 
                                    :form_group_size, :style, :help_block, :icon, :input_group, :invisible_label,  
                                    :grid_system, :label, :label_class, :label_col, :label_disabled, :layout, 
                                    :control_class, :control_col, :offset_control_col, :offset_label_col, 
                                    :placeholder].include? k || v.empty? }
      end
    
      def input_group_for_base_controls
        if @input_group
          position, type, value, size = @input_group[:type].to_s.sub(/_\w+/, ""), @input_group[:type].to_s.sub(/\w+_/, ""), @input_group[:value], @input_group[:size] if @input_group
          size = "input-group-#{size}" if size
          content_tag(:div, class: ["input-group", size].compact.join(" ")) do
            spen_left = input_group_spen(type, value) if position == "left"
            spen_right = input_group_spen(type, value) if position == "right"
            [spen_left, yield, spen_right].join.html_safe
          end
        else
          yield
        end
      end
    
      def input_group_spen(type = nil, value = nil)
        if type == "char"
          spen_class = "input-group-addon"
        elsif type == "button"
          spen_class = "input-group-btn"
        end
        content_tag :spen, value, class: spen_class
      end
      
      def icon_tag
        if @icon
          if @icon.include? "fa-"
            content_tag(:spen, class: "glyphicon form-control-feedback") { content_tag :i, "", class: "#{@icon}" }
          else
            content_tag :spen, "", class: "glyphicon glyphicon-#{@icon} form-control-feedback"
          end
        end
      end
    
      def form_group_for_base_controls(helper = nil)
        if ["check_box", "radio_button", "btn"].include?(helper) && @layout != :horizontal
          @style && helper != "btn" ? content_tag(:div, class: @style) { yield } : yield
        else
          @form_group_class = [@form_group_class, "has-feedback"].compact.join(" ") if @icon
          form_group_class = ["form-group", @form_group_class, @form_group_size, @style].compact.join(" ")
          content_tag(:div, class: form_group_class) { yield }
        end
      end
    
      def help_block
        content_tag :p, @help_block, class: "help-block" if @help_block
      end
      
      def control_col_block(helper = nil)
        if @layout == :horizontal
          @offset_control_col ||= default_horizontal_label_col if ["check_box", "radio_button", "btn"].include?(helper)
          bootstrap_col(col: (@control_col || default_horizontal_control_col), grid_system: @grid_system, offset_col: @offset_control_col) { yield }
        else
          yield
        end
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