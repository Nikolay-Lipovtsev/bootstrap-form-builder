require "bootstrap_form_builder/tag"
require "bootstrap_form_builder/button"

module Control
  class FormBuilder < ActionView::Helpers::FormBuilder
    include Tag
    include Button
    
    COMMON_OPTIONS = [:layout, :label_class, :label_col, :offset_label_col, :label_text, :invisible_label, :required,
                      :control_class, :control_col, :offset_control_col, :placeholder, :popover, :error_disable,
                      :row_disable, :inline, :grid_system, :disabled, :rows]

    LABEL_OPTIONS = [:layout, :label_class, :label_col, :label_text, :label_offset, :invisible_label, :grid_system]

    CONTROL_OPTIONS = [:class, :placeholder, :data, :html, :disabled, :rows]

    FIELD_HELPERS = %w{color_field date_field datetime_field datetime_local_field
                    email_field month_field number_field password_field phone_field
                    range_field search_field telephone_field text_area text_field time_field
                    url_field week_field}

    CHECK_BOX_AND_RADIO_HELPERS = %w{check_box radio_button}

    COMMON_FORM_OPTIONS = [:layout, :label_col, :invisible_label, :control_col, :offset_control_col, :grid_system]

    delegate :content_tag, :capture, :concat, to: :@template

    FIELD_HELPERS.each do |helper|
      define_method helper do |field, *args|
        options = args.detect{ |a| a.is_a?(Hash) } || {}
        generate_all(helper, field, options) do
          options[:control_col] ||= default_date_col if helper == "date_field"
          options[:placeholder] ||= I18n.t("helpers.label.#{@object.class.to_s.downcase}.#{field}") if options[:placeholder] || options[:invisible_label]
          options[:class] = ["form-control", options[:class]].compact.join(" ")
          super(field, options.slice(*CONTROL_OPTIONS))
        end
      end
    end

    CHECK_BOX_AND_RADIO_HELPERS.each do |helper|
      define_method helper do |field, *args|
        options = args.detect{ |a| a.is_a?(Hash) } || {}
        get_common_form_options(options)
        generate_class(helper, field, options)
        if options[:layout] || options[:control_col]
          generate_form_group(options) do
            content_tag(:div, class: options[:control_class]) do
              generate_label_and_control(helper, field, options) { super(field, options.slice(*CONTROL_OPTIONS)) }
            end
          end
        else
          generate_label_and_control(helper, field, options) { super(field, options.slice(*CONTROL_OPTIONS)) }
        end

        #generate_all(helper, field, options) { super(field, options.slice(*CONTROL_OPTIONS)) }
      end
    end

    def get_common_form_options(options = {})
      COMMON_FORM_OPTIONS.each { |name| options[name] ||= @options[name] if @options[name] }
    end

    def generate_form_group_row(options = {})
      if (options[:control_col] || options[:offset_control_col]) && !(options[:row_disable] || options[:layout])
        bootstrap_row { yield }
      else
        yield
      end
    end

    def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
      fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
      COMMON_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
      fields_for_without_bootstrap(record_name, record_object, fields_options, &block)
    end

    alias_method_chain :fields_for, :bootstrap

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

    def check_box_or_radio?(helper)
      CHECK_BOX_AND_RADIO_HELPERS.include?(helper)
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