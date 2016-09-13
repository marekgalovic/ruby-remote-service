require "bundler/setup"
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword)
    count
  end
end

ServiceA.start(brokers: ['localhost:5672'])