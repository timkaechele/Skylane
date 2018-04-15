module Flung

  # Error raised if the server error code
  # is not in the range of -32099..-32000
  class InvalidServerErrorCode < StandardError
  end

  class Error < StandardError
    attr_reader :code, :message, :data

    def initialize(code, message, data=nil)
      @code = code 
      @message = @message
      @data = data
    end
  end

  class ParseError < Error
    def initialize(data=nil)
      super(-32700, "Parse error", data)
    end
  end

  class InvalidRequestError < Error
    def initialize(data=nil)
      super(-32600, "Invalid Request", data)
    end
  end

  class MethodNotFoundError < Error
    def initialize(data=nil)
      super(-32601, "Method not found", data)
    end
  end

  class InvalidParamsError < Error
    def initialize(data=nil)
      super(-32602, "Invalid params", data)
    end
  end

  class InternalError < Error
    def initialize(data=nil)
      super(-32603, "Internal error", data)
    end
  end


  class ServerError < Error 
    def initialize(code, message, data)
      if !(-32099..-32000).include?(code)
        raise InvalidServerErrorCode 
      end
      super(code, message, data)
    end
  end

end