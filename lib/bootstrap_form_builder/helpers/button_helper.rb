module BootstrapFormBuilder
  module Helpers
    module ButtonHelper
  
      # Options for button
      #
      # :tag
      # :type
      # :style
      # :size
      # :class
      # :text
      # :desabled
      def button(options = {})
    
        options[:tag] ||= :input
        return options[:tag]
        options[:type] = options[:type].to_s if options[:type]
        options[:style] ||= :default
        options[:style] = "btn-#{options[:style].to_s}"
        options[:size] = "btn-#{options[:size].to_s}" if options[:size]
        options[:class] = ["disabled", options[:class]].compact.join(" ") if options[:disabled] && options[:tag] = :a
        options[:class] = ["btn", options[:style], options[:size], options[:class]].compact.join(" ")
        options[:tag] != :a ? options[:type] ||= "submit" : options[:type] ||= "button"
        if options[:tag] = :input
          options[:value] = options[:text]
          options[:name] = "commit"
          content_tag(options[:tag], "", options.slice(:class, :type, :value, :name))
        elsif [:a, :button].include?(options[:tag])
          options.delete(:disabled) if options[:tag] = :a
          content_tag(options[:tag], options[:text], options.slice(:class, :type, :disabled))
        end
      end
    end
  end
end