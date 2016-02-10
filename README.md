# Monsoon

[https://www.github.com/neilgupta/monsoon](https://www.github.com/neilgupta/monsoon)

[![Gem Version](https://badge.fury.io/rb/monsoon-droplet.png)](http://badge.fury.io/rb/monsoon-droplet)

Monsoon writes messages to a stream of data. That stream can be anything, from an external service to a log or even an in-memory array, as long as you write an adapter for it. Out of the box, Monsoon includes adapters for AWS Kinesis and stdout.

Monsoon allows you to define versioned contracts for your messages, treating your streams as an API for other clients to consume. Each message sent by Monsoon includes only the keys defined in the contract, the version of the contract used, and whether or not that contract is deprecated.

## Installation

Install the gem on your machine:

```
gem install monsoon-droplet
```

Or add it to your `Gemfile`:

```ruby
gem 'monsoon-droplet'
```

## Setup

Create `/config/initializers/monsoon.rb` and add:

```ruby
require 'monsoon'
require 'monsoon/streams/kinesis'
require 'monsoon/streams/console'

Monsoon.versions_schema = {
  "analytics": {
    "1.0.0": ["user_id", "event_type", "timestamp", "data"],
    "1.0.1": ["user_id", "event_type", "timestamp", "data"],
    "1.1.0": ["user_id", "event_type", "timestamp", "data", "resource_id"],
    "2.0.0": ["event_type", "timestamp", "data", "resource_id"]
  },
  "transcodes": {
    "1.0.0": ["filename", "status"],
    "2.0.0": ["filename", "sources"]
  }
}

# if using the Kinesis stream...
ENV['AWS_ACCESS_KEY_ID'] = "YOUR AWS ACCESS KEY"
ENV['AWS_SECRET_ACCESS_KEY'] = "YOUR AWS SECRET"
ENV['AWS_REGION'] = "YOUR AWS REGION"
```

### Stream Adapters

To add a stream adapter, just require it:

```ruby
require 'monsoon/streams/kinesis'
```

This will add the built-in AWS Kinesis adapter. `monsoon/streams/console` is also built-in for testing by writing your streams to STDOUT.

You can write your own stream adapter by creating a class that implements `#put_records(stream_name, records_array)` and then add it to Monsoon with `Monsoon.streams << YourNewAdapter.new`. See `Monsoon::Streams::Console` for an example.

Monsoon will send your messages to all added streams by default.

### Versions Schema

To auto-generate versioned copies of your message, configure Monsoon with your versions schema. This is just a hash of stream names and keys that tells Monsoon, given a stream name, here's a list of versions we support and the keys each version should include in its message. For example, if you have the following schema defined:

```ruby
Monsoon.versions_schema = {
  "analytics": {
    "1.0.0": ["user_id", "event_type", "timestamp", "data"],
    "1.0.1": ["user_id", "event_type", "timestamp", "data"],
    "1.1.0": ["user_id", "event_type", "timestamp", "data", "resource_id"],
    "2.0.0": ["event_type", "timestamp", "data", "resource_id"]
  },
  "transcodes": {
    "1.0.0": ["filename", "status"],
    "2.0.0": ["filename", "sources"]
  }
}
```

and you want to send the message `{user_id: 1, event_type: 'play', timestamp: 23, data: 'some other data', resource_id: 10}` to your `analytics` stream, Monsoon will automatically generate 4 versions of your message for each defined version. The versioned message will only include the keys needed for that version, as well as 2 new keys: 'droplet_version' and 'droplet_deprecated'. `droplet_version` tells the receiving client which version they're reading, and `version_deprecated` is true if there is a newer version defined in the schema.

If the original message does not include all of the keys needed for an older version (e.g., `user_id` is left out in the above example), then Abacus will only send the versions it has the data for (e.g., it will only send v2.0+ for the 'analytics' stream).

### Droplets

To send a message after you've configured Monsoon, just create a new Droplet and stream it:

```ruby
droplet = Monsoon::Droplet.new("analytics", {user_id: 1, event_type: 'play', timestamp: 23, data: 'some other data', resource_id: 10})
droplet.stream
```

Droplets can also take a hash with the following options:

* `:versioning` - can be `:skip`, `:enforce`, or `nil`
  - `:skip` will ignore the versions schema and write the data exactly as passed
  - `:enforce` will require using the schema and will write nothing if unable to version
  - `nil` will try to write versioned droplets and fallback to raw data (default)

`#stream` can also take an optional stream adapter (any object that implements `#put_records`) to only stream to that adapter. For example:

```ruby
droplet = Monsoon::Droplet.new("my_stream", {user_id: 1, event_type: 'play', timestamp: 23}, {versioning: :skip})
droplet.stream(YourNewAdapter.new)
```

## Author

Neil Gupta [http://metamorphium.com](http://metamorphium.com)

## License

The MIT License (MIT) Copyright (c) 2016 Neil Gupta. See [MIT-LICENSE](https://raw.github.com/neilgupta/monsoon/master/MIT-LICENSE)
