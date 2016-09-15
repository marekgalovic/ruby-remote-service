require 'test_helper'

class ServiceTest < Minitest::Test
  def setup
    @user_service = User.instance
  end

  class User < ::RemoteService::Service
    def remote_method(count, foo:)
      return "#{count}:#{foo}"
    end
  end

  def test_service_has_correct_queue_name
    assert_equal 'services.user', User.queue_name
  end

  def test_handle_executes_called_method_with_correct_params
    @user_service.expects(:respond_with_result).with('_INBOX.reply_to_hash', '123:bar').once.returns(true)

    request_payload = { "action"=>"remote_method", "params"=>[123, { "foo"=>"bar" }] }
    @user_service.handle(request_payload, '_INBOX.reply_to_hash')
  end
end
