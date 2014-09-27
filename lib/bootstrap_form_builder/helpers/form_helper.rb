module BootstrapFormBuilder
  module Helpers
    module FormHelper

      def bootstrap_builder_form_for(object, options = {}, &block)
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
        #
        # For example, to render a form with invisible labels
        # The HTML generated for this would be (modulus formatting):

        options[:html] ||= {}
        options[:html][:role] = "form"
        options[:builder] ||= BootstrapFormBuilder::ControlBuilder

        layout = case options[:layout]
        when :inline
          "form-inline"
        when :horizontal
          "form-horizontal"
        end

        if layout
          options[:html][:class] = [options[:html][:class], layout].compact.join(" ")
        end
        disabled(options) do
          form_for(object, options, &block)
        end
      end

      def disabled(options={})
        options[:disabled] ? content_tag(:fieldset, "", disabled: true) { yield } : yield
      end
    end
  end
end