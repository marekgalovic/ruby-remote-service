require 'logger'
require 'benchmark'
require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Proxy
  timeout 100
end

class ServiceB < RemoteService::Proxy
  timeout 100
end

RemoteService.logger.level = Logger::DEBUG
RemoteService.connect(brokers: ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222', 'nats://127.0.0.1:6222'])

ServiceA.all(123, keyword: 'value')
ServiceB.users

