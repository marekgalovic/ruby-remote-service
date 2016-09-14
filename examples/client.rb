require 'logger'
require 'benchmark'
require "bundler/setup"
require "remote_service"

RemoteService.logger.level = Logger::ERROR
RemoteService.connect(brokers: ['localhost:5672'])

class ServiceA < RemoteService::Proxy
  timeout 1000000
end

class ServiceB < RemoteService::Proxy
  timeout 1000
end

clients = []
100.times do
  clients << Thread.new do
    1.times do
      ServiceA.all(123, keyword: 'value')
    end
  end
end

puts Benchmark.measure {
  clients.each do |client|
    client.join
  end
}