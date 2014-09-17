require "bootstrap_form_builder/version"
require "bootstrap_form_builder/form"
require "bootstrap_form_builder/control"

module BootstrapFormBuilder
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end

ActionView::Base.send :include, BootstrapFormBuilder::Form