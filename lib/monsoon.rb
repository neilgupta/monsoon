require 'monsoon/sem_ver'
require 'monsoon/versions_schema'
require 'monsoon/droplet'

module Monsoon
  @@streams = []
  @@versions_schema = {}
  @@default_stream = nil

  def self.streams
    @@streams
  end

  def self.streams=(streams)
    @@streams = streams
  end

  def self.versions_schema
    @@versions_schema
  end

  def self.versions_schema=(versions_schema)
    @@versions_schema = versions_schema
  end

  def self.default_stream
    @@default_stream
  end

  def self.default_stream=(stream_name)
    @@default_stream = stream_name
  end
end
