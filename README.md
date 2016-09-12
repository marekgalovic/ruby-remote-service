# RemoteService

Remote services made easy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'remote_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remote_service

## Usage

First you need to define and run your service. Minimal service can be run with a following script. Return value of each action will be sent back as a response.
```ruby
require "remote_service"

class ServiceA < RemoteService::Service
  def all(count, keyword)
    count
  end
end

ServiceA.start
```

To call this service from remote machine, one need to define service proxy. Following script is an example of how can we execute remote call to the service defined above.
```ruby
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
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/remote_service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

