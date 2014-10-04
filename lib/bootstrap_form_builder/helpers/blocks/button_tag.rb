module BootstrapFormBuilder
  module Helpers
    module Blocks
      module ButtonTag
        
        def button_or_link_tag(content_or_options = nil, options = {}, &block)
          options[:disabled] = "disabled" if options[:disabled]
          super(content_or_options, options, &block)
        end
        
        def button_input_tag(content_or_options = nil, options = {}, &block)
          if content_or_options.is_a? Hash
            options = content_or_options
          else
            options ||= {}
          end

          options = { 'name' => 'button', 'type' => 'submit' }.merge!(options.stringify_keys)

          if block_given?
            content_tag :input, options, &block
          else
            content_tag :input, content_or_options || "Submit", options
          end
        end
      end
    end
  end
end