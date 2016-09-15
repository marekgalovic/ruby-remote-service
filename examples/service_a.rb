require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword:)
    raise StandardError
    keyword
  end
end

ServiceA.start(brokers: ['nats://127.0.0.1:5222'])