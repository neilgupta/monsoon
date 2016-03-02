module Monsoon
  class Droplet
    attr_reader :stream_name
    attr_reader :options
    attr_reader :raw_data
    attr_reader :data

    # new - creates a droplet
    #   data - hash of data to write to stream (required)
    #   options - optional hash
    #     :versioning => can be :skip, :enforce, or nil
    #       :skip will ignore the versions schema and write the data exactly as passed
    #       :enforce will require using the schema and will write nothing if unable to version
    #       nil will try to write versioned droplets and fallback to raw data (default)
    #     :partition_key => the partition key to use for kinesis
    #
    # @example
    #   Monsoon::Droplet.new({stream: 'transcodes', event: 'download_complete', filename: 'my_movie.mp4', media_id: 5, url: 'example.com/my_movie.mp4'}, {versioning: :enforce})
    def initialize(raw_data, options = {})
      @stream_name = raw_data.delete(:stream) || raw_data.delete('stream') || Monsoon.default_stream
      raise ArgumentError, "stream not specified" unless @stream_name
      @event = raw_data[:event] || raw_data['event']
      @options = options
      @raw_data = raw_data
      @data = VersionsSchema.new(@stream_name, @event).get_droplets(@raw_data) unless @options[:versioning] == :skip
      @data = [@raw_data] if blank? && @options[:versioning] != :enforce
    end

    # stream - writes the droplet to all configured stream adapters
    #   streamer - (optional) stream adapter instance to limit which adapter is used (adapter must implement `#put_records`)
    #
    # @example
    #   droplet = Monsoon::Droplet.new({stream: 'transcodes', event: 'download_complete', filename: 'my_movie.mp4', media_id: 5, url: 'example.com/my_movie.mp4'})
    #   droplet.stream(Monsoon::Streams::Console.new)
    def stream(streamer = false)
      return if blank?
      streamer ? streamer.put_records(@stream_name, @data, @options) : Monsoon.streams.each {|s| stream(s) }
    end

    def blank?
      @data.nil? || @data.empty?
    end
  end
end
