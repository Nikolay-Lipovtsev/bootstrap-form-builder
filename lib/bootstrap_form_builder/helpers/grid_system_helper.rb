module BootstrapFormBuilder
  module Helpers
    module GridSystemHelper
      
      def bootstrap_row(options = {})
        options[:class] = ["row", options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end

      def control_group
        content_tag(:div, class: "row") { yield }
      end
      
      def bootstrap_col(options = {})
        options[:grid_system] ||= default_grid_system
        options[:class] = [grid_system_class(grid_system, col, type), options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end
      
      def grid_system_class(grid_system, col, control_type = :control)
        "col-#{(grid_system || default_grid_system).to_s}-#{col || (control_type == :control ? default_horizontal_control_col : default_horizontal_label_col)}"
      end

      def grid_system_offset_class(grid_system, col)
        "col-#{(grid_system || default_grid_system).to_s}-offset-#{col}"
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