# Weather App

## Ruby & Rails Versions
This project is built using Ruby 3.2.2 and Rails 8.0.2

## Description
A simple weather application that provides current weather information for a given location. The app uses the Google Geocoding 
API to convert addresses into geographic coordinates (latitude and longitude) and the National Weather Service API to fetch 
weather data based on those coordinates.

Both the latitude/longitude lookup and the weather lookup are cached for 30 minutes to reduce the number of API calls and 
improve performance.

The project uses tailwindcss for the small amount of styling. 

## Design Patterns
The application makes heavy use of the Service Object design pattern to encapsulate the logic for interacting with external APIs.
This keeps the controllers skinny, makes testing easier, and allows for better separation of concerns. In a larger application 
I would pull in something like dry.rb and use Success and Failure monads to handle the success and failure cases of the API calls.

For something like this, I opted to use simple Data classes to make sure that the return types are consistent and easy to work with.

## Requirements
Outside the standard Ruby and Rails requirements, the only other requirement should be a valid Google Geocoder API key. You can get one
[here](https://developers.google.com/maps/documentation/geocoding/get-api-key).

There should already be one in the credential store, but if you want to use your own, it should be under:
```yaml
google:
    geocode_api_key: <YOUR_API_KEY>
```

```bash
  bin/rails credentials:edit
```

## Getting Started
To get started with the Weather App, follow these steps:

1. Clone the repo
2. Install the required gems by running `bundle install`
3. Run the development server with `bin/dev`

## Testing
To run the test suite, use the following command:

```bash
  bundle exec rspec
```

For the test suite, I used RSpec as I find RSpec to be more expressive and easier to read. In places where an external API 
is called, I chose to mock the API calls instead of using VCR or WebMock. In an expanded example, I would use VCR to record the API
calls and use that in the test suite to catch errors around API changes.
