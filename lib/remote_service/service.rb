require 'singleton'

module RemoteService
  class Service < Base
    include Singleton

    def handle(payload, reply_to)
      result = method(payload['action'].to_sym).call(*prepare_params(payload['params']))
      RemoteService.logger.debug "RESULT - ACTION:[#{payload['action']}] REPLY_TO:[#{reply_to}] PARAMS:[#{payload['params']}] RESULT:[#{result}]"
      respond_with_result(reply_to, result)
    end

    private

    def respond_with_result(reply_to, result)
      Queue.instance.publish(reply_to, {result: result})
    end

    def prepare_params(params)
      params.map { |param| param.is_a?(Hash) ? sym_keys(param) : param }
    end

    def sym_keys(params)
      params.map { |k, v| [k.to_sym, v] }.to_h
    end

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