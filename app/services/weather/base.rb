module Weather
  # Define the Success and Failure classes using Data to keep the shape of the response consistent
  Success = Data.define(:temperature, :wind_speed)
  Failure = Data.define(:error)

  class Base
    # The weather API I picked is the National Weather Service API that uses latitude and longitude. If another API is used
    # that takes different parameters, this is where it would get updated. The .call method just makes it easier to call the service
    # from outside the class.
    def self.call(latitude:, longitude:)
      new.call(latitude:, longitude:)
    end

    def call(latitude:, longitude:)
      raise NotImplementedError, "Subclasses must implement a call method"
    end

    # The next two methods are just helper methods to create success and failure Data objects
    def success(temperature:, wind_speed:)
      Success.new(temperature, wind_speed)
    end

    def failure(error:)
      Failure.new(error)
    end

    protected

    # Including the conversion methods here as it's likely that other APIs might return data in Celsius or km/h
    def celsius_to_fahrenheit(celsius)
      (celsius * 9.0 / 5.0) + 32
    end

    def kmh_to_mph(kmh)
      kmh * 0.621371
    end
  end
end
