require 'nats/client'

module RemoteService
  module Connector
    class Nats
      attr_reader :brokers

      def initialize(brokers)
        @brokers = brokers
      end

      def start
        connection_thread
      end

      def stop
        NATS.stop
        stop_subscriber
        connection_thread.exit
      end

      def publish(to_queue, message)
        NATS.publish(to_queue, message)
      end

      def request(to_queue, message, &block)
        NATS.request(to_queue, message, &block)
      end

      def subscribe(service_queue, &block)
        connect do
          RemoteService.logger.debug "SERVICE QUEUE: #{service_queue}"
          NATS.subscribe(service_queue, queue: service_queue, &block)
        end
      end

      private

      attr_reader :connection

      def connect
        NATS.start(brokers: @brokers) do |connection|
          RemoteService.logger.info "CONNECTED: #{connection.connected_server}"
          connection.on_reconnect do
            RemoteService.logger.info "RECONNECT, NEW_NODE: #{connection.connected_server}"
          end
          connection.on_disconnect do |reason|
            RemoteService.logger.info "DISCONNECTED: #{reason}"
          end
          yield(connection)
        end
      end

      def connection_thread
        @connection_thread ||= begin
          mutex = Mutex.new
          condition = ConditionVariable.new
          conn_thread = Thread.new do
            connect do
              mutex.synchronize{condition.signal}
            end
          end
          mutex.synchronize{condition.wait(mutex)}
          conn_thread
        end
      end
    end
  end
end