require 'spec_helper'

describe Monsoon::SemVer do
  describe 'new' do
    it 'parses a semantic version string into its parts' do
      sv = Monsoon::SemVer.new('1.1.0')
      expect(sv.major).to eq(1)
      expect(sv.minor).to eq(1)
      expect(sv.patch).to eq(0)
    end

    it 'parses a semantic version string with additional info' do
      sv = Monsoon::SemVer.new('1.2.3-alpha')
      expect(sv.major).to eq(1)
      expect(sv.minor).to eq(2)
      expect(sv.patch).to eq(3)
    end

    it 'raises an ArgumentError if the string is not a valid semantic version' do
      expect{Monsoon::SemVer.new('0.0.0')}.to raise_error(ArgumentError)
    end

    it 'parses a semantic version symbol' do
      sv = Monsoon::SemVer.new(:"0.3.23")
      expect(sv.major).to eq(0)
      expect(sv.minor).to eq(3)
      expect(sv.patch).to eq(23)
    end
  end

  describe '#<=>' do
    it 'compares 2 SemVers' do
      sv1 = Monsoon::SemVer.new('10.3.0')
      sv2 = Monsoon::SemVer.new('2.0.0')
      expect(sv1 > sv2).to eq(true)
    end

    it 'compares SemVer with version string' do
      sv1 = Monsoon::SemVer.new('10.3.0')
      expect(sv1 > '2.0.0').to eq(true)
    end

    it 'compares SemVer with version symbol' do
      sv1 = Monsoon::SemVer.new('10.3.0')
      expect(sv1 == :"10.3.0").to eq(true)
    end
  end

  describe '#to_s' do
    it 'combines a SemVer back into its version string' do
      sv = Monsoon::SemVer.new('3.4.0')
      expect(sv.to_s).to eq('3.4.0')
    end
  end

  describe 'valid?' do
    it 'returns true if a string is a valid semantic version' do
      expect(Monsoon::SemVer.valid?('3.21.0')).to eq(true)
    end

    it 'returns true if a symbol is a valid semantic version' do
      expect(Monsoon::SemVer.valid?(:"13.0")).to eq(true)
    end

    it 'returns false for a non-string object' do
      expect(Monsoon::SemVer.valid?(true)).to eq(false)
    end

    it 'returns false for a string with an invalid semantic version' do
      expect(Monsoon::SemVer.valid?('-3')).to eq(false)
    end
  end
end
