# frozen_string_literal: true

require "faraday"
require "json"

module MOCO
  # Handles HTTP communication with the MOCO API
  # Responsible for building API requests and converting responses to entity objects
  class Connection
    attr_reader :client, :subdomain, :api_key, :debug

    def initialize(client, subdomain, api_key, debug: false)
      @client = client
      @subdomain = subdomain
      @api_key = api_key
      @debug = debug
      @conn = Faraday.new do |f|
        f.request :json
        f.response :json
        f.request :authorization, "Token", "token=#{@api_key}"
        f.url_prefix = "https://#{@subdomain}.mocoapp.com/api/v1"
      end
    end

    # Maximum retries for rate-limited requests
    MAX_RETRIES = 3
    # Base delay between retries (seconds)
    RETRY_DELAY = 1.0

    # Define methods for HTTP verbs (get, post, put, patch, delete)
    # These methods send the request and return the raw parsed JSON response body.
    %w[get post put patch delete].each do |http_method|
      define_method(http_method) do |path, params = {}|
        retries = 0

        loop do
          begin
            # Log URL if debug is enabled
            if @debug
              full_url = @conn.build_url(path, params).to_s
              warn "[DEBUG] Fetching URL: #{http_method.upcase} #{full_url}"
            end
            response = @conn.send(http_method, path, params)

            # Handle rate limiting with automatic retry
            if response.status == 429 && retries < MAX_RETRIES
              retries += 1
              # Get Retry-After header or use exponential backoff
              retry_after = response.headers["Retry-After"]&.to_f || (RETRY_DELAY * (2**retries))
              warn "[RATE LIMITED] Waiting #{retry_after}s before retry #{retries}/#{MAX_RETRIES}..." if @debug
              sleep(retry_after)
              next
            end

            # Raise an error for non-successful responses
            unless response.success?
              # Attempt to parse error details from the body, otherwise use status/reason
              error_details = response.body.is_a?(Hash) ? response.body["message"] : response.body
              raise "MOCO API Error: #{response.status} #{response.reason_phrase}. Details: #{error_details}"
            end

            return response.body
          rescue Faraday::Error => e
            # Wrap Faraday errors
            raise "Faraday Connection Error: #{e.message}"
          end
        end
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
