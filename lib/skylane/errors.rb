module Skylane

  # Error raised if the server error code
  # is not in the range of -32099..-32000
  class InvalidServerErrorCode < StandardError
  end

  class Error < StandardError
    attr_reader :code, :message, :data, :id
    attr_writer :id

    def initialize(code, message, data: nil, id: nil)
      @code = code 
      @message = message
      @data = data
      @id = id
    end

    def to_h 
      hash_representation = {
        jsonrpc: Skylane::JSON_RPC_VERSION, 
        error: {
          code: self.code, 
          message: self.message,
        },
        id: self.id
      }
      if !self.data.nil?
        hash_representation[:error][:data] = self.data.to_h
      end
      hash_representation
    end
  end

  class ParseError < Error
    def initialize(data: nil, id: nil)
      super(-32700, "Parse error", data: data, id: id)
    end
  end

  class InvalidRequestError < Error
    def initialize(data: nil, id: nil)
      super(-32600, "Invalid Request", data: data, id: id)
    end
  end

  class MethodNotFoundError < Error
    def initialize(data: nil, id: nil)
      super(-32601, "Method not found", data: data, id: id)
    end
  end

  class InvalidParamsError < Error
    def initialize(data: nil, id: nil)
      super(-32602, "Invalid params", data: data, id: id)
    end
  end

  class InternalError < Error
    def initialize(data: nil, id: nil)
      super(-32603, "Internal error", data: data, id: id)
    end
  end


  class ServerError < Error 
    def initialize(code, message, data: nil, id: nil)
      if !(-32099..-32000).include?(code)
        raise InvalidServerErrorCode 
      end
      super(code, message, data: data, id: id)
    end
  end
end