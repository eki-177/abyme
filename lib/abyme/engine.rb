module Abyme
  class Engine < ::Rails::Engine
    isolate_namespace Abyme
    
    config.after_initialize do
      ActiveSupport.on_load :action_view do
        include Abyme::ViewHelpers
      end
    end
  end
end