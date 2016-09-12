require 'securerandom'
require 'timeout'
require 'json'

module RemoteService
  class Call
    attr_reader :queue, :action, :params, :timeout

    def initialize(queue, action, params, timeout: 10)
      @queue = queue
      @action = action
      @params = params
      @timeout = timeout / 1000.0
      @timestamp = Time.now.utc
    end

    def id
      @id ||= SecureRandom.uuid
    end

    def response(&block)
      return call_service_synchronously if !block_given?
      call_service(&block)
    end

    def rpc_payload
      {action: action, params: params}
    end

    def handle(payload, *)
      RemoteService.logger.info "CALL ID:[#{id}] PARAMS:#{params} TIME: #{(Time.now.utc - @timestamp)*1000}ms"
      @callback.call(payload['result'])
    end

    private

    attr_reader :mutex, :condition

    def call_service(&block)
      @callback = block
      Queue.instance.publish(rpc_payload, queue, id, self)
    end

    def call_service_synchronously
      lock
      call_service do |response|
        unlock(response)
      end
      Timeout.timeout(timeout) {
        mutex.synchronize{condition.wait(mutex)}
        @response
      }
    rescue Timeout::Error
      Queue.instance.remove_handler(id)
      raise
    end

    def lock
      @mutex = Mutex.new
      @condition = ConditionVariable.new
    end

    def unlock(response)
      @response = response
      mutex.synchronize{condition.signal}
    end
  end
end