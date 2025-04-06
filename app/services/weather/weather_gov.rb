module Weather
  class WeatherGov < Weather::Base
    include HTTParty
    base_uri "https://api.weather.gov"

    def call(latitude:, longitude:)
      # Get the results from the initial query which contains a list of URLs to get the actual forecast data
      api_data = get_initial_api_data(latitude, longitude)
      return failure(error: "Error getting weather data: Invalid request") if api_data.nil?

      # Get the station id from the URL listed in the API data
      station_id = get_station_id(api_data)

      # Get the latest observation data for the station
      observation_response = self.class.get("/stations/#{station_id}/observations/latest")

      # Return either a Success object with the temperature and wind speed or a Failure object with an error message
      if observation_response.code == 200
        data = JSON.parse(observation_response.body, symbolize_names: true)

        temperature = data[:properties][:temperature][:value]
        wind_speed = data[:properties][:windSpeed][:value]

        success(temperature: celsius_to_fahrenheit(temperature), wind_speed: kmh_to_mph(wind_speed))
      else
        failure(error: "Error getting weather data: #{observation_response.code}")
      end
    rescue HTTParty::Error => e
      failure(error: "Failed to get weather data: #{response.code}")
    rescue StandardError => e
      failure(error: e.message)
    end

    def get_initial_api_data(latitude, longitude)
      # Use HTTParty to make the GET request to the Weather.gov API
      # https://www.weather.gov/documentation/services-web-api
      response = self.class.get("/points/#{latitude},#{longitude}")

      # Check if the response is successful
      return nil if response.code != 200

      # Parse the JSON response and return it
      JSON.parse(response.body, symbolize_names: true)
    end

    def get_station_id(index_api_data)
      # Grab the stations URL from the API data and get a list of observation stations
      stations_url = index_api_data[:properties][:observationStations]
      stations_response = HTTParty.get(stations_url)

      # Grab the station ID from the first station in the list
      station_data = JSON.parse(stations_response.body, symbolize_names: true)
      station_data[:features][0][:properties][:stationIdentifier]
    end
  end
end
