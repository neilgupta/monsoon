require 'json'

module Monsoon
  module Streams
    class Console
      def put_records(stream, records, options = {})
        records.each do |r|
          puts "Streaming to #{stream}: #{JSON.pretty_generate(r)}"
        end
      end
    end
  end
end

Monsoon.streams << Monsoon::Streams::Console.new
