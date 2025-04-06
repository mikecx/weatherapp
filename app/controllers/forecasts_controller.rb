class ForecastsController < ApplicationController
  def index
  end

  def forecast
    params.expect([ :postal_code, :street_address, :city, :state ])

    street_address = params[:street_address]
    city = params[:city]
    state = params[:state]
    postal_code = params[:postal_code]

    # Build an array of the address params so it can be easily formatted in both a machine-readable format and a
    # human-readable format
    address_array = [ street_address, city, state, postal_code ]
    api_address = address_array.join(",").strip

    # Since there's no object needed to hold the forecast data, we can use the postal code as a cache key instead of
    # using Model#cache_key
    cache_key = "weather_#{postal_code}"

    # Build up the variables to be used in the rendered view
    @address = address_array.join(", ").strip

    # Check to see if the object is already cached
    @cached = Rails.cache.exist?(cache_key)

    # Use the geocoding service object to get the latitude and longitude of the address, then use the weather service
    # object to get the forecast data. Cache the geocoding and forecast data for 30 minutes.
    @forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      coordinates = ::Geocoding::Google.call(address: api_address)

      # If the geocoding service returns a failure, return the error message
      if coordinates.is_a?(::Geocoding::Failure)
        coordinates.to_h
      else
        ::Weather::WeatherGov.call(latitude: coordinates.latitude, longitude: coordinates.longitude).to_h
      end
    end
  end
end
