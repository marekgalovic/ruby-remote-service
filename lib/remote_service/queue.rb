require 'securerandom'
require 'singleton'
require 'msgpack'
require 'bunny'

module RemoteService
  class Queue
    include Singleton

    def initialize
      @handlers = {}
    end

    def connect(brokers:, workers:16)
      @conn = Bunny.new(host: brokers.first)
      @workers = workers
    end

    def start(service=nil)
      @conn.start
      @service = service
      queue_subscriber.subscribe(block: service?) do |delivery_info, properties, payload|
        pop_handler(properties.correlation_id).handle(decode(payload), properties.reply_to, properties.correlation_id)
      end
    end

    def stop
      @conn.stop
    end

    def publish(payload, queue, correlation_id, handler=nil)
      register_handler(correlation_id, handler)
      exchange.publish(
        encode(payload),
        routing_key: queue,
        reply_to: queue_subscriber.name,
        correlation_id: correlation_id
      )
    end

    private
    def channel
      @channel ||= @conn.create_channel(nil, @workers)
    end

    def exchange
      @exchange ||= channel.default_exchange
    end

    def queue_subscriber
      @queue_subscriber ||= channel.queue(queue_name)
    end

    def service?
      @service != nil
    end

    def register_handler(correlation_id, handler)
      @handlers[correlation_id] = handler
    end

    def pop_handler(correlation_id)
      return @service if @service
      @handlers[correlation_id]
    ensure
      @handlers.delete(correlation_id)
    end

    def queue_name
      return @service.class.queue_name if @service
      SecureRandom.uuid
    end

    def encode(payload)
      MessagePack.pack(payload)
    end

    def decode(payload)
      MessagePack.unpack(payload)
    end
  end
end