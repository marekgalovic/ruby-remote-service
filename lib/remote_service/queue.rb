require 'securerandom'
require 'singleton'
require 'msgpack'

module RemoteService
  class Queue
    include Singleton

    def connect(brokers, &block)
      @conn = RemoteService::Connector::Nats.new(brokers)
      @conn.start(&block)
    end

    def service(service_handler, workers=16)
      @service_handler = service_handler
      @workers = workers
      start_service_subscriber
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

    def start_service_subscriber
      RemoteService.logger.debug "SERVICE QUEUE: #{service_queue_name}"
      @conn.subscribe(service_queue_name) do |request, reply_to|
        begin
          payload = decode(request)
          RemoteService.logger.debug "FETCHED - REPLY_TO:[#{reply_to}] PAYLOAD:[#{payload}]"
          @service_handler.handle(payload, reply_to)
        rescue => e
          RemoteService.logger.error(e)
          Queue.instance.publish(
            reply_to,
            {result: nil, error: {name: e.class.name, message: e.message, backtrace: e.backtrace}},
          )
        end
      end
    end

    def service?
      @service_handler != nil
    end

    def service_queue_name
      @service_handler.class.queue_name if @service_handler
    end

    def encode(payload)
      MessagePack.pack(payload)
    end

    def decode(payload)
      MessagePack.unpack(payload)
    end
  end
end