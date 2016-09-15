require 'securerandom'
require 'singleton'
require 'msgpack'

module RemoteService
  class Queue
    include Singleton

    EXIT_SIGNALS = ['INT', 'TERM', 'SIGQUIT']

    def connect(brokers, &block)
      brokers ||= ENV.fetch('REMOTE_SERVICE_BROKERS', 'nats://127.0.0.1:4222').split(',')
      @conn = Connector::Nats.new(brokers)
      @conn.start(&block)
    end

    def service(service_handler, workers, monitor_interval)
      workers ||= ENV.fetch('REMOTE_SERVICE_WORKERS', 4)
      monitor_interval ||= ENV.fetch('REMOTE_SERVICE_MONITOR_INTERVAL', 5)
      @worker_pool = WorkerPool.new(workers.to_i, monitor_interval.to_i)
      @service_handler = service_handler
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
      @worker_pool.start
      @conn.subscribe(service_queue_name) do |*args|
        @worker_pool.run(*args) do |request, reply_to|
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

    def setup_signal_handlers
      EXIT_SIGNALS.each do |sig|
        trap(sig) do
          @worker_pool.exit if service?
          @conn.exit if !service?
          EM.stop
        end
      end
    end
  end
end