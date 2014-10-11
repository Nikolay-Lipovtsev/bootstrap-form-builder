require "bootstrap_form_builder/helpers/blocks/button_tag"

module BootstrapFormBuilder
  module Helpers
    # Provides a number of methods for creating a simple button with Bootstrap style
    module FormTagHelper
      include BootstrapFormBuilder::Helpers::Blocks::ButtonTag 
      
      # Creates a HTML div block with bootstrap row class.
      # ==== Options
      # :tag
      # :style
      # :size
      # :class
      # :active
      # :disabled
      # :col
      # :offset_col
      # :row_disable
      def button_tag(content_or_options = nil, options = nil, &block)
        if content_or_options.is_a? Hash
          options = content_or_options
        else
          options ||= {}
        end
        
        button_block(options[:col], options) do
          options = base_button_class(options)
          options[:disabled] = "disabled" if options[:disabled]
          options = { name: "button", type: "submit" }.merge!(options.symbolize_keys)
          if block_given?
            content_tag :button, options, &block
          else
            content_tag :button, content_or_options || "Button", options
          end
        end
      end
      
      def button_link_tag(name = nil, options = nil, html_options = nil, &block)
        button_block(html_options[:col], html_options) do
          html_options = base_button_class(html_options)
          html_options[:class] = [html_options[:class], "disabled"].compact.join(" ") if html_options[:disabled]
          html_options = { role: "button" }.merge!(html_options.symbolize_keys)
          name ||= "Button"
          link_to name, options, html_options, &block
        end
      end
      
      def submit_tag(value = nil, options = {})
        options = base_button_class(options)
        button_block(options[:col], options) { super value || "Save changes", options }
      end
      
      private
      
      def button_block(col = nil, options = {})
        col ? bootstrap_row_with_col(col, options.slice(:row_disable, :offset_col)) { yield } : yield
      end
      
      def base_button_class(html_options = {})
        html_options[:style] = "btn-#{(html_options[:style] || "default").to_s}"
        html_options[:size] = "btn-#{html_options[:size].to_s}" if html_options[:size]
        html_options[:active] = "active" if html_options[:active]
        html_options[:class] = ["btn", html_options[:style],  html_options[:size], html_options[:class], html_options[:active]].compact.join(" ")
        html_options[:class] = [html_options[:class], "btn-block"].compact.join(" ") if html_options[:col]
        html_options.delete_if{ |k, v| [:style, :size, :col, :active].include? k }
      end
    end
  end
end