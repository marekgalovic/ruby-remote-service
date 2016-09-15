require 'test_helper'

class CallTest < Minitest::Test
  def setup
    @call = ::RemoteService::Call.new('services.test', :method, [123, { foo: :bar }], timeout: 100)
  end

  def test_converts_timeout
    assert_equal 0.1, @call.timeout
  end

  def test_run_will_initalize_request_with_correct_params
    ::RemoteService::Queue.instance.expects(:request)
      .with('services.test', { action: :method, params: [123, { foo: :bar }] }).yields({ 'result': nil }).once

    @call.run do
    end
  end

  def test_run_will_raise_timeout_error_when_nothing_yielded
    ::RemoteService::Queue.instance.expects(:request).once

    assert_raises Timeout::Error do
      @call.run
    end
  end
end
