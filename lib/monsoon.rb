require 'monsoon/sem_ver'
require 'monsoon/versions_schema'
require 'monsoon/droplet'

module Monsoon
  @@streams = []
  @@versions_schema = {}

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
end
