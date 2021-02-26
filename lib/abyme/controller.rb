module Abyme
  module Controller
    def abyme_attributes
      return [] if resource_class.nil?
      
      resource_class.abyme_attributes
    end

    private

    def resource_class
      self.class.name.match(/(.*)(Controller)/)[1].singularize.safe_constantize
    end
  end
end