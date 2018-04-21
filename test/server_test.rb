require "test_helper"
require 'json'
module Flung
  class ServerTest < Minitest::Test
    include Rack::Test::Methods

    class TestHandler
      extend Flung::Handler
      def sum(x, y)
        x + y
      end

      def key_args(x:, y:)
        { x: x, y: y }
      end

      def hello_world
        "Hello World"
      end

      def always_failing_method
        raise ServerError.new(-32001,
                              "Authentication error",
                              data: { user_message: "No auth token provided" })
      end
    end

    def app
      router = Router.new
      router.add_handler(TestHandler.new)

      app = Server.new(router)
      builder = Rack::Builder.new
      builder.run app
    end

    def test_non_post_method_get
      get '/'
      assert last_response.ok?
      assert last_response.body.empty?
    end

    def test_non_post_method_put
      put '/'
      assert last_response.ok?
      assert last_response.body.empty?
    end

    def test_non_post_method_delete
      delete '/'
      assert last_response.ok?
      assert last_response.body.empty?
    end

    def test_with_empty_body
      post '/'

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal -32700, json["error"]["code"]
      assert_equal "Parse error", json["error"]["message"]
      assert_nil json["id"]
    end

    def test_with_valid_request
      post_json({
        jsonrpc: "2.0",
        method: 'sum',
        params: [1, 2],
        id: 1
        })

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal 3, json["result"]
      assert_equal 1, json["id"]
    end


    def test_with_missing_method
      post_json({
        jsonrpc: "2.0",
        method: 'what_is_this',
        id: 1
        })

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal -32601, json["error"]["code"]
      assert_equal 1, json["id"]
    end

   def test_with_empty_batch
      post_json([])

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal -32600, json["error"]["code"]
      assert_nil nil, json["id"]
    end

    def test_with_multiple_batch_entries
      post_json([{
          jsonrpc: "2.0",
          method: 'what_is_this',
          id: 1
        }, {
          jsonrpc: "2.0",
          method: 'sum',
          params: [1, 2],
          id: 2
        }])

      assert last_response.ok?

      assert_equal "2.0", json[0]["jsonrpc"]
      assert_equal -32601, json[0]["error"]["code"]
      assert_equal 1, json[0]["id"]

      assert_equal "2.0", json[1]["jsonrpc"]
      assert_equal 3, json[1]["result"]
      assert_equal 2, json[1]["id"]
    end


    def test_with_empty_params
      post_json({
          jsonrpc: "2.0",
          method: 'hello_world',
          id: 1
        })

      assert last_response.ok?

      assert_equal "2.0", json["jsonrpc"]
      assert_equal "Hello World", json["result"]
      assert_equal 1, json["id"]
    end

    def test_with_invalid_params
      post_json({
          jsonrpc: "2.0",
          method: 'hello_world',
          params: ["what", "is", "this"],
          id: 1
        })

      assert last_response.ok?

      assert_equal "2.0", json["jsonrpc"]
      assert_equal -32602, json["error"]["code"]
      assert_equal 1, json["id"]
    end

    # def test_with_invalid_request_wrong_rpc_version
    #   post_json({
    #       jsonrpc: "2.1",
    #       method: 'hello_world',
    #       params: ["what", "is", "this"],
    #       id: 1
    #     })

    #   assert last_response.ok?

    #   assert_equal "2.0", json["jsonrpc"]
    #   assert_equal -32600, json["error"]["code"]
    #   assert_equal 1, json["id"]
    # end

    # def test_with_invalid_request_no_method_key
    #   post_json({
    #       jsonrpc: "2.0",
    #       method: 'hello_world',
    #       params: ["what", "is", "this"],
    #       id: 1
    #     })

    #   assert last_response.ok?

    #   assert_equal "2.0", json["jsonrpc"]
    #   assert_equal -32600, json["error"]["code"]
    #   assert_equal 1, json["id"]
    # end

    # def test_with_invalid_request_with_empty_method
    #   post_json({
    #       jsonrpc: "2.0",
    #       method: '',
    #       params: ["what", "is", "this"],
    #       id: 1
    #     })

    #   assert last_response.ok?

    #   assert_equal "2.0", json["jsonrpc"]
    #   assert_equal -32600, json["error"]["code"]
    #   assert_equal 1, json["id"]
    # end


    # def test_with_invalid_request_params_string
    #   post_json({
    #       jsonrpc: "2.0",
    #       method: 'hello_world',
    #       params: 'Hello World',
    #       id: 1
    #     })

    #   assert last_response.ok?

    #   assert_equal "2.0", json["jsonrpc"]
    #   assert_equal -32600, json["error"]["code"]
    #   assert_equal 1, json["id"]
    # end


    def test_with_valid_request_and_named_params
      post_json({
        jsonrpc: "2.0",
        method: 'sum',
        params: {x: 1, y: 2},
        id: 1
        })

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal 3, json["result"]
      assert_equal 1, json["id"]
    end

    def test_with_valid_request_named_params_and_key_args
      post_json({
        jsonrpc: "2.0",
        method: 'key_args',
        params: { x: 1, y: 2 },
        id: 1
        })

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal({ "x" =>  1, "y" => 2 }, json["result"])
      assert_equal 1, json["id"]
    end

    def test_with_valid_request_named_params_and_key_args_inverted
      post_json({
        jsonrpc: "2.0",
        method: 'key_args',
        params: { y: 1, x: 2 },
        id: 1
        })

      assert last_response.ok?
      assert_equal "2.0", json["jsonrpc"]
      assert_equal({ "x" => 2, "y" => 1 }, json["result"])
      assert_equal 1, json["id"]
    end

    def post_json(json_hash)
      json = JSON.generate(json_hash)

      post('/', json, { 'CONTENT_TYPE' => 'application/json' })
    end



    def json
      JSON.parse(last_response.body)
    end

  end
end
