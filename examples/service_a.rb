require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword)
    count
  end
end

RemoteService.logger.level = Logger::DEBUG
ServiceA.start(brokers: ['nats://127.0.0.1:4222'])