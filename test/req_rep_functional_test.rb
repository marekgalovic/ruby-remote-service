require 'test_helper'

class ReqRepFunctionalTest < Minitest::Test
  module Service
    class ServiceA < ::RemoteService::Service
      def all(count)
        count
      end

      def method_that_raises
        raise StandardError
      end
    end
  end

  module Proxy
    class ServiceA < ::RemoteService::Proxy
      timeout 10
    end
  end

  def setup
    Thread.new do
      Service::ServiceA.start(brokers: ['nats://127.0.0.1:4222'])
    end
  end

  def test_remote_method_is_called_through_local_proxy
    RemoteService.connect(brokers: ['nats://127.0.0.1:4222'])
    sleep(0.1) #wait for service's eventmachine to start (improves stability, needed only in test)

    assert_equal 123, Proxy::ServiceA.all(123)
  end

  def test_remote_method_is_called_through_local_proxy
    RemoteService.connect(brokers: ['nats://127.0.0.1:4222'])
    sleep(0.1) #wait for service's eventmachine to start (improves stability, needed only in test)

    assert_raises ::RemoteService::Errors::RemoteCallError do
      Proxy::ServiceA.method_that_raises
    end
  end
end