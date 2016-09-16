require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Proxy
  timeout 100
end

RemoteService.logger.level = Logger::DEBUG
RemoteService.connect(brokers: ['nats://127.0.0.1:4222'])

puts ServiceA.update(123)

