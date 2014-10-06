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
      #
      # For example, to render a form with invisible labels
      # The HTML generated for this would be (modulus formatting):
      def bootstrap_form_for(object, options = {}, &block)
        options[:html] ||= {}
        options[:html][:role] = "form"
        options[:builder] ||= BootstrapFormBuilder::Helpers::FormBuilder
        options[:html][:class] = [options[:html][:class], "form-#{options[:layout].to_s}"].compact.join(" ") if options[:layout]
        
        disabled(options) do
          form_for(object, options, &block)
        end
      end
      
      private
      
      def disabled(options = {})
        options[:disabled] ? content_tag(:fieldset, "", disabled: true) { yield } : yield
      end
    end 
     
    class FormBuilder < ActionView::Helpers::FormBuilder

      def button(value = nil, options = {}, &block)
      end
    end
  end
end