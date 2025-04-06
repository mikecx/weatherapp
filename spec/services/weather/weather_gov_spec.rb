require "rails_helper"

describe Weather::WeatherGov do
  describe '#call' do
    subject(:call) { described_class.call(latitude:, longitude:) }

    let(:latitude) { 34.0522 }
    let(:longitude) { -118.2437 }

    before do
      # Mocking the external service to avoid network calls.
      allow(described_class).to receive(:get).and_return(
        instance_double(HTTParty::Response, code: 200, body: {
          properties: {
            temperature: { value: 14 },
            windSpeed: { value: 5 }
          }
        }.to_json)
      )

      # Mocking the initial API data to return a valid response and station ID to return a valid station ID
      allow_any_instance_of(described_class).to receive(:get_initial_api_data).and_return(
        {
          properties: {
            observationStations: 'https://api.weather.gov/stations'
          }
        }
      )

      allow_any_instance_of(described_class).to receive(:get_station_id).and_return('station_id')
    end

    it 'returns a success response with weather data', :aggregate_failures do
      result = call

      expect(result).to be_a(Weather::Success)
      expect(result.temperature).to eq(57.2) # 14 Celsius to Fahrenheit
      expect(result.wind_speed).to eq(3.106855) # 5 km/h to mph
    end

    context 'when the API returns an error' do
      describe "when the initial API data is invalid" do
        before do
          allow_any_instance_of(described_class).to receive(:get_initial_api_data).and_return(nil)
        end

        it 'returns a failure response', :aggregate_failures do
          result = call

          expect(result).to be_a(Weather::Failure)
          expect(result.error).to eq('Error getting weather data: Invalid request')
        end
      end

      describe 'when the observation response is not successful' do
        before do
          allow(described_class).to receive(:get).and_return(
            instance_double(HTTParty::Response, code: 422, body: {})
          )

          # Mocking the initial API data to return a valid response and station ID to return a valid station ID
          allow_any_instance_of(described_class).to receive(:get_initial_api_data).and_return(
            {
              properties: {
                observationStations: 'https://api.weather.gov/stations'
              }
            }
          )

          allow_any_instance_of(described_class).to receive(:get_station_id).and_return('station_id')
        end

        it 'returns a failure response', :aggregate_failures do
          result = call

          expect(result).to be_a(Weather::Failure)
          expect(result.error).to eq('Error getting weather data: 422')
        end
      end
    end
  end

  describe '#get_initial_api_data' do
    subject(:get_initial_api_data) { described_class.new.get_initial_api_data(latitude, longitude) }

    let(:latitude) { 34.0522 }
    let(:longitude) { -118.2437 }

    before do
      allow(described_class).to receive(:get).and_return(
        instance_double(HTTParty::Response, code: 200, body: {
          properties: {
            observationStations: 'https://api.weather.gov/stations'
          }
        }.to_json)
      )
    end

    it 'returns the API data' do
      result = get_initial_api_data

      expect(result).to be_a(Hash)
      expect(result[:properties][:observationStations]).to eq('https://api.weather.gov/stations')
    end
  end

  describe '#get_station_id' do
    subject(:get_station_id) { described_class.new.get_station_id(api_data) }

    let(:api_data) do
      {
        properties: {
          observationStations: 'https://api.weather.gov/stations'
        }
      }
    end

    before do
      allow(HTTParty).to receive(:get).and_return(
        instance_double(HTTParty::Response, code: 200, body: {
          features: [
            {
              properties: {
                stationIdentifier: 'station_id'
              }
            }
          ]
        }.to_json)
      )
    end

    it 'returns the station ID' do
      result = get_station_id

      expect(result).to eq('station_id')
    end
  end
end
