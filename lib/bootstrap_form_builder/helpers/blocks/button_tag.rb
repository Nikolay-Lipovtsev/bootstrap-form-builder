module BootstrapFormBuilder
  module Helpers
    module Blocks
      module ButtonTag
        
        def button_tag(options = nil, &block)
          content = options[:content]
          options = base_class(options)
          options = { name: "button", type: "submit", tag: :button }.merge!(options.symbolize_keys)
          tag = options[:tag]
          options.delete(:tag)
          if block_given?
            content_tag tag, options, &block
          else
            content_tag tag, content || "Button", options
          end
        end
        
        def button_link_tag(name = nil, options = nil, html_options = nil, &block)
          html_options = base_class(html_options)
          html_options = { role: "button" }.merge!(html_options.symbolize_keys)
          link_to (name || "Button"), options, html_options, &block
        end
        
        private
        
        def base_class(options = {})
          options[:style] = "btn-#{(options[:style] || "default").to_s}"
          options[:size] = "btn-#{options[:size].to_s}" if options[:size]
          options[:class] = ["btn", options[:style],  options[:size], options[:class]].compact.join(" ")
          return "test"
          options.delete_if{ |k, v| [:style, :size].include? k }
        end
      end
    end
  end
end