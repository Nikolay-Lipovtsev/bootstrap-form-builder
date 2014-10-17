require "bootstrap_form_builder/helpers/form_helper"
require "bootstrap_form_builder/helpers/form_tag_helper"
require "bootstrap_form_builder/helpers/tag_helper"
require "bootstrap_form_builder/helpers/grid_system_helper"

module BootstrapFormBuilder
  module Helpers
    
    include BootstrapFormBuilder::Helpers::FormHelper
    include BootstrapFormBuilder::Helpers::FormTagHelper
    include BootstrapFormBuilder::Helpers::TagHelper
    include BootstrapFormBuilder::Helpers::GridSystemHelper
  end
end