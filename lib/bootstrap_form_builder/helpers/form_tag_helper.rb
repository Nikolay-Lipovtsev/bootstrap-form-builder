require "bootstrap_form_builder/helpers/blocks/button_tag"

module BootstrapFormBuilder
  module Helpers
    module FormTagHelper
      include BootstrapFormBuilder::Helpers::Blocks::ButtonTag 
      
      # :tag
      # :style
      # :size
      # :class
      # :active
      # :disabled
      # :col
      def button_tag(content_or_options = nil, options = nil, &block)
        if content_or_options.is_a? Hash
          options = content_or_options
        else
          options ||= {}
          options[:content] = content_or_options
        end
        
        button_block(options[:col]) { super options, &block }
      end
      
      def button_link_tag(name = nil, options = nil, html_options = nil, &block)
        button_block(html_options[:col]) { super name, options, html_options, &block }
      end
      
      private
      
      def button_block(col = nil)
        col ? bootstrap_row_with_col(col) { yield } : yield
      end
    end
  end
end