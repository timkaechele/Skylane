require 'set'
module Flung
  module Handler

    def exposed_methods
      object_methods = Object.methods.map(&:to_sym)
      instance_methods = self.instance_methods.map(&:to_sym)
      found_methods = instance_methods - object_methods

      Set.new(found_methods)
    end

  end
end
