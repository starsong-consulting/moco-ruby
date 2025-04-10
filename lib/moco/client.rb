# frozen_string_literal: true

module MOCO
  # Main client class for interacting with the MOCO API
  # Provides dynamic access to all API endpoints through method_missing
  class Client
    attr_reader :connection

    def initialize(subdomain:, api_key:)
      @connection = Connection.new(self, subdomain, api_key)
      @collections = {}
    end

    # Dynamically handle entity collection access (e.g., client.projects)
    def method_missing(name, *args, &)
      # Check if the method name corresponds to a known plural entity type
      if collection_name?(name)
        # Return a CollectionProxy directly for chainable queries
        # Cache it so subsequent calls return the same proxy instance
        @collections[name] ||= CollectionProxy.new(
          self,
          name.to_s, # Pass the plural name (e.g., "projects") as the path hint
          ActiveSupport::Inflector.classify(name.to_s) # Get class name (e.g., "Project")
        )
      else
        # Delegate to superclass for non-collection methods
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      collection_name?(name) || super
    end

    # Check if the method name looks like a collection name (plural)
    def collection_name?(name)
      name.to_s == ActiveSupport::Inflector.pluralize(name.to_s)
    end

    # Delegate HTTP methods to connection
    %i[get post put patch delete].each do |method|
      define_method(method) do |path, params = {}|
        connection.send(method, path, params)
      end
    end
  end
end
