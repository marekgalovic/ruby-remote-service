require 'securerandom'
require 'singleton'
require 'msgpack'

module RemoteService
  class Queue
    include Singleton

    def initialize
      # at_exit { stop }
    end

    def connect(brokers, service_handler=nil, workers=16)
      @conn = RemoteService::Connector::Nats.new(brokers)
      @service_handler = service_handler
      @workers = workers
      return service_subscriber if service?
      @conn.start
    end

    def request(queue, payload)
      RemoteService.logger.debug "REQUEST - SERVICE:[#{queue}] PAYLOAD:[#{payload}]"
      sent_at = Time.now.utc
      @conn.request(queue, encode(payload)) do |response|
        data = decode(response)
        response_time = (Time.now.utc - sent_at)*1000
        RemoteService.logger.debug "RESPONSE - SERVICE:[#{queue}] PAYLOAD:[#{data}] TIME:[#{response_time}ms]"
        yield(data)
      end
    end

    def publish(queue, payload)
      @conn.publish(queue, encode(payload))
    end

    def stop
      @conn.stop
    end

    private

    def service_subscriber
      @conn.subscribe(service_queue_name) do |request, reply_to|
        payload = decode(request)
        RemoteService.logger.debug "FETCHED - REPLY_TO:[#{reply_to}] PAYLOAD:[#{payload}]"
        @service_handler.handle(payload, reply_to)
      end
    end

    def service?
      @service_handler != nil
    end

    def service_queue_name
      @service_handler.class.queue_name if @service_handler
    end

    def log_message(action, queue, reply_to, payload)
      "#{action.to_s.upcase} - QUEUE:[#{queue}] REPLY_TO:[#{reply_to}] PAYLOAD:[#{payload}]"
    end

    def encode(payload)
      MessagePack.pack(payload)
    end

    def decode(payload)
      MessagePack.unpack(payload)
    end
  end
end