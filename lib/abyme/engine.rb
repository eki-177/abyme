module Abyme
  class Engine < ::Rails::Engine
    isolate_namespace Abyme
    
    config.after_initialize do
      ActiveSupport.on_load :action_view do
        # ActionView::Base.send :include, Abyme::ViewHelpers
        include Abyme::ViewHelpers
      end
    end
  end
end