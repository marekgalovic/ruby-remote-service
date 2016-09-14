require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword)
    sleep(0.1)
    count
  end
end

RemoteService.logger.level = Logger::DEBUG
ServiceA.start(brokers: ['nats://127.0.0.1:4222'])