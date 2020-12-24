# frozen_string_literal: true

require "test_helper"

class UnifiHostsTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::UnifiHosts.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "expected")
  end
end
