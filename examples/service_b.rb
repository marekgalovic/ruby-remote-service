require "bundler/setup"
require 'remote_service'

class ServiceB < RemoteService::Service
  def users
    [{id: 1, name: 'John', surname: 'Doe'}]
  end
end

ServiceB.start(brokers: ['localhost:5672'], workers: 16)