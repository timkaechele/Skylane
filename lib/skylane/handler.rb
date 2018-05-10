 require 'set'
module Skylane
  module Handler

    def exposed_methods
      object_methods = Object.methods.map(&:to_sym)
      accessible_methods = self.public_instance_methods.map(&:to_sym)
      found_methods = accessible_methods - object_methods

      Set.new(found_methods)
    end

    # Accepts the parameter_name, an action that should be called 
    # @param parameters - a single parameter as a symbol or an array of parameters
    # @param action - a callable (`.call`) action that accepts a hash with the 
    #   specified parameters
    # @param only - a single symbol or an array of symbols that represent the methods
    #   that should be handled by this before_action
    def before_action(parameters, action, only: nil)
    end

    # Accepts a parameters hash and returns a parameters hash
    def apply_before_actions(method_name, parameters)
    end

    # Finds before_actions that have to be applied before dispatching 
    # the request 
    def applicable_before_actions(method_name)
    end
  end
end
