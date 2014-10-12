module BootstrapFormBuilder
  module Helpers
    # Provides a number of methods for creating a simple Bootstrap blocks
    module GridSystemHelper
      
      # Creates a HTML div block with bootstrap row class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      #
      # <tt>:row_disabled</tt> if set to true, the content will build without bootstrap row div block,
      # it will return empty content.
      #
      # === Examples
      # bootstrap_row { "Test" }
      # # => <div class="row">"Test"</div>
      #
      # bootstrap_row(class: "foo") { "Test" }
      # # => <div class="row foo">"Test"</div>
      #
      # bootstrap_row(row_disabled: true) { "Test" }
      # # => "Test"
      def bootstrap_row(options = {})
        options[:class] = ["row", options[:class]].compact.join(" ")
        options[:row_disabled] ? yield : content_tag(:div, class: options[:class]) { yield }
      end
      
      alias :control_group :bootstrap_row
      
      # Creates a HTML div block with bootstrap grid column class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      #
      # <tt>:grid_system</tt> if the set value from bootstrap grid system you can chenge default value "sm" 
      # to "xs", "sm", "md" or "lg". You can use string and symbols for the values
      # 
      # <tt>:offset_col</tt> if the set value in the range from 1 to 12 it generate bootstrap offset class 
      # in HTML div block with bootstrap grid column.
      #
      # === Examples
      # bootstrap_col { "Test" }
      # # => <div class="col-sm-12">"Test"</div>
      #
      # bootstrap_col(6) { "Test" }
      # # => <div class="col-sm-6">"Test"</div>
      #
      # bootstrap_col(6, offset_col: 4) { "Test" }
      # # => <div class="col-sm-6 col-sm-offset-4">"Test"</div>
      #
      # bootstrap_col(6, class: "foo") { "Test" }
      # # => <div class="col-sm-6 foo">"Test"</div>
      #
      # bootstrap_col(6, grid_system: :lg) { "Test" }
      # # => <div class="col-lg-6 foo">"Test"</div>
      def bootstrap_col(col = nil, options = {})
        options[:class] = [grid_system_class(options[:grid_system], col), 
                          grid_system_offset_class(options[:grid_system], options[:offset_col]), 
                          options[:class]].compact.join(" ")
        content_tag(:div, class: options[:class]) { yield }
      end
      
      # Creates a HTML div block with bootstrap row class and HTML div block with bootstrap grid column class inside.
      #
      # === Options
      # You can use only symbols for the attribute names.
      #
      # <tt>:row_disabled</tt> if set to true, it will create only HTML div block with bootstrap grid column class
      # and without HTML div block with bootstrap row class.
      #
      # === Examples
      # bootstrap_row_with_col { "Test" }
      # # => <div class="row">
      #        <div class="col-sm-12">
      #          "Test"
      #        </div>
      #      </div>
      #
      # bootstrap_row_with_col(6) { "Test" }
      # # => <div class="row">
      #        <div class="col-sm-6">
      #          "Test"
      #        </div>
      #      </div>
      #
      # bootstrap_row_with_col(6, offset_col: 4) { "Test" }
      # # => <div class="row">
      #        <div class="col-sm-6 col-sm-offset-4">
      #          "Test"
      #        </div>
      #      </div>
      #
      # bootstrap_row_with_col(6, class: "foo") { "Test" }
      # # => <div class="row foo">
      #        <div class="col-sm-6">
      #          "Test"
      #        </div>
      #      </div>
      #
      # bootstrap_row_with_col(6, grid_system: :lg) { "Test" }
      # # => <div class="row">
      #        <div class="col-lg-6">
      #          "Test"
      #        </div>
      #      </div>
      def bootstrap_row_with_col(col = nil, options = {})
        bootstrap_row(options) { bootstrap_col(col, options.slice(:grid_system, :offset_col)) { yield }}
      end
      
      # Creates a HTML class with Bootstrap col.
      def grid_system_class(grid_system = default_grid_system, col = default_col)
        "col-#{(grid_system || default_grid_system).to_s}-#{col || default_col}"
      end
      
      # Creates a HTML class with Bootstrap offset-col.
      def grid_system_offset_class(grid_system, col)
        "col-#{(grid_system || default_grid_system).to_s}-offset-#{col}" if col
      end
      
      def default_horizontal_label_col
        2
      end

      def default_col
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