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
      # :control_col
      # :offset_control_col
      
      
    end
  end
end
=begin
def generate_button(options = {})
  options[:tag] ||= :input
  options[:tag] != :a ? options[:type] ||= "submit" : options[:type] ||= "button"
  options[:type] = options[:type].to_s if options[:type]
  options[:class] = generate_class(options)
  options[:tag] = :input ? generate_input_tag(options) : generate_button_or_link_tag(options)
end

private

def generate_input_tag(options = {})
  options[:value] = options[:text]
  options[:name] = "commit"
  options[:disabled] = "disabled" if options[:disabled]
  content_tag(options[:tag], "", options.slice(:class, :type, :value, :name))
end

def generate_button_or_link_tag(options = {})
  
end

def generate_class(options = {})
  options[:style] ||= :default
  options[:style] = "btn-#{options[:style].to_s}"
  options[:size] = "btn-#{options[:size].to_s}" if options[:size]
  options[:class] = ["disabled", options[:class]].compact.join(" ") if options[:disabled] && options[:tag] = :a
  options[:class] = ["btn-block", options[:class]].compact.join(" ") if options[:control_col]
  options[:class] = ["btn", options[:style], options[:size], options[:class]].compact.join(" ")
end
=end