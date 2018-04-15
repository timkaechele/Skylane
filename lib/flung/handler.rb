 require 'set'
module Flung
  module Handler

    def exposed_methods
      object_methods = Object.methods.map(&:to_sym)
      accessible_methods = self.public_instance_methods.map(&:to_sym)
      found_methods = accessible_methods - object_methods

      Set.new(found_methods)
    end

  end
end
