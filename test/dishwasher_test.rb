require "test_helper"

class DishwasherTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Dishwasher::VERSION
  end
end
