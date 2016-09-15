module RemoteService
  class Base
    class << self

      def queue_name
        "services.#{@queue ||= default_queue_name}"
      end

      private

      def queue(name)
        @queue = name
      end

      def default_queue_name
        self.name.split(/::/).last.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").downcase
      end
    end
  end
end
