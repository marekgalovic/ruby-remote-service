require 'timeout'

module RemoteService
  module Util
    class Lock
      def initialize(timeout=0)
        @mutex = Mutex.new
        @condition = ConditionVariable.new
        @timeout = timeout
      end

      def unlock(*return_value)
        @return_value = *return_value
        @mutex.synchronize{ @condition.signal }
      end

      def wait
        Timeout.timeout(@timeout) do
          @mutex.synchronize{ @condition.wait(@mutex) }
          @return_value
        end
      end
    end
  end
end
