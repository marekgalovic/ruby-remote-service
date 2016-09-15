module RemoteService
  class WorkerPool
    attr_reader :queue, :threads

    def initialize(worker_count, monitor_interval)
      @worker_count = worker_count
      @monitor_interval = monitor_interval
      @threads = []
      @queue = ::Queue.new
    end

    def run(*args, &block)
      queue.push({ args: args, callable: block })
    end

    def start
      spawn_workers
      monitor_thread
      RemoteService.logger.info "WORKER POOL - WORKERS: #{threads.size}"
    end

    def join
      threads.each do |thread|
        thread.join
      end
      monitor_thread.join
    end

    def exit
      threads.each do |thread|
        thread.exit
      end
      monitor_thread.exit
    end

    private

    def spawn_workers
      @worker_count.times do
        @threads << Thread.new do
          loop do
            data = queue.pop
            data[:callable].call(*data[:args])
          end
        end
      end
    end

    def monitor_thread
      @monitor_thread ||= begin
        RemoteService.logger.info "WORKER POOL - MONITOR INTERVAL: #{@monitor_interval}s"
        Thread.new do
          loop do
            RemoteService.logger.info "WORKER POOL - WAITING: #{queue.size}"
            sleep(@monitor_interval)
          end
        end
      end
    end
  end
end