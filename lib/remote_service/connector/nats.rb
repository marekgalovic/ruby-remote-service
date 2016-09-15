require 'nats/client'

module RemoteService
  module Connector
    class Nats
      attr_reader :brokers

      def initialize(brokers)
        @brokers = brokers
        @mutex = Mutex.new
      end

      def start(&block)
        return connection_thread if !block_given?
        connect(&block)
      end

      def exit
        @conn_thread.exit
      end

      def publish(to_queue, message)
        @mutex.synchronize do
          NATS.publish(to_queue, message)
        end
      end

      def request(to_queue, message, &block)
        @mutex.synchronize do
          NATS.request(to_queue, message, &block)
        end
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
        @conn_thread = Thread.new do
          connect do |connection|
            lock.unlock(connection)
          end
        end
        lock.wait
      end
    end
  end
end
