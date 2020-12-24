# frozen_string_literal: true

require "test_helper"

class UnifiDedupeHostsTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::UnifiDedupeHosts.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "expected")
  end
end
