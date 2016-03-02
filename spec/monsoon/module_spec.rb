require 'spec_helper'

describe Monsoon do
  describe 'streams=' do
    it 'saves a new stream' do
      Monsoon.streams = ['hello']
      expect(Monsoon.streams).to eq(['hello'])
    end
  end

  describe 'versions_schema=' do
    it 'saves the new versions schema' do
      Monsoon.versions_schema = {'analtyics' => {'play' => {'1.0' => ['user_id']}}}
      expect(Monsoon.versions_schema).to eq({'analtyics' => {'play' => {'1.0' => ['user_id']}}})
    end
  end

  describe 'default_stream=' do
    it 'saves the default stream' do
      Monsoon.default_stream = 'analtyics'
      expect(Monsoon.default_stream).to eq('analtyics')
    end
  end
end
