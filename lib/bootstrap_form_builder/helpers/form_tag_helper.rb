module BootstrapFormBuilder
  module Helpers
    # Provides a number of methods for creating a simple button with Bootstrap style
    module FormTagHelper
      
      # Creates a button tag with bootstrap class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      # 
      # <tt>:active</tt> if set to true, takes the value of the active state.
      #
      # <tt>:disabled</tt> if set to true, takes the value of the disabled state.
      #
      # <tt>:col</tt> if set the value of a range of columns for Bootstrap grid system (1..12), the default size (width 
      # of content within) will be changed to the set. You can use integer for the values.
      #
      # <tt>:offset_col</tt> if set the value of a range of offset columns for Bootstrap grid system (1..12), it should
      # create a offset div block with a button inside. You can use integer for the values.
      # 
      # <tt>:row_disabled</tt> if set to true, it should generate Bootstrap col div with a button inside and without 
      # Bootstrap row div. This works only if set :col or :offset_col options.
      #
      # <tt>:style</tt> if set the value of a range of styles for Bootstrap buttons ("default", "primary", "success",
      # "info", "warning", "danger", "link"), the default style will be changed to the set. The default value is the 
      # "default", it can not be set. You can use string and symbols for the values.
      # 
      # <tt>:size</tt> if set the value of a range of size for Bootstrap buttons ("lg", "sm", "xs"), the default size 
      # will be changed to the set. For default size value is not set. You can use string and symbols for the values.
      #
      # === Examples
      # button_tag("Test")
      # # => <button class="btn btn-default" name="button" type="submit">Test</button>
      #
      # button_tag { content_tag(:ins, "Test with ins") }
      # # => <button class="btn btn-default" name="button" type="submit">
      #        <ins>Test with ins</ins>
      #      </button>
      #
      # button_tag("Test", type: :button)
      # # => <button class="btn btn-default" name="button" type="button">Test</button>
      #
      # button_tag("Test", style: :primary)
      # # => <button class="btn btn-primary" name="button" type="submit">Test</button>
      #
      # button_tag("Test", size: :lg)
      # # => <button class="btn btn-default btn-lg" name="button" type="submit">Test</button>
      #
      # button_tag("Test", active: true)
      # # => <button class="btn btn-default active" name="button" type="submit">Test</button>
      #
      # button_tag("Test", disabled: true)
      # # => <button class="btn btn-default" disabled="disabled" name="button" type="submit">Test</button>
      #
      # button_tag("Test", col: 6)
      # # => <div class="row">
      #        <div class="col-sm-6">
      #          <button class="btn btn-default btn-block" name="button" type="submit">Test</button>
      #        </div>
      #      </div>
      #
      # button_tag("Test", col: 6, row_disabled: true)
      # # => <div class="col-sm-6">
      #        <button class="btn btn-default btn-block" name="button" type="submit">Test</button>
      #      </div>
      # 
      # button_tag("Test", offset_col: 6)
      # # => <div class="row">
      #        <div class="col-sm-offset-6">
      #          <button class="btn btn-default" name="button" type="submit">Test</button>
      #        </div>
      #      </div>
      #      
      def button_tag(content_or_options = nil, options = nil, &block)
        content_or_options, options = yield, content_or_options if block_given?
        options ||= {}
        
        button_block(options) do
          options = base_button_class options
          options = { name: "button", type: "submit" }.merge!(options.symbolize_keys)
          content_tag :button, content_or_options || "Button", options
        end
      end
      
      # Creates a link tag with bootstrap button class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      # 
      # <tt>:active</tt> if set to true, takes the value of the active state.
      #
      # <tt>:disabled</tt> if set to true, takes the value of the disabled state.
      #
      # <tt>:col</tt> if set the value of a range of columns for Bootstrap grid system (1..12), the default size (width 
      # of content within) will be changed to the set. You can use only integer for the values.
      #
      # <tt>:offset_col</tt> if set the value of a range of offset columns for Bootstrap grid system (1..12), it should
      # create a offset div block with a link button inside. You can use only integer for the values.
      # 
      # <tt>:row_disabled</tt> if set to true, it should generate Bootstrap col div with a link button inside and 
      # without Bootstrap row div. This works only if set :col or :offset_col options.
      #
      # <tt>:style</tt> if set the value of a range of styles for Bootstrap link buttons ("default", "primary", 
      # "success", "info", "warning", "danger", "link"), the default style will be changed to the set. The default 
      # value is the "default", it can not be set. You can use string and symbols for the values.
      # 
      # <tt>:size</tt> if set the value of a range of size for Bootstrap link buttons ("lg", "sm", "xs"), the default 
      # size will be changed to the set. For default size value is not set. You can use string and symbols for the 
      # values.
      #
      # === Examples
      # button_link_tag("Test", new_user_path)
      # # => <a class="btn btn-default" href="/users/new" role="button">Test</a>
      #
      # button_link_tag(new_user_path) { content_tag(:ins, "Test with ins") }
      # # => <a class="btn btn-default" href="/users/new" role="button"><ins>Test with ins</ins></a>
      #        <ins>Test with ins</ins>
      #      </a>
      #
      # button_link_tag("Test", new_user_path, type: :button)
      # # => <a class="btn btn-default" href="/users/new" role="button" type="button">Test</a>
      #
      # button_link_tag("Test", new_user_path, style: :primary)
      # # => <a class="btn btn-primary" href="/users/new" role="button">Test</a>
      #
      # button_link_tag("Test", new_user_path, size: :lg)
      # # => <a class="btn btn-default btn-lg" href="/users/new" role="button">Test</a>
      #
      # button_link_tag("Test", new_user_path, active: true)
      # # => <a class="btn btn-default active" href="/users/new" role="button">Test</a>
      #
      # button_link_tag("Test", new_user_path, disabled: true)
      # # => <a class="btn btn-default disabled" disabled="disabled" href="/users/new" role="button">Test</a>
      #
      # button_link_tag("Test", new_user_path, col: 6)
      # # => <div class="row">
      #        <div class="col-sm-6">
      #          <a class="btn btn-default btn-block" href="/users/new" role="button">Test</a>
      #        </div>
      #      </div>
      #
      # button_link_tag("Test", new_user_path, col: 6, row_disabled: true)
      # # => <div class="col-sm-6">
      #        <a class="btn btn-default btn-block" href="/users/new" role="button">Test</a>
      #      </div>
      # 
      # button_link_tag("Test", new_user_path, offset_col: 6)
      # # => <div class="row">
      #        <div class="col-sm-offset-6">
      #          <a class="btn btn-default" href="/users/new" role="button">Test</a>
      #        </div>
      #      </div>
      #      
      def button_link_tag(name = nil, options = nil, html_options = {}, &block)
        html_options, options = options, nil if block_given?
        html_options ||= {}
        button_block(html_options) do
          html_options = base_button_class html_options
          html_options[:class] = [html_options[:class], "disabled"].compact.join(" ") if html_options[:disabled]
          html_options = { role: "button" }.merge!(html_options.symbolize_keys)
          name ||= "Button"
          options, html_options = html_options, nil if block_given?
          link_to name, options, html_options, &block
        end
      end
      
      # Creates a submit tag with bootstrap button class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      # 
      # <tt>:active</tt> if set to true, takes the value of the active state.
      #
      # <tt>:disabled</tt> if set to true, takes the value of the disabled state.
      #
      # <tt>:col</tt> if set the value of a range of columns for Bootstrap grid system (1..12), the default size (width 
      # of content within) will be changed to the set. You can use only integer for the values.
      #
      # <tt>:offset_col</tt> if set the value of a range of offset columns for Bootstrap grid system (1..12), it should
      # create a offset div block with a submit button inside. You can use only integer for the values.
      # 
      # <tt>:row_disabled</tt> if set to true, it should generate Bootstrap col div with a submit button inside and 
      # without Bootstrap row div. This works only if set :col or :offset_col options.
      #
      # <tt>:style</tt> if set the value of a range of styles for Bootstrap submit buttons ("default", "primary", 
      # "success", "info", "warning", "danger", "link"), the default style will be changed to the set. The default 
      # value is the "default", it can not be set. You can use string and symbols for the values.
      # 
      # <tt>:size</tt> if set the value of a range of size for Bootstrap submit buttons ("lg", "sm", "xs"), the default 
      # size will be changed to the set. For default size value is not set. You can use string and symbols for the 
      # values.
      #
      # === Examples
      # submit_tag("Test")
      # # => <input class="btn btn-default" name="commit" type="submit" value="Test">
      #
      # submit_tag("Test", type: :button)
      # # => <input class="btn btn-default" name="commit" type="button" value="Test">
      #
      # submit_tag("Test", style: :primary)
      # # => <input class="btn btn-primary" name="commit" type="submit" value="Test">
      #
      # submit_tag("Test", size: :lg)
      # # => <input class="btn btn-default btn-lg" name="commit" type="submit" value="Test">
      #
      # submit_tag("Test", active: true)
      # # => <input class="btn btn-default active" name="commit" type="submit" value="Test">
      #
      # submit_tag("Test", disabled: true)
      # # => <input class="btn btn-default" disabled="disabled" name="commit" type="submit" value="Test">
      #
      # submit_tag("Test", col: 6)
      # # => <div class="row">
      #        <div class="col-sm-6">
      #          <input class="btn btn-default btn-block" name="commit" type="submit" value="Test">
      #        </div>
      #      </div>
      #
      # submit_tag("Test", col: 6, row_disabled: true)
      # # => <div class="col-sm-6">
      #        <input class="btn btn-default btn-block" name="commit" type="submit" value="Test">
      #      </div>
      # 
      # submit_tag("Test", offset_col: 6)
      # # => <div class="row">
      #        <div class="col-sm-offset-6">
      #          <input class="btn btn-default" name="commit" type="submit" value="Test">
      #        </div>
      #      </div>
      #
      def submit_tag(value = nil, options = nil)
        options ||= {}
        button_block(options) do
          options = base_button_class options
          super value || "Save changes", options
        end
      end
      
      # Creates a button input tag with bootstrap button class.
      #
      # === Options
      # You can use only symbols for the attribute names.
      # 
      # <tt>:active</tt> if set to true, takes the value of the active state.
      #
      # <tt>:disabled</tt> if set to true, takes the value of the disabled state.
      #
      # <tt>:col</tt> if set the value of a range of columns for Bootstrap grid system (1..12), the default size (width 
      # of content within) will be changed to the set. You can use only integer for the values.
      #
      # <tt>:offset_col</tt> if set the value of a range of offset columns for Bootstrap grid system (1..12), it should
      # create a offset div block with a button input inside. You can use only integer for the values.
      # 
      # <tt>:row_disabled</tt> if set to true, it should generate Bootstrap col div with a button input inside and 
      # without Bootstrap row div. This works only if set :col or :offset_col options.
      #
      # <tt>:style</tt> if set the value of a range of styles for Bootstrap buttons input ("default", "primary", 
      # "success", "info", "warning", "danger", "link"), the default style will be changed to the set. The default 
      # value is the "default", it can not be set. You can use string and symbols for the values.
      # 
      # <tt>:size</tt> if set the value of a range of size for Bootstrap buttons input ("lg", "sm", "xs"), the default 
      # size will be changed to the set. For default size value is not set. You can use string and symbols for the 
      # values.
      #
      # === Examples
      # button_input_tag("Test")
      # # => <input class="btn btn-default" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", type: :button)
      # # => <input class="btn btn-default" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", style: :primary)
      # # => <input class="btn btn-primary" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", size: :lg)
      # # => <input class="btn btn-default btn-lg" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", active: true)
      # # => <input class="btn btn-default active" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", disabled: true)
      # # => <input class="btn btn-default" disabled="disabled" name="commit" type="button" value="Test">
      #
      # button_input_tag("Test", col: 6)
      # # => <div class="row">
      #        <div class="col-sm-6">
      #          <input class="btn btn-default btn-block" name="commit" type="button" value="Test">
      #        </div>
      #      </div>
      #
      # button_input_tag("Test", col: 6, row_disabled: true)
      # # => <div class="col-sm-6">
      #        <input class="btn btn-default btn-block" name="commit" type="button" value="Test">
      #      </div>
      # 
      # button_input_tag("Test", offset_col: 6)
      # # => <div class="row">
      #        <div class="col-sm-offset-6">
      #          <input class="btn btn-default" name="commit" type="button" value="Test">
      #        </div>
      #      </div>
      #
      def button_input_tag(value = nil, options = nil)
        options ||= {}
        options[:type] = :button
        submit_tag value, options
      end
      
      private
      
      def button_block(options = {})
        if [:col, :offset_col].any? { |k| options.key?(k) }
          bootstrap_row_with_col(options.slice(:col, :grid_system, :offset_col, :row_disabled)) { yield }
        else 
          yield
        end
      end
      
      def base_button_class(options = {})
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