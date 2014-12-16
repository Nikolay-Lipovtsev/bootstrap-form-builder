module BootstrapFormBuilder
  module Helpers
    module Tags
      class BootstrapButton
        
        def button_tag(content_or_options = nil, options = nil, &block)
          content_or_options, options = yield, content_or_options if block_given?
          options ||= {}
        
          button_block(options) do
            options = base_button_class options
            options = { name: "button", type: "submit" }.merge!(options)
            content_tag :button, content_or_options || "Button", options
          end
        end
        
        private
      
        def button_block(options = {})
          if [:col, :offset_col].any? { |k| options.key?(k) }
            bootstrap_row_with_col(options.slice(:col, :grid_system, :offset_col, :row_disabled)) { yield }
          else 
            yield
          end
        end
      
        def button_class(options = {})
          options.symbolize_keys!
          options[:style] = "btn-#{(options[:style] || "default").to_s}"
          options[:size] = "btn-#{options[:size].to_s}" if options[:size]
          options[:active] = "active" if options[:active]
          options[:class] = ["btn", options[:style],  options[:size], options[:class], options[:active]].compact.join(" ")
          options[:class] = [options[:class], "btn-block"].compact.join(" ") if options[:col]
          options.delete_if { |k, v| [:active, :col, :grid_system, :offset_col, :row_disabled, :size, :style].include? k }
        end
      end
    end
  end
end