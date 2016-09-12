require "bundler/setup"
require 'remote_service'

class ServiceB < RemoteService::Service
  def all

  end
end

ServiceB.run