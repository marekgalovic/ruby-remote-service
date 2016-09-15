require 'nats/client'

module RemoteService
  module Connector
    class Nats
      attr_reader :brokers

      def initialize(brokers:)
        @brokers = brokers
      end

      def start(&block)
        return connection_thread if !block_given?
        connect(&block)
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
        NATS.subscribe(service_queue, queue: service_queue, &block)
      end

      private

      attr_reader :connection

      def connect
        NATS.start(servers: @brokers) do |connection|
          RemoteService.logger.info "CONNECTED: #{connection.connected_server}"
          RemoteService.logger.info "SERVERS IN POOL: #{connection.server_pool.count}"
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
        lock = Util::Lock.new
        Thread.new do
          connect do |connection|
            lock.unlock(connection)
          end
        end
        lock.wait
      end
    end
  end
end
