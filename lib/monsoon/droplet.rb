module Monsoon
  class Droplet
    attr_reader :stream_name
    attr_reader :options
    attr_reader :raw_data
    attr_reader :data

    # new - creates a droplet
    #   stream_name - name of the stream to write to (required)
    #   data - hash of data to write to stream (required)
    #   options - optional hash
    #     :versioning => can be :skip, :enforce, or nil
    #       :skip will ignore the versions schema and write the data exactly as passed
    #       :enforce will require using the schema and will write nothing if unable to version
    #       nil will try to write versioned droplets and fallback to raw data (default)
    #
    # @example
    #   Monsoon::Droplet.new('analytics', {user_id: 3, event_type: 'play'}, {versioning: :enforce})
    def initialize(stream_name, raw_data, options = {})
      @stream_name = stream_name
      @options = options
      @raw_data = raw_data
      @data = VersionsSchema.new(@stream_name).get_droplets(@raw_data) unless @options[:versioning] == :skip
      @data = [@raw_data] if blank? && @options[:versioning] != :enforce
    end

    # stream - writes the droplet to all configured stream adapters
    #   streamer - (optional) stream adapter instance to limit which adapter is used (adapter must implement `#put_records`)
    #
    # @example
    #   droplet = Monsoon::Droplet.new('analytics', {user_id: 3, event_type: 'play'})
    #   droplet.stream(Monsoon::Streams::Console.new)
    def stream(streamer = false)
      return if blank?
      streamer ? streamer.put_records(@stream_name, @data) : Monsoon.streams.each {|s| stream(s) }
    end

    def blank?
      @data.nil? || @data.empty?
    end
  end
end
