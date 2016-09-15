require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword:)
    keyword
  end
end

RemoteService.logger.level = Logger::INFO
ServiceA.start(brokers: ['nats://localhost:4222'])