require "test_helper"

class FlungTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Flung::VERSION
  end
end
