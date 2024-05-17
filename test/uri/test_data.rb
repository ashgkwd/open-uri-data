# frozen_string_literal: true

require "test_helper"

class URI::TestData < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::URI::Data::VERSION
  end

  # TODO: Write tests for URI::Data.new and others
end
