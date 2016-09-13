require "bundler/setup"
require 'remote_service'

class ServiceB < RemoteService::Service
  def users
    # raise StandardError, 'Unable to respond.'
    [{id: 1, name: 'John', surname: 'Doe'}]
  end
end

RemoteService.logger.level = Logger::DEBUG
ServiceB.start(brokers: ['localhost:5672'], workers: 20)