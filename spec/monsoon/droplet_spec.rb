require 'spec_helper'

describe Monsoon::Droplet do
  let(:schema) {
    {
      'analytics' => {
        'play' => {
          '1.1' => ['user_id', 'timestamp'],
          '2.0' => ['resource_id', 'timestamp']
        }
      }
    }
  }
  let(:record) {
    {
      'event' => 'play',
      'user_id' => 1,
      'timestamp' => 360,
      'resource_id' => '23'
    }
  }
  let(:stream_adapter1) { AdapterTest.new }
  let(:stream_adapter2) { AdapterTest.new }


  before {
    Monsoon.versions_schema = schema
    Monsoon.default_stream = 'analytics'
    Monsoon.streams << stream_adapter1
    Monsoon.streams << stream_adapter2
  }

  describe 'new' do
    it 'saves the passed arguments' do
      droplet = Monsoon::Droplet.new(record, {versioning: nil})
      expect(droplet.stream_name).to eq('analytics')
      expect(droplet.options).to eq({versioning: nil})
      expect(droplet.raw_data).to eq(record)
    end

    it 'saves the passed arguments, using stream from record' do
      droplet = Monsoon::Droplet.new(record.merge({'stream' => 'videos'}), {versioning: :skip, partition_key: 'bob'})
      expect(droplet.stream_name).to eq('videos')
      expect(droplet.options).to eq({versioning: :skip, partition_key: 'bob'})
      expect(droplet.raw_data).to eq(record)
    end

    it 'raises an error if no stream is provided' do
      Monsoon.default_stream = nil
      expect{Monsoon::Droplet.new(record)}.to raise_error(ArgumentError)
    end

    it 'computes the versioned droplets' do
      droplet = Monsoon::Droplet.new(record, {versioning: nil})
      expect(droplet.data).to eq(Monsoon::VersionsSchema.new('analytics', 'play').get_droplets(record))
    end

    it 'returns the raw record in an array if no versioned droplets' do
      droplet = Monsoon::Droplet.new(record.merge({'stream' => 'videos'}), {versioning: nil})
      expect(droplet.data).to eq([record])
    end

    it 'returns the raw record in an array if versioning is skipped' do
      droplet = Monsoon::Droplet.new(record, {versioning: :skip})
      expect(droplet.data).to eq([record])
    end

    it 'returns empty array if no versioned droplets and versioning is enforced' do
      droplet = Monsoon::Droplet.new(record.merge({'stream' => 'videos'}), {versioning: :enforce})
      expect(droplet.data).to eq([])
    end

    it 'returns the raw record in an array if no event provided' do
      record['event'] = nil
      droplet = Monsoon::Droplet.new(record)
      expect(droplet.data).to eq([record])
    end
  end

  describe '#stream' do
    it 'writes data to all configured stream adapters' do
      Monsoon::Droplet.new(record).stream
      expect(stream_adapter1.stream).to eq('analytics')
      expect(stream_adapter1.data).to eq(Monsoon::VersionsSchema.new('analytics', 'play').get_droplets(record))
      expect(stream_adapter1.options).to eq({})
      expect(stream_adapter2.stream).to eq('analytics')
      expect(stream_adapter2.options).to eq({})
      expect(stream_adapter2.data).to eq(Monsoon::VersionsSchema.new('analytics', 'play').get_droplets(record))
    end

    it 'passes all options to stream adapters' do
      Monsoon::Droplet.new(record, {versioning: :skip, partition_key: 'bob'}).stream
      expect(stream_adapter1.options).to eq({versioning: :skip, partition_key: 'bob'})
      expect(stream_adapter2.options).to eq({versioning: :skip, partition_key: 'bob'})
    end

    it 'writes data to specified stream adapter' do
      new_stream_adapter = AdapterTest.new
      Monsoon::Droplet.new(record, {hippo: :animal}).stream(new_stream_adapter)
      expect(new_stream_adapter.stream).to eq('analytics')
      expect(new_stream_adapter.data).to eq(Monsoon::VersionsSchema.new('analytics', 'play').get_droplets(record))
      expect(new_stream_adapter.options).to eq({hippo: :animal})
      expect(stream_adapter1.stream).to be_nil
      expect(stream_adapter1.data).to eq([])
      expect(stream_adapter1.options).to be_nil
    end

    it 'does nothing if no stream adapters configured' do
      Monsoon.streams = []
      Monsoon::Droplet.new(record).stream
      expect(stream_adapter1.stream).to be_nil
      expect(stream_adapter1.data).to eq([])
    end
  end

  describe '#blank?' do
    it 'returns true if droplet has no data' do
      droplet = Monsoon::Droplet.new(record.merge({stream: 'videos'}), {versioning: :enforce})
      expect(droplet.blank?).to eq(true)
    end

    it 'returns false if droplet has data' do
      droplet = Monsoon::Droplet.new(record.merge({stream: 'videos'}), {versioning: nil})
      expect(droplet.blank?).to eq(false)
    end
  end
end

class AdapterTest
  attr_reader :stream
  attr_reader :data
  attr_reader :options

  def initialize
    @data = []
    @stream = nil
    @options = nil
  end

  def put_records(stream, records, options = {})
    @stream = stream
    @data = records
    @options = options
  end
end
