module BootstrapFormBuilder
  module Helpers
    module WrapperHelper
      
      def wrapper(layout = nil, grouped_controls = false, label = nil, content = nil)
        if layout == :horizontal
          
        elsif layout == :inline
          
        else
          
        end
      end
      
      private
      
      def col_block(helper = nil, options = {})
        if options[:col_block_disabled] || options[:layout] != :horizontal
          yield
        else
          options[:offset_control_col] ||= default_horizontal_label_col if ["check_box", "radio_button", "btn", "collection"].include?(helper)
          options[:control_col] ||= default_horizontal_control_col
          bootstrap_col(col: options[:control_col], grid_system: options[:grid_system], offset_col: options[:offset_control_col]) { yield }
        end
      end
    end
  end
end