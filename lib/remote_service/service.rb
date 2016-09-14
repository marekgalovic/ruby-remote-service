require 'singleton'

module RemoteService
  class Service < Base
    include Singleton

    def handle(payload, reply_to)
      result = method(payload['action'].to_sym).call(*payload['params'])
      RemoteService.logger.debug "RESULT - REPLY_TO:[#{reply_to}] PARAMS:[#{payload}] RESULT:[#{result}]"
      Queue.instance.publish(reply_to, {result: result})
    rescue => e
      RemoteService.logger.error(e)
      Queue.instance.publish(
        reply_to,
        {result: nil, error: {name: e.class.name, message: e.message, backtrace: e.backtrace}},
      )
    end

    private

    class << self
      def start(brokers, workers=16)
        queue = Queue.instance
        queue.connect(brokers, self.instance, workers: workers)
      end
    end
  end
end