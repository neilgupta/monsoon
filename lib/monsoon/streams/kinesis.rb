require 'aws-sdk'

module Monsoon
  module Streams
    class Kinesis
      def initialize
        @client = Aws::Kinesis::Client.new
      end

      def put_records(stream, records, options = {})
        data = records.map do |r|
          {
            data: JSON.generate(r),
            partition_key: options[:partition_key] || r['event'] || r[:event] || r['droplet_version'] || 'monsoon'
          }
        end
        @client.put_records(records: data, stream_name: stream)
      end
    end
  end
end

Monsoon.streams << Monsoon::Streams::Kinesis.new
