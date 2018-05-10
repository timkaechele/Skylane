require "test_helper"
module Skylane
  class RouterTest < Minitest::Test
    class TestHandler
      extend Skylane::Handler
      def sum(x, y)
        x + y
      end
    end

    def test_add_namespace_with_empty_namespace
      router = Router.new 
      handler = TestHandler.new

      router.add_handler(handler)

      assert_equal handler, router.handler_for("sum")
    end

    def test_add_namespace
      router = Router.new
      root_handler = TestHandler.new
      namespaced_handler = TestHandler.new

      router.add_handler(root_handler)
      router.add_handler(namespaced_handler, "test_namespace")

      assert_equal root_handler, router.handler_for("sum")
      assert_equal namespaced_handler, router.handler_for("test_namespace.sum")
    end

    def test_handler_for_with_missing_function
      router = Router.new

      assert_nil router.handler_for("imaginary_root_function")
      assert_nil router.handler_for("imaginary.function")
    end

    def test_available_functions
      router = Router.new 

      handler = TestHandler.new

      router.add_handler(handler)
      router.add_handler(handler, "testing")

      available_functions = router.available_functions

      assert_equal 2, available_functions.count
      assert available_functions.include?("sum")
      assert available_functions.include?("testing.sum")
    end


    def test_method_for
      router = Router.new
      root_handler = TestHandler.new
      namespaced_handler = TestHandler.new

      root_sum_method = root_handler.method(:sum)
      namespaced_sum_method = namespaced_handler.method(:sum)

      router.add_handler(root_handler)
      router.add_handler(namespaced_handler, "test_namespace")

      assert_equal root_sum_method, router.method_for("sum")
      assert_equal root_sum_method.call(2, 3), router.method_for("sum").call(2, 3)

      assert_equal namespaced_sum_method, router.method_for("test_namespace.sum")
      assert_equal namespaced_sum_method.call(2, 3), 
                   router.method_for("test_namespace.sum").call(2, 3)
    end

    def test_method_for_with_missing_method
      router = Router.new
      handler = TestHandler.new

      router.add_handler(handler)
      router.add_handler(handler, "test")

      assert_nil router.method_for("multiply")
      assert_nil router.method_for("test.multiply")
    end
  end
end
