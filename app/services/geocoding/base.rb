module Geocoding
  # Define the Success and Failure classes using Data to keep the shape of the response consistent
  Success = Data.define(:latitude, :longitude)
  Failure = Data.define(:error)

  class Base
    # The geocoding API should be used to take an address and return latitude and longitude. If another API is used that
    # takes different parameters, this is where it would get updated. The .call method just makes it easier to call the service
    def self.call(address:)
      new.call(address:)
    end

    def call(address:)
      raise NotImplementedError, "Subclasses must implement a call method"
    end

    # The next two methods are just helper methods to create success and failure Data objects
    def success(latitude:, longitude:)
      Success.new(latitude, longitude)
    end

    def failure(error:)
      Failure.new(error)
    end
  end
end
