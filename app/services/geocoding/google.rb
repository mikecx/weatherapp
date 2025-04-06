module Geocoding
  class Google < Geocoding::Base
    include HTTParty
    base_uri "https://maps.googleapis.com/maps/api"

    def call(address:)
      # Grab the API key from Rails credentials
      google_api_key = Rails.application.credentials.dig(:google, :geocode_api_key)

      # Use HTTParty to make the GET request to the Google Geocoding API, JSON format
      # https://developers.google.com/maps/documentation/geocoding/requests-geocoding
      response = self.class.get("/geocode/json", query: { address: address.strip, key: google_api_key })

      # Return either a Success object with latitude and longitude or a Failure object with an error message
      if response.code == 200
        data = JSON.parse(response.body, symbolize_names: true)
        latitude = data[:results][0][:geometry][:location][:lat]
        longitude = data[:results][0][:geometry][:location][:lng]

        success(latitude: latitude, longitude: longitude)
      else
        failure(error: "Error getting geocoding data: #{response.code}")
      end
    rescue HTTParty::Error => e
      failure(error: "Failed to get geocoding data: #{e.message}")
    rescue StandardError => e
      failure(error: e.message)
    end
  end
end
