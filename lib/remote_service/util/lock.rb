module RemoteService
  module Util
    class Lock
      def initialize
        @mutex = Mutex.new
        @condition = ConditionVariable.new
      end

      def unlock(*return_value)
        @return_value = *return_value
        @mutex.synchronize{ @condition.signal }
      end

      def wait
        @mutex.synchronize{ @condition.wait(@mutex) }
        @return_value
      end
    end
  end
end