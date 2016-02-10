require 'spec_helper'

describe Monsoon::VersionsSchema do
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

  before { Monsoon.versions_schema = schema }

  describe 'new' do
    it 'saves the passed stream' do
      vs = Monsoon::VersionsSchema.new('analytics')
      expect(vs.stream).to eq('analytics')
    end
  end

  describe '#get_droplets' do
    it 'parses the schema to create versioned droplets' do
      vs = Monsoon::VersionsSchema.new('analytics')
      record = {
        'user_id' => 1,
        'event_type' => 'play',
        'resource_id' => '23'
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'user_id' => 1,
          'droplet_version' => '1.0.0',
          'droplet_deprecated' => true
        }, {
          'user_id' => 1,
          'event_type' => 'play',
          'droplet_version' => '1.1.0',
          'droplet_deprecated' => true
        }, {
          'resource_id' => '23',
          'event_type' => 'play',
          'droplet_version' => '2.0.0',
          'droplet_deprecated' => false
        },
      ])
    end

    it 'ignores incomplete versions when parsing' do
      vs = Monsoon::VersionsSchema.new('analytics')
      record = {
        'event_type' => 'play',
        'resource_id' => '23'
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => '23',
          'event_type' => 'play',
          'droplet_version' => '2.0.0',
          'droplet_deprecated' => false
        }
      ])
    end

    it 'includes attributes that are defined but nil' do
      vs = Monsoon::VersionsSchema.new('analytics')
      record = {
        'event_type' => 'play',
        'resource_id' => nil
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => nil,
          'event_type' => 'play',
          'droplet_version' => '2.0.0',
          'droplet_deprecated' => false
        }
      ])
    end

    it 'ignores attributes not defined in schema' do
      vs = Monsoon::VersionsSchema.new('analytics')
      record = {
        'event_type' => 'play',
        'resource_id' => '23',
        'something_else' => true
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => '23',
          'event_type' => 'play',
          'droplet_version' => '2.0.0',
          'droplet_deprecated' => false
        }
      ])
    end

    it 'returns an empty array if no schema found' do
      vs = Monsoon::VersionsSchema.new('videos')
      record = {
        'event_type' => 'play',
        'resource_id' => '23',
        'something_else' => true
      }
      expect(vs.get_droplets(record)).to eq([])
    end

    it 'works even if symbols are used for keys' do
      vs = Monsoon::VersionsSchema.new('analytics')
      record = {
        event_type: 'play',
        resource_id: nil
      }
      expect(vs.get_droplets(record)).to match_array([
        {
          'resource_id' => nil,
          'event_type' => 'play',
          'droplet_version' => '2.0.0',
          'droplet_deprecated' => false
        }
      ])
    end
  end

  describe '#deprecated?' do
    it 'returns true if there is a newer version in schema' do
      vs = Monsoon::VersionsSchema.new('analytics')
      expect(vs.deprecated?('1.1.0')).to eq(true)
    end

    it 'returns false if this is the latest version in schema' do
      vs = Monsoon::VersionsSchema.new('analytics')
      expect(vs.deprecated?('2.0.0')).to eq(false)
    end

    it 'returns nil if there is no schema' do
      vs = Monsoon::VersionsSchema.new('videos')
      expect(vs.deprecated?('2.0.0')).to eq(nil)
    end
  end

  describe '#versions' do
    it 'returns array of all defined versions in schema' do
      vs = Monsoon::VersionsSchema.new('analytics')
      expect(vs.versions).to match_array(['1.0.0', '1.1.0', '2.0.0'])
    end

    it 'returns an empty array if no schema defined' do
      vs = Monsoon::VersionsSchema.new('videos')
      expect(vs.versions).to eq([])
    end
  end
end
