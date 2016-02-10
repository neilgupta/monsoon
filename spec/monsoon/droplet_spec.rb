require 'spec_helper'

describe Monsoon::Droplet do
  let(:schema) {
    {
      'analytics' => {
        '1.0.0' => ['user_id'],
        '1.1.0' => ['user_id', 'event_type'],
        '2.0.0' => ['resource_id', 'event_type']
      }, 'errors' => {
        '1.0.0' => ['name'],
        '1.1.0' => ['name', 'source']
      }
    }
  }
  let(:record) {
    {
      'user_id' => 1,
      'event_type' => 'play',
      'resource_id' => '23'
    }
  }
  let(:stream_adapter1) { AdapterTest.new }
  let(:stream_adapter2) { AdapterTest.new }


  before {
    Monsoon.versions_schema = schema
    Monsoon.streams << stream_adapter1
    Monsoon.streams << stream_adapter2
  }

  describe 'new' do
    it 'saves the passed arguments' do
      droplet = Monsoon::Droplet.new('analytics', record, {versioning: nil})
      expect(droplet.stream_name).to eq('analytics')
      expect(droplet.options).to eq({versioning: nil})
      expect(droplet.raw_data).to eq(record)
    end

    it 'computes the versioned droplets' do
      droplet = Monsoon::Droplet.new('analytics', record, {versioning: nil})
      expect(droplet.data).to eq(Monsoon::VersionsSchema.new('analytics').get_droplets(record))
    end

    it 'returns the raw record in an array if no versioned droplets' do
      droplet = Monsoon::Droplet.new('videos', record, {versioning: nil})
      expect(droplet.data).to eq([record])
    end

    it 'returns the raw record in an array if versioning is skipped' do
      droplet = Monsoon::Droplet.new('analytics', record, {versioning: :skip})
      expect(droplet.data).to eq([record])
    end

    it 'returns empty array if no versioned droplets and versioning is enforced' do
      droplet = Monsoon::Droplet.new('videos', record, {versioning: :enforce})
      expect(droplet.data).to eq([])
    end
  end

  describe '#stream' do
    it 'writes data to all configured stream adapters' do
      Monsoon::Droplet.new('analytics', record).stream
      expect(stream_adapter1.stream).to eq('analytics')
      expect(stream_adapter1.data).to eq(Monsoon::VersionsSchema.new('analytics').get_droplets(record))
      expect(stream_adapter2.stream).to eq('analytics')
      expect(stream_adapter2.data).to eq(Monsoon::VersionsSchema.new('analytics').get_droplets(record))
    end

    it 'writes data to specified stream adapter' do
      new_stream_adapter = AdapterTest.new
      Monsoon::Droplet.new('analytics', record).stream(new_stream_adapter)
      expect(new_stream_adapter.stream).to eq('analytics')
      expect(new_stream_adapter.data).to eq(Monsoon::VersionsSchema.new('analytics').get_droplets(record))
      expect(stream_adapter1.stream).to be_nil
      expect(stream_adapter1.data).to eq([])
    end

    it 'does nothing if no stream adapters configured' do
      Monsoon.streams = []
      Monsoon::Droplet.new('analytics', record).stream
      expect(stream_adapter1.stream).to be_nil
      expect(stream_adapter1.data).to eq([])
    end
  end

  describe '#blank?' do
    it 'returns true if droplet has no data' do
      droplet = Monsoon::Droplet.new('videos', record, {versioning: :enforce})
      expect(droplet.blank?).to eq(true)
    end

    it 'returns false if droplet has data' do
      droplet = Monsoon::Droplet.new('videos', record, {versioning: nil})
      expect(droplet.blank?).to eq(false)
    end
  end
end

class AdapterTest
  attr_reader :stream
  attr_reader :data

  def initialize
    @data = []
    @stream = nil
  end

  def put_records(stream, records)
    @stream = stream
    @data = records
  end
end
