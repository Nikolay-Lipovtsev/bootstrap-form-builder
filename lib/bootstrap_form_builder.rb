require "bootstrap_form_builder/version"

module BootstrapFormBuilder
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end

ActionView::Base.send :include, BootstrapFormBuilder::Form