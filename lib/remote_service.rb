require "remote_service/version"
require "remote_service/errors"
require "remote_service/util/lock"
require "remote_service/connector/nats"
require "remote_service/queue"
require "remote_service/call"
require "remote_service/base"
require "remote_service/service"
require "remote_service/proxy"
require 'logger'

module RemoteService
  extend self
  attr_writer :logger

  def connect(brokers, &block)
    queue = Queue.instance
    queue.connect(brokers, &block)
  end

  def disconnect
    Queue.instance.stop
  end

  def logger
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO
      logger
    end
  end
end
