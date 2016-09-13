require 'securerandom'
require 'timeout'
require 'json'

module RemoteService
  class Call
    attr_reader :queue, :action, :params, :timeout

    def initialize(queue, action, params, timeout:)
      @queue = queue
      @action = action
      @params = params
      @timeout = (timeout || 10) / 1000.0
    end

    def id
      @id ||= SecureRandom.uuid
    end

    def run(&block)
      return call_service_synchronously if !block_given?
      call_service(&block)
    end

    def handle(payload, *)
      RemoteService.logger.info "CALL ID:[#{id}] PARAMS:#{params} TIME: #{(Time.now.utc - @sent_at)*1000}ms"
      @callback.call(payload['result'], payload['error'])
    end

    private

    attr_reader :mutex, :condition

    def call_service(&block)
      @callback = block
      @sent_at = Time.now.utc
      Queue.instance.publish({action: action, params: params}, queue, id, self)
    end

    def call_service_synchronously
      lock
      call_service do |*params|
        unlock(*params)
      end
      Timeout.timeout(timeout) {
        mutex.synchronize{condition.wait(mutex)}
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
      mutex.synchronize{condition.signal}
    end

    def remote_error
      Errors::RemoteCallError.new(@error['name'], @error['message'], @error['backtrace'])
    end
  end
end