require 'singleton'

module RemoteService
  class Service < Base
    include Singleton

    def handle(payload, reply_to)
      result = method(payload['action'].to_sym).call(*payload['params'])
      RemoteService.logger.debug "RESULT - ACTION:[#{payload['action']}] REPLY_TO:[#{reply_to}] PARAMS:[#{payload['params']}] RESULT:[#{result}]"
      Queue.instance.publish(reply_to, {result: result})
    end

    private

    class << self
      def start(brokers, workers=16)
        queue = Queue.instance
        queue.connect(brokers) do
          queue.service(self.instance, workers)
        end
      end
    end
  end
end