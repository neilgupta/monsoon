module Monsoon
  class VersionsSchema
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def get_droplets(record)
      return if record.nil?

      schema.map do |version, keys|
        symbolized_keys = keys.map(&:to_sym)
        # Only keep the record keys that are defined in this version's schema
        versioned_record = record.select{|k,v| symbolized_keys.include?(k.to_sym)}
        # stringify record keys
        versioned_record = Hash[versioned_record.map { |k, v| [k.to_s, v] }]
        # add versioning metadata
        versioned_record.merge({
          'droplet_version' => version.to_s,
          'droplet_deprecated' => deprecated?(version)
        }) if versioned_record.keys.length == keys.length # make sure we got all the keys for this version
      end.compact
    end

    def deprecated?(version)
      SemVer.new(version) < versions.max_by {|v| SemVer.new(v)} unless versions.empty?
    end

    def versions
      schema.keys
    end

    private

    def schema
      @schema ||= Monsoon.versions_schema[@stream.to_sym] || Monsoon.versions_schema[@stream.to_s] || {}
    end
  end
end
