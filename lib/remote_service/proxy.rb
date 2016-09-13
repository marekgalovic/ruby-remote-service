module RemoteService
  class Proxy < Base
    class << self
      def method_missing(method_name, *args, &block)
        service_call(method_name, args, &block)
      end

      def timeout(time)
        @timeout = time
      end

      private

      def service_call(action, payload, &block)
        Call.new(self.queue_name, action, payload, timeout: @timeout).run(&block)
      end
    end
  end
end