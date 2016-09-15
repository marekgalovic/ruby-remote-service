module RemoteService
  class Call
    attr_reader :queue, :action, :params, :timeout

    def initialize(queue, action, params, timeout:)
      @queue = queue
      @action = action
      @params = params
      @timeout = (timeout || 10) / 1000.0
    end

    def run(&block)
      return call_service_synchronously if !block_given?
      call_service(&block)
    end

    private

    def call_service
      Queue.instance.request(queue, {action: action, params: params}) do |response|
        yield(response['result'], response['error'])
      end
    end

    def call_service_synchronously
      lock = Util::Lock.new(timeout)
      call_service do |response, error|
        lock.unlock(response, error)
      end
      response, error = lock.wait
      raise remote_error(error) if error
      response
    end

    def remote_error(error)
      RemoteService.logger.error("RPC_ERROR - SERVICE:[#{queue}] ACTION:[#{action}] ERROR:#{error}")
      Errors::RemoteCallError.new(error['name'], error['message'], error['backtrace'])
    end
  end
end