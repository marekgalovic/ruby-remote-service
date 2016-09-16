require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def update(payload)
    payload
  end
end

RemoteService.logger.level = Logger::INFO
ServiceA.start(brokers: ['nats://localhost:4222', 'nats://localhost:5222'])