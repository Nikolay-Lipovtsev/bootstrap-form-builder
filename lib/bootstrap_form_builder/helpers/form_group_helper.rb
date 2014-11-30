module BootstrapFormBuilder
  module Helpers
    module FormGroupHelper

      def form_group(options = {})
        helper = "form_group_builder"
        form_group_builder(helper, nil, options) do
          col_block(helper, options) { yield }
        end
      end      
    end
  end
end
  