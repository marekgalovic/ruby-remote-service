require 'test_helper'

class QueueTest < Minitest::Test
  def test_queue_uses_singleton
    assert_raises NoMethodError do
      ::RemoteService::Queue.new
    end
  end

  def test_connect_initializes_nats_connection
    NATS.expects(:start).with(
      servers: ['nats://127.0.0.1:4222'],
      dont_randomize_servers: true,
      reconnect_time_wait: 0.2,
      max_reconnect_attempts: 5
    ).once

    ::RemoteService::Queue.instance.connect(['nats://127.0.0.1:4222']) do
      EM.stop
    end
  end
end
