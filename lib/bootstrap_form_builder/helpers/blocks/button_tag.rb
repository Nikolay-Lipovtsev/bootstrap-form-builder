module BootstrapFormBuilder
  module Helpers
    module Blocks
      module ButtonTag
        
        def button_tag(options = nil, &block)
          super options[:content], generate_class(options), &block
        end
        
        private
        
        def generate_class(options)
          options ||= {}
          options[:style] ||= :default
          options[:style] = "btn-#{options[:style].to_s}"
          options[:size] = "btn-#{options[:size].to_s}" if options[:size]
          options[:class] = ["btn", options[:style], options[:size], options[:class]].compact.join(" ")
          options.delete_if{ |k, v| [:style, :size, :content].include? k }
        end
      end
    end
  end
end