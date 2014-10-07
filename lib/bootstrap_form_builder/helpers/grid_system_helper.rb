module BootstrapFormBuilder
  module Helpers
    # Provides a number of methods for creating a simple Bootstrap blocks
    module GridSystemHelper
      
      def bootstrap_row(options = {})
        options[:class] = ["row", options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end
      
      alias :control_group :bootstrap_row
      
      def bootstrap_col(col = nil, options = {})
        options[:class] = [grid_system_class(options[:grid_system], col), 
                          grid_system_offset_class(options[:grid_system], options[:offset_col]), 
                          options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end
      
      def bootstrap_row_with_col(col = nil, options = {})
        bootstrap_row(options) { bootstrap_col(col, options.slice(:grid_system, :offset_col)) { yield }}
      end
      
      def grid_system_class(grid_system = default_grid_system, col = default_control_col)
        "col-#{(grid_system || default_grid_system).to_s}-#{col || default_control_col}"
      end

      def grid_system_offset_class(grid_system, col)
        "col-#{(grid_system || default_grid_system).to_s}-offset-#{col}" if col
      end

      def default_horizontal_label_col
        2
      end

      def default_control_col
        12
      end

      def default_horizontal_control_col
        10
      end

      def default_grid_system
        "sm"
      end
    end
  end
end