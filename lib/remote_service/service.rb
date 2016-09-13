require 'singleton'

module RemoteService
  class Service < Base
    include Singleton

    def handle(payload, reply_to, correlation_id)
      result = method(payload['action'].to_sym).call(*payload['params'])
      Queue.instance.publish({result: result}, reply_to, correlation_id)
    rescue => e
      RemoteService.logger.error(e)
      Queue.instance.publish(
        {result: nil, error: {name: e.class.name, message: e.message, backtrace: e.backtrace}},
        reply_to,
        correlation_id
      )
    end

    private

    class << self
      def start(*args)
        queue = Queue.instance
        queue.connect(*args)
        queue.start(self.instance)
      end
    end
  end
end