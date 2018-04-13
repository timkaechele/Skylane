require "test_helper"
module Flung
  class HandlerTest < Minitest::Test

    class TestHandler
      extend Flung::Handler

      def sum(x, y)
        puts x, y
      end

      def hello_world()
        puts "Hello this is a test"
      end
    end

    def test_exposed_methods
      handler = TestHandler.new

      assert_equal handler.class.exposed_methods.count, 2
      assert handler.class.exposed_methods.include?(:sum)
      assert handler.class.exposed_methods.include?(:hello_world)
    end



  end
end
