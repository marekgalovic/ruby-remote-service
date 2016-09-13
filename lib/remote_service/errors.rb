module RemoteService
  module Errors
    class RemoteCallError < StandardError
      attr_accessor :name, :message, :backtrace

      def initialize(name, message, backtrace)
        @name = name
        @message = message
        @backtrace = backtrace
      end
    end
  end
end