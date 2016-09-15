require 'test_helper'

class WorkerPoolTest < Minitest::Test
  def setup
    @pool = RemoteService::WorkerPool.new(4, 10)
  end

  def test_start_spawns_correct_number_of_threads
    @pool.start

    assert_equal 4, @pool.threads.size
    @pool.exit
  end

  def test_run_parallelizes_workload_across_threads
    started_at = Time.now.utc

    @pool.start
    expectations = []
    4.times do
      expectation = {m: Mutex.new, cv: ConditionVariable.new}
      @pool.run(expectation) do |expectation|
        sleep(1)
        expectation[:m].synchronize{ expectation[:cv].signal }
      end
      expectations << expectation
    end

    threads = []
    expectations.each do |expectation|
      threads << Thread.new { expectation[:m].synchronize { expectation[:cv].wait(expectation[:m]) } }
    end
    threads.each { |t| t.join.exit }

    assert (Time.now.utc - started_at) < 1.1
    @pool.exit
  end
end