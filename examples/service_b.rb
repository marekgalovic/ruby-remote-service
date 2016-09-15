require "bundler/setup"
require 'remote_service'

class ServiceB < RemoteService::Service
  def users
    [{id: 1, name: 'John', surname: 'Doe'}]
  end
end

ServiceB.start(brokers: ['nats://127.0.0.1:6222'])