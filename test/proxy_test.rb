require 'test_helper'

class ProxyTest < Minitest::Test
  class User < ::RemoteService::Proxy; end

  def test_proxy_has_correct_queue_name
    assert_equal 'services.user', User.queue_name
  end

  def test_missing_method_is_proxied_to_call_service_with_correct_params
    User.expects(:service_call).once.with(:remote_method, [123, { foo: :bar }]).returns(true)

    User.remote_method(123, foo: :bar)
  end
end
