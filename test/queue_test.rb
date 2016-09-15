require 'test_helper'

class QueueTest < Minitest::Test
  def test_queue_uses_singleton
    assert_raises NoMethodError do
      ::RemoteService::Queue.new
    end
  end

  def test_connect_initializes_nats_connection
    NATS.expects(:start).with(servers: ['nats://127.0.0.1:4222']).once

    ::RemoteService::Queue.instance.connect(brokers: ['nats://127.0.0.1:4222']) do
    end
  end
end
