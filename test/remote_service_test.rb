require 'test_helper'

class RemoteServiceTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RemoteService::VERSION
  end
end
