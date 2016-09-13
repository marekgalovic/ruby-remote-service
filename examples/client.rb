require 'logger'
require "bundler/setup"
require "remote_service"

RemoteService.connect(brokers: ['localhost:5672'])

class ServiceA < RemoteService::Proxy
  timeout 100
end

class ServiceB < RemoteService::Proxy
  timeout 100
end

puts ServiceA.all(123, keyword: 'value')
puts ServiceB.users