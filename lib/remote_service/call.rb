require 'securerandom'
require 'timeout'

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
      lock
      call_service do |response, error|
        unlock(response, error)
      end
      Timeout.timeout(timeout) {
        @mutex.synchronize{ @condition.wait(@mutex) }
        raise remote_error if @error
        @response
      }
    end

    def lock
      @mutex = Mutex.new
      @condition = ConditionVariable.new
    end

    def unlock(response, error)
      @response = response
      @error = error
      @mutex.synchronize{@condition.signal}
    end

    def remote_error
      RemoteService.logger.error("RPC_ERROR - SERVICE:[#{queue}] ACTION:[#{action}] ERROR:#{@error}")
      Errors::RemoteCallError.new(@error['name'], @error['message'], @error['backtrace'])
    end
  end
end