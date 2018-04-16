require 'json'

module Flung
  class Server

    JSON_RPC_VERSION = "2.0"

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
        return JSON.generate(error.to_h)
      end

      responses = requests.map do |request|
        begin 
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
          instance_method.public_send(:call, request_hash["params"])
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

    def validate_json_rpc_schema(json_rpc_request)
      if !json_rpc_request.is_a?(Hash)
        raise InvalidRequestError 
      end

      if json_rpc_request["jsonrpc"] != JSON_RPC_VERSION
        raise InvalidRequestError
      end

      if !json_rpc_request.has_key?("method") || json_rpc_request["method"].empty?
        raise InvalidRequestError
      end

      if json_rpc_request.has_key?("params")
        params = json_rpc_request["params"]

        if !(params.is_a?(Array) || params.is_a?(Hash))
          raise InvalidRequestError
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

        payload.each do |element|
          validate_json_rpc_schema(element)
        end

        return is_batched, payload
      rescue JSON::ParserError => e 
        raise ParseError
      end
    end

  end
end