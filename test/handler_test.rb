require "test_helper"
module Flung
  class HandlerTest < Minitest::Test

    class TestHandler
      extend Flung::Handler

      def sum(x, y)
        puts x, y
      end

      def hello_world()
        puts "Greetings, Earthling."
      end

      private 
      def the_hidden_method
        puts "I should be hidden."
      end
    end

    def test_exposed_methods
      handler = TestHandler.new

      assert_equal 2, handler.class.exposed_methods.count
      assert handler.class.exposed_methods.include?(:sum)
      assert handler.class.exposed_methods.include?(:hello_world)
    end


    def test_hidden_methods
      handler = TestHandler.new

      assert_equal 2, handler.class.exposed_methods.count
      refute handler.class.exposed_methods.include?(:the_hidden_method)
    end
  end
end
