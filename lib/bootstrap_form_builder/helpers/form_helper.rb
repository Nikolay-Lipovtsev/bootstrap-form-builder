require "bootstrap_form_builder/helpers/form_tag_helper"
require "bootstrap_form_builder/helpers/grid_system_helper"

module BootstrapFormBuilder
  module Helpers
    # Provides a number of methods for creating a simple forms with Bootstrap style
    module FormHelper
      
      # Creates a form tag with bootstrap class.
      # === Options
      # You can use only symbols for the attribute names.
      # 
      # <tt>:control_class</tt> this value will be added to the value of the class controls all controls of the form.
      #
      # <tt>:control_col</tt> if you set a value in the range grid system for Bootstrap (1..12), the default size of the
      # controls in all the form fields will be changed. The default size (2) value is not set. This only applies to
      # horizontal forms.
      #
      # <tt>:disabled</tt> if set to true, it should generate fieldset tag with a disabled option around fields inside
      # form tag.
      #
      # <tt>:invisible_label</tt> if set to true, then this should make invisible all the labels in all fields within
      # the form, except for checkboxes and radio buttons.
      #
      # <tt>:form_group_disabled</tt> if set to true, then this should disable all forms groups in all fields within
      # the form.
      #
      # <tt>:grid_system</tt> if set the value of a range of grid system for Bootstrap ("xs", "sm", "md", "lg"), 
      # the default size of all fields will be changed to the set. For default grid system ("md") value is not set.
      #
      # <tt>:label_class</tt> this value will be added to the value of the class labels all labels of the form.
      #
      # <tt>:label_col</tt> if you set a value in the range grid system for Bootstrap (1..12), the default size of the
      # labels in all the form fields will be changed. The default size (2) value is not set. This only applies to
      # horizontal forms.
      #
      # <tt>:layout</tt> this value sets the style for the form Bootstrap. By default, this is the basic style, but it
      # can be set in :horizontal or :inline.
      #
      # <tt>:offset_control_col</tt> if you set a value in the range grid system for Bootstrap (1..12), the default
      # offset_col of the controls in all the form fields will be changed. The default offset_col (2) value is not set.
      # This only applies to horizontal forms.
      #
      # <tt>:offset_label_col</tt> if you set a value in the range grid system for Bootstrap (1..12), the default
      # offset_col of the lables in all the form fields will be changed. The default offset_col (2) value is not set.
      # This only applies to horizontal forms.
      #
      # === Examples
      # bootstrap_form_for @user, url: { action: "create" } do |user_f|
      #   ...
      # end
      # # => <form accept-charset="UTF-8" action="/users" class="new_user" id="new_user" method="post" role="form">
      #         <div style="display:none"><input name="utf8" type="hidden" value="✓">
      #           <input name="authenticity_token" type="hidden" value="/xWrku1kPx13LYYoYonTdATfLTkWQHTHL+eATnqoQQg=">
      #           ...
      #         </div>
      #      </form>
      #
      def bootstrap_form_for(object, options = {}, &block)
        options[:html] ||= {}
        options[:html][:role] = "form"
        options[:builder] ||= BootstrapFormBuilder::Helpers::FormBuilder
        options[:html][:class] = ["form-#{options[:layout].to_s}", options[:html][:class]].compact.join(" ") if options[:layout]
        
        disabled(options) { form_for object, options, &block }
      end
      
      private
      
      def disabled(options = {})
        options[:disabled] ? content_tag(:fieldset, disabled: true) { yield } : yield
      end
    end
    
    # Provides a number of methods for creating a simple fields with Bootstrap style
    class FormBuilder < ActionView::Helpers::FormBuilder
      
      include BootstrapFormBuilder::Helpers::FormTagHelper
      include BootstrapFormBuilder::Helpers::GridSystemHelper
      
      BASE_CONTROL_HELPERS = %w{color_field date_field datetime_field datetime_local_field email_field month_field 
                                number_field password_field phone_field range_field search_field telephone_field 
                                text_area text_field time_field url_field week_field}
      
      COLLECTION_HELPERS = %w{collection_check_boxes collection_radio_buttons}
      
      BASE_FORM_OPTIONS = [:control_class, :control_col, :invisible_label, :form_group_disabled, :grid_system, 
                          :label_class, :label_col, :layout, :offset_control_col, :offset_label_col]
    
      BASE_CONTROL_OPTIONS = [:input_group, :label, :help_block, :placeholder]
    
      LABEL_OPTIONS = [:invisible_label, :label, :label_class, :label_col, :label_offset_col]
      
      #Check options in fields_for_with_bootstrap
      
      def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
        fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
        BASE_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
        fields_for_without_bootstrap record_name, record_object, fields_options, &block
      end
      
      alias_method_chain :fields_for, :bootstrap
      
      delegate  :button_input_tag, :button_link_tag, :button_tag, :content_tag, :capture, :concat, :label_tag, 
                :submit_tag, to: :@template
      
      def label(method_name, content_or_options = nil, options = {}, &block)
        content_is_options = content_or_options.is_a? Hash
        options, content_or_options = content_or_options, nil if content_is_options
        unless options[:label_disabled]
          options[:label_class] = ["control-label", options[:label_class]].compact.join(" ")
          options[:label_class] = [options[:label_class], "#{grid_system_class((options[:label_col] || default_horizontal_label_col), options[:grid_system])}"].compact.join(" ") if options[:layout] == :horizontal
          options[:label_class] = [options[:label_class], "#{grid_system_offset_class(options[:offset_label_col], options[:grid_system])}"].compact.join(" ") if options[:offset_label_col]
          options[:label_class] = [options[:label_class], "sr-only"].compact.join(" ") if options[:invisible_label] || options[:layout] == :inline
          options[:class] = options[:label_class]
          options = options.slice(:class)
          content_or_options, options = options, nil if content_is_options
          super method_name, content_or_options, options, &block
        end
      end
      
      BASE_CONTROL_HELPERS.each do |helper|
        define_method(helper) do |method_name, *args|
          options = args.detect { |a| a.is_a?(Hash) } || {}
          form_group_builder(helper, method_name, options) do
            options[:class] = ["form-control", options[:control_class], options[:size]].compact.join(" ")
            icon_tag = icon_block(options) || ""
            help_tag = help_block(options) || ""
            error_tag = error_message(method_name, options) || ""
            helper_tag = super method_name, options.slice(:class, :disabled, :placeholder, :readonly, :rows)
            helper_tag = col_block(helper, options) { [input_group_for_base_controls(options) { [helper_tag, icon_tag].join.html_safe }, help_tag, error_tag].join.html_safe }
            [label(method_name, options[:label], options), helper_tag].join.html_safe
          end
        end
      end
      
      def control_static(method_name, content_or_options = nil, options = nil, &block)
        helper = "control_static"
        options, content_or_options = content_or_options, nil if block_given?
        form_group_builder(helper, method_name, options) do
          options[:class] = ["form-control-static", options[:control_class], options[:size]].compact.join(" ")
          helper_tag = block_given? ? yield : content_or_options
          helper_tag = col_block(helper, options) { content_tag(:p, helper_tag, options.slice(:class)) }
          [label(method_name, options[:label], options), helper_tag, help_block(options)].join.html_safe
        end
      end
      
      def check_box(method_name, options = {}, checked_value = "1", unchecked_value = "0")
        helper = "check_box"
        form_group_builder(helper, method_name, options) do
          col_block(helper, options) do
            block_for_check_box_and_radio_button(helper, options) do
              options[:class] = options[:control_class] if options[:control_class]
              helper_tag = super method_name, options.slice(:class, :checked, :disabled, :multiple, :readonly), checked_value, unchecked_value
              helper_tag = [helper_tag, options[:label]].join.html_safe
              options[:label_class] = [options[:label_class], "#{helper.to_s.gsub(/(_)+(button)?/, "")}-inline"].compact.join(" ") if options[:inline]
              options[:class] = options[:label_class]
              helper_tag = label_tag nil, helper_tag, options.slice(:class)
              error_tag = error_message method_name, options
              [helper_tag, help_block(options), error_tag].join.html_safe
            end
          end
        end
      end
      
      def radio_button(method_name, tag_value, options = {})
        helper = "radio_button"
        form_group_builder(helper, method_name, options) do
          col_block(helper, options) do
            block_for_check_box_and_radio_button(helper, options) do
              options[:class] = options[:control_class] if options[:control_class]
              helper_tag = super method_name, tag_value, options.slice(:class, :checked, :disabled, :multiple, :readonly)
              helper_tag = [helper_tag, options[:label]].join.html_safe
              options[:label_class] = [options[:label_class], "#{helper.to_s.gsub(/(_)+(button)?/, "")}-inline"].compact.join(" ") if options[:inline]
              options[:class] = options[:label_class]
              helper_tag = label_tag nil, helper_tag, options.slice(:class)
              error_tag = error_message method_name, options
              [helper_tag, help_block(options), error_tag].join.html_safe
            end
          end
        end
      end
      
      COLLECTION_HELPERS.each do |helper|
        define_method(helper) do |method_name, collection, value_method, text_method, *args|
          options = args.detect { |a| a.is_a?(Hash) } || {}
          form_group_builder(helper, method_name, options) do
            col_block(helper, options) do
              helper_tags, options[:form_group_disabled], options[:col_block_disabled] = "", true, true
              checked, options[:checked] = options[:checked], nil if options[:checked]
              options[:multiple] = true if helper == "collection_check_boxes"
              collection.each do |object|
                options[:checked], checked = true, nil if (checked && object.send(value_method) && checked.to_s == object.send(value_method).to_s) || checked == true
                options[:label] = object.send text_method
                tag_value = value_method ? object.send(value_method) : "1"
                helper == "collection_check_boxes" ? helper_tags << check_box(method_name, options, tag_value, nil) : helper_tags << radio_button(method_name, tag_value, options)
                options[:checked] = false
              end
              options[:value] = "" if helper == "collection_check_boxes"
              helper_tags << hidden_field(method_name, options) if helper == "collection_check_boxes"
              helper_tags.html_safe
            end
          end
        end
      end
      
      def select(method_name, choices = nil, select_options = {}, options = {}, &block)
        helper = "select"
        form_group_builder(helper, method_name, options) do
          options[:class] = ["form-control", options[:control_class], options[:size]].compact.join(" ")
          help_tag = help_block(options) || ""
          error_tag = error_message(method_name, options) || ""
          helper_tag = super method_name, choices, select_options, options.slice(:class, :disabled, :placeholder, :readonly, :rows), &block
          helper_tag = col_block(helper, options) { [helper_tag, help_tag, error_tag].join.html_safe }
          [label(method_name, options[:label], options), helper_tag].join.html_safe
        end
      end
      
      def button(content_or_options = nil, options = {}, &block)
        helper = "btn"
        content_is_options = content_or_options.is_a? Hash
        options, content_or_options = content_or_options, nil if content_is_options
        form_group_builder(helper, nil, options) do
          col_block(helper, options) do
            options.delete(:class)
            options[:class] = options[:control_class] if options[:control_class]
            options = options.slice(:active, :class, :col, :style, :size, :disabled)
            content_or_options, options = options, nil if content_is_options
            button_tag content_or_options, options, &block
          end
        end
      end
      
      def button_link(name = nil, options = {}, html_options = {}, &block)
        helper = "btn"
        form_group_builder(helper, nil, options) do
          col_block(helper, options) do
            options.delete(:class)
            options[:class] = options[:control_class] if options[:control_class]
            options = options.slice(:active, :class, :col, :style, :size, :disabled)
            button_link_tag name, options, html_options, &block
          end
        end
      end
      
      def submit(value = nil, options = {})
        helper = "btn"
        form_group_builder(helper, nil, options) do
          col_block(helper, options) do
            options.delete(:class)
            options[:class] = options[:control_class] if options[:control_class]
            options = options.slice(:active, :class, :col, :style, :size, :disabled)
            submit_tag value, options
          end
        end
      end
      
      def button_input(value = nil, options = {})
        helper = "btn"
        content_is_options = content_or_options.is_a? Hash
        form_group_builder(helper, nil, options) do
          col_block(helper, options) do
            options.delete(:class)
            options[:class] = options[:control_class] if options[:control_class]
            options = options.slice(:active, :class, :col, :style, :size, :disabled)
            button_input_tag value, options
          end
        end
      end
      
      def form_group(options = {})
        helper = "form_group_builder"
        form_group_builder(helper, nil, options) do
          col_block(helper, options) { yield }
        end
      end
      
      private
      
      def form_group_builder(helper, method_name, options = {})
        base_options helper, method_name, options
        if options[:form_group_disabled]
          yield
        elsif ["check_box", "radio_button", "btn"].include?(helper) && options[:layout] != :horizontal
          options[:style] && helper != "btn" ? content_tag(:div, class: options[:style]) { yield } : yield
        else
          options[:class] = ["form-group", options[:form_group_class], options[:form_group_size], options[:style]].compact.join(" ")
          content_tag(:div, options.slice(:class)) { yield }
        end
      end
      
      def base_options(helper, method_name, options = {})
        options ||= {}
        BASE_FORM_OPTIONS.each{ |name| options[name] ||= @options[name] if @options[name] }
        
        options[:checked] = "checked" if options[:checked]
        options[:disabled] = "disabled" if options[:disabled]
        options[:form_group_class] = ["has-feedback", options[:form_group_class]].compact.join(" ") if options[:icon]
        options[:form_group_size] = "form-group-#{options.delete(:size)}" if options[:size] && options[:layout] == :horizontal
        options[:placeholder] ||= options[:label] || I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{method_name.to_s}") if (options[:placeholder] || options[:invisible_label] || options[:layout] == :inline) && [*BASE_CONTROL_HELPERS].include?(helper)
        options[:readonly] = "readonly" if options[:readonly]
        options[:size] = "input-#{options.delete(:size)}" if options[:size] && helper != "btn"
        options[:style] = "has-#{options.delete(:style)}" if options[:style] && helper != "btn"
        options[:style] = "has-error" if has_error?(method_name, options) && !(["btn", "control_static", "label"].include?(helper))
      end
      
      def col_block(helper = nil, options = {})
        if options[:col_block_disabled] || options[:layout] != :horizontal
          yield
        else
          options[:offset_control_col] ||= default_horizontal_label_col if ["check_box", "radio_button", "btn", "collection"].include?(helper)
          options[:control_col] ||= default_horizontal_control_col
          bootstrap_col(col: (options[:control_col]), grid_system: options[:grid_system], offset_col: options[:offset_control_col]) { yield }
        end
      end
      
      def block_for_check_box_and_radio_button(helper, options = {})
        options[:inline] ? yield : content_tag(:div, class: helper.to_s.gsub(/(_)+(button)?/, "")) { yield }
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
    
      def input_group_spen(type = nil, value = nil)
        if type == "char"
          spen_class = "input-group-addon"
        elsif type == "button"
          spen_class = "input-group-btn"
        end
        content_tag :spen, value, class: spen_class
      end
      
      def icon_block(options = {})
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
    
      def has_error?(method_name, options = {})
        method_name && !(options[:error_disabled]) && @object.respond_to?(:errors) && !(@object.errors[method_name].empty?)
      end

      def error_message(method_name, options = {})
        content_tag(:ui, class: "text-danger") { @object.errors[method_name].collect { |msg| concat(content_tag(:li, msg)) }} if has_error?(method_name, options)
      end
    end
  end
end