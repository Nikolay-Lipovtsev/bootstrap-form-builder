module BootstrapFormBuilder
  module Helpers
    module ControlHelper

      def generate_form_group_row(options = {})
        if (options[:control_col] || options[:offset_control_col]) && !(options[:row_disable] || options[:layout])
          bootstrap_row { yield }
        else
          yield
        end
      end

      def generate_all(helper, field, options = {})
        get_common_form_options(options)
        generate_class(helper, field, options)
        generate_form_group(options) { generate_label_and_control(helper, field, options) { yield } }
      end

      def generate_class(helper, field, options = {})
        options[:group_class] = [options[:group_class], "form-group"].compact.join(" ")
        options[:group_class] = [options[:group_class], "has-error"].compact.join(" ") if has_error?(field, options)
        options[:label_class] = [options[:label_class], "sr-only"].compact.join(" ") if options[:invisible_label] || options[:layout] == :inline
        options[:label_class] = [options[:label_class], "#{helper.gsub(/([_]|button)/, "")}-inline"].compact.join(" ") if check_box_or_radio?(helper) && options[:inline]
        if options[:layout]
          options[:label_class] = [options[:label_class], grid_system_offset_class(options[:grid_system], options[:offset_label_col])].compact.join(" ") unless check_box_or_radio?(helper)
          options[:label_class] = [options[:label_class], grid_system_class(options[:grid_system], options[:label_col], :label)].compact.join(" ") unless check_box_or_radio?(helper)
          options[:label_class] = [options[:label_class], "control-label"].compact.join(" ") unless check_box_or_radio?(helper)
          options[:control_class] = [options[:control_class], grid_system_offset_class(options[:grid_system], options[:offset_control_col])].compact.join(" ")
          options[:control_class] = [options[:control_class], grid_system_class(options[:grid_system], options[:control_col], :control)].compact.join(" ")
        else
          options[:group_class] = [options[:group_class], grid_system_offset_class(options[:grid_system], options[:offset_control_col])].compact.join(" ")
          options[:group_class] = [options[:group_class], grid_system_class(options[:grid_system], options[:control_col], :control)].compact.join(" ") if options[:control_col]
        end
      end

      def control_group_label(method, text = nil, options = {}, &block)
        options[:label_class] = [options[:label_class], grid_system_offset_class(options[:grid_system], options[:offset_label_col])].compact.join(" ") if options[:offset_label_col]
        options[:label_class] = [options[:label_class], grid_system_class(options[:grid_system], options[:label_col], :label)].compact.join(" ") if options[:label_col]
        options[:label_class] ? content_tag(:div, class: options[:label_class]) { label(method, text, options, &block) } : label(method, text, options, &block)
      end

      def generate_form_group(options = {})
        generate_form_group_row(options) do
          content_tag(:div, class: options[:group_class]) { yield }
        end
      end

      def generate_label_and_control(helper, field, options = {}, &block)
        if check_box_or_radio?(helper)
          options[:label_text] ||= I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{field}")
          if options[:inline]
            content_tag(:label, generate_control(helper, options, &block) << options[:label_text], class: options[:label_class])
          else
            content_tag(:div, class: "checkbox") { content_tag(:label, generate_control(helper, options, &block) << options[:label_text], class: options[:label_class]) }
          end
        else
          label(field, options[:label_text], class: options[:label_class]) << generate_control(helper, options, &block)
        end
      end

      def generate_control(helper, options = {}, &block)
        if options[:layout] == :horizontal && !check_box_or_radio?(helper)
          content_tag(:div, class: options[:control_class]) { yield }
        else
          yield
        end
      end

      def has_error?(field, options = {})
        @object.respond_to?(:errors) && !(field.nil? || @object.errors[field].empty?) and !(options[:error_disable])
      end

      def error_message(field)
        if has_error?(field)
          @object.errors[field].collect { |msg| concat(content_tag(:li, msg)) }
        end
      end

      def grid_system_class(grid_system, col, type = :control)
        "col-#{(grid_system || default_grid_system).to_s}-#{col || (type == :control ? default_horizontal_control_col : default_horizontal_label_col)}"
      end

      def grid_system_offset_class(grid_system, col)
        "col-#{(grid_system || default_grid_system).to_s}-offset-#{col}" if col
      end

      def default_horizontal_label_col
        3
      end

      def default_control_col
        12
      end

      def default_horizontal_control_col
        7
      end

      def default_date_col
        4
      end

      def default_grid_system
        "sm"
      end

      def error_class
        "has-error"
      end
    end
  end
end