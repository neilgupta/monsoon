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
      Monsoon.versions_schema = {'analtyics' => {'1.0' => ['user_id']}}
      expect(Monsoon.versions_schema).to eq({'analtyics' => {'1.0' => ['user_id']}})
    end
  end
end
