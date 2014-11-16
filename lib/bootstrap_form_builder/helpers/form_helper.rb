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
      
      BASE_FORM_OPTIONS = [:invisible_label, :grid_system, :label_class, :label_col, :layout, :control_class, 
                          :control_col, :offset_control_col, :offset_label_col]
    
      BASE_CONTROL_OPTIONS = [:input_group, :label, :help_block, :placeholder]
    
      LABEL_OPTIONS = [:invisible_label, :label, :label_class, :label_col, :label_offset_col]
      
      #Check options in fields_for_with_bootstrap
      
      def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
        fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
        BASE_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
        fields_for_without_bootstrap record_name, record_object, fields_options, &block
      end
      
      alias_method_chain :fields_for, :bootstrap
      
      delegate :content_tag, :capture, :concat, to: :@template
      
      def label(method_name, content_or_options = nil, options = nil, &block)
        options ||= {}
        options.delete(:class)
        content_is_options = content_or_options.is_a? Hash
        options, content_or_options = content_or_options, nil if content_is_options
        base_options "label", options
        unless options[:label_disabled]
          options[:label_class] = [options[:label_class], "sr-only"].compact.join(" ") if options[:invisible_label]
          options[:class] = ["control-label", options[:label_class]].compact.join(" ")
          options = options.slice(:class)
          content_or_options, options = options, nil if content_is_options
          super method_name, content_or_options, options, &block
        end
      end
      
      BASE_CONTROL_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect { |a| a.is_a?(Hash) } || {}
          options[:style] = "error" if has_error?(method_name, options)
          base_options helper, options
          form_group(helper, options) do
            options[:label_class] = [options[:label_class], "control-label #{grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system])}"].compact.join(" ") if options[:layout] == :horizontal
            options[:label_class] = [options[:label_class], "#{grid_system_offset_class(options[:offset_label_col], options[:grid_system])}"].compact.join(" ") if options[:offset_label_col]
            options[:invisible_label] = true if options[:layout] == :inline
            options[:placeholder] ||= options[:label] || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if options[:placeholder] || options[:invisible_label]
            options[:class] = ["form-control", options[:control_class], options[:size]].compact.join(" ")
            error_tag = error_message method_name, options
            helper_tag = super method_name, options.slice(:class, :disabled, :placeholder, :readonly, :rows)
            helper_tag = col_block(helper, options) { input_group_for_base_controls(options) { helper_tag << (icon_tag(options) || "") } << (error_tag || "") }
            [label(method_name, options[:label], options), helper_tag, help_block(options)].join.html_safe
          end
        end
      end
      
      def control_static(method_name, content_or_options = nil, options = nil, &block)
        options, content_or_options = content_or_options, nil if block_given?
        base_options "control_static", options
        form_group("control_static", options) do
          options[:label_class] = [options[:label_class], "control-label #{grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system])}"].compact.join(" ") if options[:layout] == :horizontal
          options[:label_class] = [options[:label_class], "#{grid_system_offset_class(options[:offset_label_col], options[:grid_system])}"].compact.join(" ") if options[:offset_label_col]
          options[:invisible_label] = true if options[:layout] == :inline
          options[:placeholder] ||= options[:label] || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if options[:placeholder] || options[:invisible_label]
          options[:class] = ["form-control-static", options[:control_class], options[:size]].compact.join(" ")
          content = block_given? ? yield : content_or_options
          helper_tag = col_block("control_static", options) { content_tag(:p, content, options.slice(:class)) }
          [label(method_name, options[:label], options), helper_tag, help_block(options)].join.html_safe
        end
      end
      
      def check_box(method_name, options = {}, checked_value = "1", unchecked_value = "0")
        base_options "check_box", options
        form_group("check_box", options) do
          col_block("check_box", options) do
            block_for_check_box_and_radio_button("checkbox", options) do
              options[:class] = options[:control_class] if options[:control_class]
              content = super method_name, options.slice(:class, :checked, :disabled, :multiple, :readonly), checked_value, unchecked_value
              content = [content, options[:label]].join.html_safe
              options[:class] = options[:label_class]
              options[:class] = [options[:class], "checkbox-inline"].compact.join(" ") if options[:inline]
              helper_tag = @template.label_tag nil, content, options.slice(:class)
              [helper_tag, help_block(options)].join.html_safe
            end
          end
        end
      end
      
      def radio_button(method_name, tag_value, options = {})
        base_options "radio_button", options
        form_group("radio_button", options) do
          col_block("radio_button", options) do
            block_for_check_box_and_radio_button("radio", options) do
              options[:class] = options[:control_class] if options[:control_class]
              content = super method_name, tag_value, options.slice(:class, :checked, :disabled, :multiple, :readonly)
              content = [content, options[:label]].join.html_safe
              options[:class] = options[:label_class]
              options[:class] = [options[:class], "radio-inline"].compact.join(" ") if options[:inline]
              helper_tag = @template.label_tag nil, content, options.slice(:class)
              [helper_tag, help_block(options)].join.html_safe
            end
          end
        end
      end
      
      def collection_check_boxes(method, collection, value_method, text_method, options = {})
        form_group("check_box", options) do
          col_block("check_box", options) do
            helper_tags = ""
            checked, options[:checked] = options[:checked], nil if options[:checked]
            collection.each do |object|
              options[:multiple] = true
              options[:form_group_disabled] = true
              options[:col_block_disabled] = true
              options[:checked], checked = true, nil if (checked && object.send(value_method) && checked.to_s == object.send(value_method).to_s) || checked == true
              options[:label] = object.send text_method
              checked_value = value_method ? object.send(value_method) : "1"
              helper_tags << check_box(method, options, checked_value, nil)
              options[:checked] = nil
            end
            options[:value] = ""
            helper_tags << hidden_field(method, options)
            helper_tags.html_safe
          end
        end
      end
      
      def collection_radio_buttons(method, collection, value_method, text_method, options = {})
        form_group("radio_button", options) do
          col_block("radio_button", options) do
            helper_tags = ""
            checked, options[:checked] = options[:checked], nil if options[:checked]
            collection.each do |object|
              options[:form_group_disabled] = true
              options[:col_block_disabled] = true
              options[:checked], checked = true, nil if (checked && object.send(value_method) && checked.to_s == object.send(value_method).to_s) || checked == true
              options[:label] = object.send text_method
              tag_value = value_method ? object.send(value_method) : "1"
              helper_tags << radio_button(method, tag_value, options)
              options[:checked] = nil
            end
            helper_tags.html_safe
          end
        end
      end
      
      def select(method, choices = nil, options = {}, html_options = {}, &block)
        base_options "select", options
        form_group("select", options) do
          html_options[:class] = ["form-control", options[:control_class], options[:size]].compact.join(" ")
          helper_tag = col_block("select", options) { super method, choices, options, html_options, &block }
          [helper_tag, help_block(options)].join.html_safe
        end
      end
      
      def button(content_or_options = nil, options = {}, &block)
        content_is_options = content_or_options.is_a? Hash
        options, content_or_options = content_or_options, nil if content_is_options
        base_options "btn", options
        form_group("btn", options) do
          col_block("btn", options) do
            options[:class] = options[:control_class]
            options = options.slice(:active, :col, :style, :size, :disabled)
            content_or_options, options = options, nil if content_is_options
            @template.button_tag content_or_options, options, &block
          end
        end
      end
      
      def button_link(name = nil, options = {}, html_options = {}, &block)
        base_options "btn", options
        form_group("btn", options) do
          col_block("btn", options) do
            options[:class] = options[:control_class]
            options = options.slice(:active, :col, :style, :size, :disabled)
            @template.button_link_tag name, options, html_options, &block
          end
        end
      end
      
      def submit(value = nil, options = {})
        base_options "btn", options
        form_group("btn", options) do
          col_block("btn", options) do
            options[:class] = options[:control_class]
            options = options.slice(:active, :col, :style, :size, :disabled)
            @template.submit_tag value, options
          end
        end
      end
      
      def button_input(value = nil, options = {})
        content_is_options = content_or_options.is_a? Hash
        base_options "btn", options
        form_group("btn", options) do
          col_block("btn", options) do
            options[:class] = options[:control_class]
            options = options.slice(:active, :class, :col, :style, :size, :disabled)
            @template.button_input_tag value, options
          end
        end
      end
      
      def bootstrap_form_group(options = {})
        base_options nil, options
        form_group(nil, options) do
          col_block(nil, options) { yield }
        end
      end
      
      private
    
      def base_options(helper = nil, options = {})
        options ||= {}
        BASE_FORM_OPTIONS.each{ |name| options[name] ||= @options[name] if @options[name] }
        
        options[:disabled] = "disabled" if options[:disabled]
        options[:readonly] = "readonly" if options[:readonly]
        options[:checked] = "checked" if options[:checked]
        options[:form_group_size] = "form-group-#{options[:form_group_size]}" if options[:form_group_size]
        options[:size] = "input-#{options.delete(:size)}" if options[:size] && helper != "btn"
        options[:style] = "has-#{options.delete(:style)}" if options[:style] && helper != "btn"
      end
      
      def form_group(helper = nil, options = {})
        if options[:form_group_disabled]
          yield
        elsif ["check_box", "radio_button", "btn"].include?(helper) && options[:layout] != :horizontal
          options[:style] && helper != "btn" ? content_tag(:div, class: options[:style]) { yield } : yield
        else
          options[:form_group_class] = [options[:form_group_class], "has-feedback"].compact.join(" ") if options[:icon]
          options[:class] = ["form-group", options[:form_group_class], options[:form_group_size], options[:style]].compact.join(" ")
          content_tag(:div, options.slice(:class)) { yield }
        end
      end

      def input_group_for_base_controls(options = {})
        if options[:input_group]
          position, type, value, size = options[:input_group][:type].to_s.sub(/_\w+/, ""), options[:input_group][:type].to_s.sub(/\w+_/, ""), options[:input_group][:value], options[:input_group][:size]
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
      
      def block_for_check_box_and_radio_button(helper, options = {})
        options[:inline] ? yield : content_tag(:div, class: helper) { yield }
      end
    
      def input_group_spen(type = nil, value = nil)
        if type == "char"
          spen_class = "input-group-addon"
        elsif type == "button"
          spen_class = "input-group-btn"
        end
        content_tag :spen, value, class: spen_class
      end
      
      def icon_tag(options = {})
        if options[:icon]
          if options[:icon].include? "fa-"
            content_tag(:spen, class: "glyphicon form-control-feedback") { content_tag :i, "", class: "#{options[:icon]}" }
          else
            content_tag :spen, "", class: "glyphicon glyphicon-#{options[:icon]} form-control-feedback"
          end
        end
      end
    
      def help_block(options = {})
        content_tag :p, options[:help_block], class: "help-block" if options[:help_block]
      end
      
      def col_block(helper = nil, options = {})
        if options[:col_block_disabled] || options[:form_group_disabled] || options[:layout] != :horizontal
          yield
        else
          options[:offset_control_col] ||= default_horizontal_label_col if ["check_box", "radio_button", "btn", "select", "collection"].include?(helper)
          bootstrap_col(col: (options[:control_col] || default_horizontal_control_col), grid_system: options[:grid_system], offset_col: options[:offset_control_col]) { yield }
        end
      end
    
      def has_error?(method_name, options = {})
        @object.respond_to?(:errors) && !(@object.errors[method_name].empty?) && !(options[:error_disabled])
      end

      def error_message(method_name, options = {})
        content_tag(:ui, class: "text-danger") { @object.errors[method_name].collect { |msg| concat(content_tag(:li, msg)) }} if has_error?(method_name, options)
      end
    end
  end
end