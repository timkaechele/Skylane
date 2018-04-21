require 'json'

module Flung
  class Server
    attr_reader :router

    def initialize(router)
      @router = router
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      if !request.post?
        response.finish
      else
        result = process_request(request.body.read)
        response.write result
        response.finish
      end
    end

    private

    def process_request(body)
      requests = nil
      is_batched = false
      begin
        is_batched, requests = parse_body(body)
      rescue Error => e
        return JSON.generate(e.to_h)
      end

      if requests.empty?
        error = InvalidRequestError.new(id: nil)
        return build_error_json(error)
      end

      responses = requests.map do |request|
        begin
          validate_json_rpc_schema(request)

          result = dispatch_request(request)
          {
            jsonrpc: Flung::JSON_RPC_VERSION,
            result: result,
            id: request["id"]
          }
        rescue Error => e
          e.to_h
        end
      end.select { |r| !r[:error].nil? || !r[:id].nil? }

      if is_batched
        JSON.generate(responses)
      elsif !responses.empty?
        JSON.generate(responses.first)
      else
        nil
      end
    end

    def dispatch_request(request_hash)
      instance_method = router.method_for(request_hash["method"])
      if instance_method.nil?
        raise MethodNotFoundError.new(id: request_hash["id"])
      end
      result = begin
        if request_hash["params"].is_a?(Hash)
          params = map_named_params(instance_method.parameters, request_hash["params"])
          instance_method.public_send(:call, *params)
        elsif request_hash["params"].is_a?(Array)
          instance_method.public_send(:call, *request_hash["params"])
        else
          instance_method.public_send(:call)
        end
      rescue ArgumentError => e
        raise InvalidParamsError.new(id: request_hash["id"], data: { error: e.message })
      end
      result
    end


    def build_error_json(error)
      JSON.generate(error.to_h)
    end

    def validate_json_rpc_schema(json_rpc_request)
      if !json_rpc_request.is_a?(Hash)
        raise InvalidRequestError.new(id: json_rpc_request["id"])
      end

      if json_rpc_request["jsonrpc"] != JSON_RPC_VERSION
        raise InvalidRequestError.new(id: json_rpc_request["id"])
      end

      if !json_rpc_request.has_key?("method") || json_rpc_request["method"].empty?
        raise InvalidRequestError.new(id: json_rpc_request["id"])
      end

      if json_rpc_request.has_key?("params")
        params = json_rpc_request["params"]

        if !(params.is_a?(Array) || params.is_a?(Hash))
          raise InvalidRequestError.new(id: json_rpc_request["id"])
        end
      end
    end

    def parse_body(body)
      begin
        payload = JSON.parse(body)
        is_batched = payload.is_a?(Array)

        if !is_batched
          payload = [payload]
        end

        return is_batched, payload
      rescue JSON::ParserError => e
        raise ParseError
      end
    end

    def map_named_params(method_parameters, named_params_hash)

      key_params = Hash.new
      normal_params = Array.new
      method_parameters.each do |method_param|
        parameter_value = named_params_hash[method_param[1].to_s]
        includes_value = named_params_hash.include?(method_param[1].to_s)
        if method_param[0] == :req || method_param[0] == :opt
          if includes_value
            normal_params.push(parameter_value)
          end
        elsif method_param[0] == :key || method_param[0] == :keyreq
          if includes_value
            key_params[method_param[1]] = parameter_value
          end
        end
      end
      normal_params.push(key_params) if !key_params.empty?
      normal_params
    end
  end
end
