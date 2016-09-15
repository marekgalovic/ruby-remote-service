$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'remote_service'

require 'minitest/autorun'
require 'mocha/mini_test'

RemoteService.logger.level = Logger::FATAL
