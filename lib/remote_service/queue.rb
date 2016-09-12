require 'singleton'
require 'json'
require 'securerandom'
require 'bunny'

module RemoteService
  class Queue
    include Singleton

    def initialize
      @conn = Bunny.new(host: "localhost", port: 5672)
      @handlers = {}
    end

    def start(service=nil)
      @conn.start
      @service = service
      queue_subscriber.subscribe(block: should_block?) do |delivery_info, properties, payload|
        handler(properties.correlation_id).handle(decode(payload), properties.reply_to, properties.correlation_id)
      end
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

    def remove_handler(correlation_id)
      @handlers.delete(correlation_id)
    end

    private
    def channel
      @channel ||= @conn.create_channel
    end

    def exchange
      @exchange ||= channel.default_exchange
    end

    def queue_subscriber
      @queue_subscriber ||= channel.queue(queue_name)
    end

    def should_block?
      @service != nil
    end

    def register_handler(correlation_id, handler)
      @handlers[correlation_id] = handler
    end

    def handler(correlation_id)
      return @service if @service
      @handlers[correlation_id]
    end

    def queue_name
      return @service.class.queue_name if @service
      SecureRandom.uuid
    end

    def encode(payload)
      JSON.generate(payload)
    end

    def decode(payload)
      JSON.parse(payload)
    end
  end
end