require 'rails_helper'

describe "Forecasts", type: :request do
  describe "GET /forecasts" do
    it "returns http success" do
      get "/forecasts"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /forecasts/forecast" do
    def action(params = {})
      get "/forecasts/forecast", params: { postal_code: '90210', street_address: '123 Main St', city: 'Beverly Hills', state: 'CA' }.merge(params)
    end

    let(:latitude) { 34.0522 }
    let(:longitude) { -118.2437 }
    let(:temperature) { 75 }
    let(:wind_speed) { 10 }

    before do
      # Mocking the external services so that this test is not slowed down by network calls.
      allow(Geocoding::Google).to receive(:call).and_return(Geocoding::Success.new(latitude:, longitude:))
      allow(Weather::WeatherGov).to receive(:call).and_return(Weather::Success.new(temperature:, wind_speed:))
    end

    it "returns http success" do
      action

      expect(response).to have_http_status(:success)
    end

    it 'calls the geocoding service' do
      action

      expect(Geocoding::Google).to have_received(:call).with(address: '123 Main St,Beverly Hills,CA,90210')
    end

    it 'calls the weather service' do
      action

      expect(Weather::WeatherGov).to have_received(:call).with(latitude:, longitude:)
    end

    it 'renders the forecast', :aggregate_failures do
      action

      expect(response.body).to include("Temperature: #{temperature}")
      expect(response.body).to include("Wind speed: #{wind_speed}")
    end
  end
end
