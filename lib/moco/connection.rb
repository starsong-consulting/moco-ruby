# frozen_string_literal: true

require "faraday"
require "json"

module MOCO
  # Handles HTTP communication with the MOCO API
  # Responsible for building API requests and converting responses to entity objects
  class Connection
    attr_reader :client, :subdomain, :api_key

    def initialize(client, subdomain, api_key)
      @client = client
      @subdomain = subdomain
      @api_key = api_key
      @conn = Faraday.new do |f|
        f.request :json
        f.response :json
        f.request :authorization, "Token", "token=#{@api_key}"
        f.url_prefix = "https://#{@subdomain}.mocoapp.com/api/v1"
      end
    end

    # Define methods for HTTP verbs (get, post, put, patch, delete)
    # These methods send the request and return the raw parsed JSON response body.
    %w[get post put patch delete].each do |http_method|
      define_method(http_method) do |path, params = {}|
        response = @conn.send(http_method, path, params)

        # Raise an error for non-successful responses
        unless response.success?
          # Attempt to parse error details from the body, otherwise use status/reason
          error_details = response.body.is_a?(Hash) ? response.body["message"] : response.body
          # Explicitly pass nil for original_error, and response for the third argument
          # raise MOCO::Error.new("MOCO API Error: #{response.status} #{response.reason_phrase}. Details: #{error_details}",
          #                       nil, response)
          # Use RuntimeError for now
          raise "MOCO API Error: #{response.status} #{response.reason_phrase}. Details: #{error_details}"
        end

        response.body
      rescue Faraday::Error => e
        # Wrap Faraday errors - pass e as the second argument (original_error)
        # raise MOCO::Error.new("Faraday Connection Error: #{e.message}", e)
        # Use RuntimeError for now
        raise "Faraday Connection Error: #{e.message}"
      end
    end

    # Define a custom error class for MOCO API errors
    # Temporarily commented out
    # class Error < StandardError
    #   attr_reader :original_error, :response
    #
    #   def initialize(message, original_error = nil, response = nil)
    #     super(message)
    #     @original_error = original_error
    #     @response = response
    #   end
    # end
  end
end
