module BootstrapFormBuilder
  module Helpers
    module Blocks
      module ButtonTag
        
        def button_tag(options = {}, &block)
          content = options[:content]
          options = base_class(options)
          options[:disabled] = "disabled" if options[:disabled]
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
          html_options[:class] = [html_options[:class], "disabled"].compact.join(" ") if html_options[:disabled]
          html_options = { role: "button" }.merge!(html_options.symbolize_keys)
          name ||= "Button"
          link_to name, options, html_options, &block
        end
        
        private
        
        def base_class(html_options = {})
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
end