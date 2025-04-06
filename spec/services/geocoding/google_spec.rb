require 'rails_helper'

describe Geocoding::Google do
  describe '#call' do
    subject(:call) { described_class.call(address:) }

    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:latitude) { 37.4221 }
    let(:longitude) { -122.0841 }

    before do
      # Mocking the external service to avoid network calls. I'd prefer to use WebMock or VCR in a real-world scenario
      # but for simplicity, I'm using RSpec's built-in mocking.
      allow(Geocoding::Google).to receive(:get).and_return(
        instance_double(HTTParty::Response, code: 200, body: {
          results: [ {
            geometry: {
              location: {
                lat: latitude,
                lng: longitude
              }
            }
          } ]
        }.to_json
      ))
    end

    it 'returns a success result with latitude and longitude' do
      result = call

      expect(result).to be_a(Geocoding::Success)
      expect(result.latitude).to eq(latitude)
      expect(result.longitude).to eq(longitude)
    end

    it 'calls the Google API with the correct address' do
      call

      expect(Geocoding::Google).to have_received(:get).with('/geocode/json', query: { address: address.strip, key: anything })
    end

    context 'when there is an error' do
      before do
        # Mocking the external service to avoid network calls. I'd prefer to use WebMock or VCR in a real-world scenario
        # but for simplicity, I'm using RSpec's built-in mocking.
        allow(Geocoding::Google).to receive(:get).and_return(
          instance_double(HTTParty::Response, code: 422, body: {}))
      end

      it 'returns a failure result with an error message' do
        result = call

        expect(result).to be_a(Geocoding::Failure)
        expect(result.error).to eq('Error getting geocoding data: 422')
      end
    end
  end
end
