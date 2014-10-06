require "bootstrap_form_builder/helpers/blocks/button_tag"

module BootstrapFormBuilder
  module Helpers
    module FormTagHelper
      include BootstrapFormBuilder::Helpers::Blocks::ButtonTag 
      
      def button_tag(content_or_options = nil, options = nil, &block)
        if content_or_options.is_a? Hash
          options = content_or_options
        else
          options ||= {}
          options[:content] = content_or_options
        end
        
        super options, &block
      end
    end
  end
end