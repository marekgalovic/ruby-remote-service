require 'singleton'

module RemoteService
  class Service < Base
    include Singleton

    def handle(payload, reply_to, correlation_id)
      result = method(payload['action'].to_sym).call(*payload['params'])
      Queue.instance.publish({result: result}, reply_to, correlation_id)
    end

    private

    class << self
      def start
        Queue.instance.start(self.instance)
      end
    end
  end
end