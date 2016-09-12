require "bundler/setup"
require "remote_service"

RemoteService.start

class ServiceA < RemoteService::Proxy
end

#non-blocking call
ServiceA.all(123, keyword: 'value') do |result|
  puts result
end
sleep(0.1)

#blocking call
puts ServiceA.all(123, keyword: 'value')