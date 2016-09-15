require "bundler/setup"
require 'remote_service'

class ServiceB < RemoteService::Service
  def users
    # raise StandardError, 'Unable to respond.'
    [{id: 1, name: 'John', surname: 'Doe'}]
  end
end

RemoteService.logger.level = Logger::DEBUG
ServiceB.start(brokers: ['nats://127.0.0.1:6222'])