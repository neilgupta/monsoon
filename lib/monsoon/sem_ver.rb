# This is a helper class for parsing and comparing semantic version strings (eg "1.1.0")
module Monsoon
  class SemVer
    include Comparable
    attr_reader :major, :minor, :patch

    def initialize(version)
      version = version.to_s if version.is_a?(Symbol)
      raise ArgumentError, 'Not a valid semantic version' unless self.class.valid?(version)

      ver = version.split('.')
      @major = ver[0].to_i
      @minor = ver[1].to_i
      @patch = ver[2].to_i
    end

    def <=> (other)
      other = self.class.new(other) if self.class.valid?(other)
      [major, minor, patch] <=> [other.major, other.minor, other.patch] if other.is_a?(self.class)
    end

    def to_s
      "#{major}.#{minor}.#{patch}"
    end

    def self.valid?(version)
      version = version.to_s if version.is_a?(Symbol)
      version.is_a?(String) && version.split('.').take(3).map(&:to_i).reduce(0, :+) > 0
    end
  end
end
