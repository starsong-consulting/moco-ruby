# frozen_string_literal: true

require "faraday"
require "json"

module MOCO
  # Represents a MOCO API session for authentication.
  #
  # The `/session` endpoint exchanges email/password credentials for an
  # API key, and can verify an existing key.
  #
  # == Creating an API key (POST /session):
  #   result = MOCO::Session.create(
  #     subdomain: "your-account",
  #     email: "you@example.com",
  #     password: "secret"
  #   )
  #   result["api_key"] # => "6f95f9a0..."
  #   result["user_id"] # => 933590696
  #
  # == Verifying an existing key (GET /session):
  #   identity = moco.session.verify
  #   identity["id"]   # => 933590696
  #   identity["uuid"] # => "7a60719d-..."
  #
  # == Note:
  #   `create` does not require an existing Client - it uses a temporary
  #   unauthenticated connection. `verify` uses the Client's configured
  #   API key.
  #
  class Session
    class << self
      # Exchange email/password for an API key. Does not require a Client.
      # Returns a Hash: { "api_key" => "...", "user_id" => ... }
      def create(subdomain:, email:, password:)
        conn = Faraday.new(url: "https://#{subdomain}.mocoapp.com/api/v1") do |f|
          f.request :json
          f.response :json
        end
        response = conn.post("session", { email:, password: })
        raise MOCO::Error, "Authentication failed: #{response.status}" unless response.success?

        response.body
      end
    end

    attr_reader :client

    def initialize(client)
      @client = client
    end

    # Verify the configured API key. Returns the identity Hash or raises on 401.
    def verify
      client.get("session")
    end
  end
end
