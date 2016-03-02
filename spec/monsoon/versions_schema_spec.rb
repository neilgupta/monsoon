require 'spec_helper'

describe Monsoon::VersionsSchema do
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

  before { Monsoon.versions_schema = schema }

  describe 'new' do
    it 'saves the passed stream' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      expect(vs.stream).to eq('analytics')
      expect(vs.event).to eq('play')
    end
  end

  describe '#get_droplets' do
    it 'parses the schema to create versioned droplets' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        'event' => 'play',
        'user_id' => 1,
        'timestamp' => 360,
        'resource_id' => '23'
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'user_id' => 1,
          'timestamp' => 360,
          'droplet_version' => '1.1',
          'droplet_deprecated' => true,
          'event' => 'play'
        }, {
          'resource_id' => '23',
          'timestamp' => 360,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        },
      ])
    end

    it 'ignores incomplete versions when parsing' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        'event' => 'play',
        'resource_id' => '23',
        'timestamp' => 120
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => '23',
          'timestamp' => 120,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        }
      ])
    end

    it 'includes event if it was not in original message' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        'resource_id' => '23',
        'timestamp' => 120
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => '23',
          'timestamp' => 120,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        }
      ])
    end

    it 'does not version if stream is not provided' do
      vs = Monsoon::VersionsSchema.new(nil, 'play')
      record = {
        'resource_id' => '23',
        'timestamp' => 120,
        'event' => 'play'
      }
      expect(vs.get_droplets(record)).to eq([])
    end

    it 'does not version if event is not provided' do
      vs = Monsoon::VersionsSchema.new('analytics', nil)
      record = {
        'resource_id' => '23',
        'timestamp' => 120,
        'event' => 'play'
      }
      expect(vs.get_droplets(record)).to eq([])
    end

    it 'includes attributes that are defined but nil' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        'event' => 'play',
        'resource_id' => nil,
        'timestamp' => 120
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => nil,
          'timestamp' => 120,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        }
      ])
    end

    it 'ignores attributes not defined in schema' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        'event' => 'play',
        'resource_id' => '23',
        'timestamp' => 120,
        'something_else' => true
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => '23',
          'timestamp' => 120,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        }
      ])
    end

    it 'returns an empty array if no stream schema found' do
      vs = Monsoon::VersionsSchema.new('videos', 'play')
      record = {
        'event_type' => 'play',
        'resource_id' => '23',
        'something_else' => true
      }
      expect(vs.get_droplets(record)).to eq([])
    end

    it 'returns an empty array if no event schema found' do
      vs = Monsoon::VersionsSchema.new('analytics', 'pause')
      record = {
        'event_type' => 'play',
        'resource_id' => '23',
        'something_else' => true
      }
      expect(vs.get_droplets(record)).to eq([])
    end

    it 'works even if symbols are used for keys' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      record = {
        event: 'play',
        resource_id: nil,
        timestamp: 120
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => nil,
          'timestamp' => 120,
          'droplet_version' => '2.0',
          'droplet_deprecated' => false,
          'event' => 'play'
        }
      ])
    end
  end

  describe '#deprecated?' do
    it 'returns true if there is a newer version in schema' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      expect(vs.deprecated?('1.1.0')).to eq(true)
    end

    it 'returns false if this is the latest version in schema' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      expect(vs.deprecated?('2.0.0')).to eq(false)
    end

    it 'returns nil if there is no schema' do
      vs = Monsoon::VersionsSchema.new('videos', 'play')
      expect(vs.deprecated?('2.0.0')).to eq(nil)
    end
  end

  describe '#versions' do
    it 'returns array of all defined versions in schema' do
      vs = Monsoon::VersionsSchema.new('analytics', 'play')
      expect(vs.versions).to match_array(['1.1', '2.0'])
    end

    it 'returns an empty array if no schema defined' do
      vs = Monsoon::VersionsSchema.new('videos', 'play')
      expect(vs.versions).to eq([])
    end
  end
end
