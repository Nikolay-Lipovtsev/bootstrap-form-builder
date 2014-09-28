require "bootstrap_form_builder/version"
require "bootstrap_form_builder/control_builder"

module BootstrapFormBuilder
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end

ActionView::Base.send :include, BootstrapFormBuilder::Helpers::FormHelper