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

    %w[get post put patch delete].each do |method|
      define_method(method) do |path, params = {}|
        response = @conn.send(method, path, params)
        build_entity(response.body, path)
      end
    end

    private

    def build_entity(data, path)
      return data.map { |item| build_entity(item, path) } if data.is_a?(Array)

      entity_class = entity_class_for(path)

      if entity_class && MOCO.const_defined?(entity_class)
        MOCO.const_get(entity_class).new(client, data)
      else
        if entity_class
          warn "Entity class #{entity_class} not defined. Using Struct."
        else
          warn "Could not determine entity type for path: #{path}. Using Struct."
        end
        to_struct(data)
      end
    end

    def entity_class_for(path)
      return nil unless path

      # Extract entity type from path (e.g., "projects/123" -> "projects")
      entity_type = path.split("/").first
      return nil unless entity_type

      # Convert to singular form and capitalize (e.g., "projects" -> "Project")
      ActiveSupport::Inflector.classify(entity_type)
    end

    # Convert hash to Struct for unknown entity types
    def to_struct(hash)
      return hash unless hash.is_a?(Hash)

      keys = hash.keys.map(&:to_sym)
      values = hash.values.map do |v|
        if v.is_a?(Hash)
          to_struct(v)
        elsif v.is_a?(Array) && v.any? && v.first.is_a?(Hash)
          v.map { |item| to_struct(item) }
        else
          v
        end
      end

      # Ensure we have at least one key
      return hash if keys.empty?

      Struct.new(*keys).new(*values)
    end
  end
end
