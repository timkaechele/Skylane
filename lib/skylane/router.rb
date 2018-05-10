module Skylane

  # Allows to map functions to handlers
  class Router
    attr_reader :routes 
    def initialize
      @routes = Hash.new
    end


    def add_handler(handler, namespace="")
      if !@routes.has_key?(namespace)
        self.routes[namespace] = Hash.new 
      end

      handler.class.exposed_methods.each do |method_name|
        if self.routes[namespace].has_key?(method_name)
          # @TODO: Error Handling for duplicate handlers for a method
        end

        self.routes[namespace][method_name] = handler
      end
    end

    def method_for(function_name)
      namespace, method_name = parse_function_name(function_name)

      handler = handler_for(function_name)

      if handler && handler.methods.include?(method_name)
        handler.method(method_name)
      else
        nil
      end
   end

    def handler_for(function_name)
      namespace, method_name = parse_function_name(function_name)

      if routes.has_key?(namespace) && routes[namespace].has_key?(method_name)
        routes[namespace][method_name]
      else 
        nil
      end
    end


    def available_functions
      self.routes.map do |namespace, functions|
        functions.map do |name, handler|
          if namespace.empty? 
            name.to_s
          else
            [namespace, name].join(".")
          end
        end
      end.flatten
    end

    private

    attr_writer :routes

    def parse_function_name(function_name)
      function_name_parts = function_name.split('.')
      namespace = function_name_parts[0..-2].join(".")
      method_name = function_name_parts.last.to_sym
      [namespace, method_name]
    end
  end
end