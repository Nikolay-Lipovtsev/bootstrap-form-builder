require "bootstrap_form_builder/helpers"

module BootstrapFormBuilder
  class Base < ActionView::Helpers::FormBuilder
    
    include BootstrapFormBuilder::Helpers
    
    def button_tag
      "Test"
    end
  end
end

=begin  
    COMMON_OPTIONS = [:layout, :label_class, :label_col, :offset_label_col, :label_text, :invisible_label, :required, 
      :control_class, :control_col, :offset_control_col, :placeholder, :popover, :error_disable, :row_disable, 
      :inline, :grid_system, :disabled, :rows]
    
    LABEL_OPTIONS = [:layout, :label_class, :label_col, :label_text, :label_offset, :invisible_label, :grid_system]

    CONTROL_OPTIONS = [:class, :placeholder, :data, :html, :disabled, :rows]

    FIELD_HELPERS = %w{color_field date_field datetime_field datetime_local_field email_field month_field 
      number_field password_field phone_field range_field search_field telephone_field text_area text_field 
      time_field url_field week_field}

    CHECK_BOX_AND_RADIO_HELPERS = %w{check_box radio_button}

    COMMON_FORM_OPTIONS = [:layout, :label_col, :invisible_label, :control_col, :offset_control_col, :grid_system]

    delegate :content_tag, :capture, :concat, to: :@template

    FIELD_HELPERS.each do |helper|
      define_method helper do |field, *args|
        options = args.detect{ |a| a.is_a?(Hash) } || {}
        generate_all(helper, field, options) do
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
  
    def fields_for_with_bootstrap(record_name, record_object = nil, fields_options = {}, &block)
      fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
      COMMON_FORM_OPTIONS.each { |name| fields_options[name] ||= options[name] if options[name] }
      fields_for_without_bootstrap(record_name, record_object, fields_options, &block)
    end
    
    alias_method_chain :fields_for, :bootstrap
    
    def get_common_form_options(options = {})
      COMMON_FORM_OPTIONS.each { |name| options[name] ||= @options[name] if @options[name] }
    end
    
    def check_box_or_radio?(helper)
      CHECK_BOX_AND_RADIO_HELPERS.include?(helper)
    end
    
    def button(options = {})
      generate_button(options)
    end
  end
=end