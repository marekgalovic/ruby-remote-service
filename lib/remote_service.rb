require "remote_service/version"
require "remote_service/errors"
require "remote_service/queue"
require "remote_service/call"
require "remote_service/base"
require "remote_service/service"
require "remote_service/proxy"
require 'logger'

module RemoteService
  extend self
  attr_writer :logger

  def start(*args)
    queue = Queue.instance
    queue.connect(*args)
    queue.start
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
