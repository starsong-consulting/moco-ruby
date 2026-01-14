# frozen_string_literal: true

module MOCO
  # Main client class for interacting with the MOCO API
  # Provides dynamic access to all API endpoints through method_missing
  class Client
    attr_reader :connection

    def initialize(subdomain:, api_key:, debug: false)
      @connection = Connection.new(self, subdomain, api_key, debug: debug)
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

    # Get the current user's profile (singleton resource)
    def profile
      Profile.new(self, get("profile"))
    end

    # Reports namespace for read-only report endpoints
    def reports
      @reports ||= ReportsProxy.new(self)
    end

    # Delegate HTTP methods to connection
    %i[get post put patch delete].each do |method|
      define_method(method) do |path, params = {}|
        connection.send(method, path, params)
      end
    end
  end

  # Proxy for accessing report endpoints
  class ReportsProxy
    def initialize(client)
      @client = client
    end

    # Get absences report
    # @param year [Integer] optional year filter
    # @param active [Boolean] optional active status filter
    def absences(year: nil, active: nil)
      params = {}
      params[:year] = year if year
      params[:active] = active unless active.nil?
      @client.get("report/absences", params)
    end

    # Get cashflow report
    # @param from [String] start date (YYYY-MM-DD)
    # @param to [String] end date (YYYY-MM-DD)
    # @param term [String] optional search term
    def cashflow(from: nil, to: nil, term: nil)
      params = {}
      params[:from] = from if from
      params[:to] = to if to
      params[:term] = term if term
      @client.get("report/cashflow", params)
    end

    # Get finance report
    # @param from [String] start date (YYYY-MM-DD)
    # @param to [String] end date (YYYY-MM-DD)
    # @param term [String] optional search term
    def finance(from: nil, to: nil, term: nil)
      params = {}
      params[:from] = from if from
      params[:to] = to if to
      params[:term] = term if term
      @client.get("report/finance", params)
    end

    # Get utilization report
    # @param from [String] start date (YYYY-MM-DD) - required
    # @param to [String] end date (YYYY-MM-DD) - required
    def utilization(from:, to:)
      @client.get("report/utilization", { from:, to: })
    end
  end
end
