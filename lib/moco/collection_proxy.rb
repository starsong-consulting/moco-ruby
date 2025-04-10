# frozen_string_literal: true

module MOCO
  # Provides ActiveRecord-style query interface for MOCO entities
  class CollectionProxy
    include Enumerable
    attr_reader :client, :entity_class_name, :filters, :limit_value

    def initialize(client, path_or_entity_name, entity_class_name)
      @client = client
      @entity_class_name = entity_class_name
      @entity_class = load_entity_class # Load and store the class
      @base_path = determine_base_path(path_or_entity_name)
      @filters = {} # Store query filters
      @limit_value = nil # Store limit for methods like first/find_by
      @loaded = false # Flag to track if data has been fetched
      @records = [] # Cache for fetched records
    end

    def load_entity_class
      # Ensure ActiveSupport::Inflector is available if not already loaded globally
      require "active_support/inflector" unless defined?(ActiveSupport::Inflector)

      entity_file_name = ActiveSupport::Inflector.underscore(entity_class_name)
      entity_file_path = "entities/#{entity_file_name}" # Path relative to lib/moco/
      begin
        # Use require_relative from the current file's directory
        require_relative entity_file_path
        MOCO.const_get(entity_class_name)
      rescue LoadError
        warn "Warning: Could not load entity file at #{entity_file_path}. Using BaseEntity."
        MOCO::BaseEntity # Fallback
      rescue NameError
        warn "Warning: Could not find entity class #{entity_class_name}. Using BaseEntity."
        MOCO::BaseEntity # Fallback
      end
    end

    # Removed method_missing and respond_to_missing? as they are not
    # currently used for building nested paths in this implementation.

    # --- Chainable Methods ---

    # Adds filters to the query. Returns self for chaining.
    def where(conditions = {})
      # TODO: Implement proper merging/handling of existing filters if called multiple times
      @filters.merge!(conditions)
      self # Return self to allow chaining like client.projects.where(active: true).where(...)
    end

    # Sets a limit on the number of records to fetch. Returns self.
    def limit(value)
      @limit_value = value
      self
    end

    # --- Methods Triggering API Call ---

    # Fetches all records matching the current filters.
    # Caches the result.
    def all
      load_records unless loaded?
      @records
    end

    # Fetches a specific record by ID. Does not use current filters or limit.
    def find(id)
      # Ensure entity_class is loaded and valid before calling new
      klass = entity_class
      return nil unless klass && klass <= MOCO::BaseEntity

      # Directly fetch by ID, bypassing stored filters/limit
      response = client.get("#{@base_path}/#{id}")
      # wrap_response now returns an array even for single results
      result_array = wrap_response(response)
      # Return the single entity or nil if not found (or if response was not a hash)
      result_array.first
    end

    # NOTE: The duplicated 'where' method definition below is removed.
    # The correct 'where' method is defined earlier in the class.

    # Fetches the first record matching the current filters.
    def first
      limit(1).load_records unless loaded? && @limit_value == 1
      @records.first
    end

    # Finds the first record matching the given attributes.
    def find_by(conditions)
      where(conditions).first
    end

    # Executes the query and yields each record.
    def each(&)
      load_records unless loaded?
      @records.each(&)
    end

    # --- Persistence Methods (Pass-through) ---
    # These don't typically belong on the relation/proxy but are kept for now.
    # Consider moving them or ensuring they operate correctly in this context.

    def create(attributes)
      klass = entity_class
      return nil unless klass && klass <= MOCO::BaseEntity

      klass.new(client, client.post(@base_path, attributes))
    end

    def update(id, attributes)
      klass = entity_class
      return nil unless klass && klass <= MOCO::BaseEntity

      klass.new(client, client.put("#{@base_path}/#{id}", attributes))
    end

    def delete(id)
      client.delete("#{@base_path}/#{id}")
    end

    # --- Internal Methods ---

    # Executes the API request based on current filters and limit.
    # Populates @records and sets @loaded flag.
    # Needs to be public for methods like first, each, find_by to call it.
    def load_records
      query_params = @filters.dup
      query_params[:limit] = @limit_value if @limit_value
      # MOCO API might use 'per_page' instead of 'limit' for pagination control
      # Adjust if necessary based on API docs. Assuming 'limit' works for now.

      response = client.get(@base_path, query_params)
      @records = wrap_response(response) # wrap_response should return an Array here
      @loaded = true
      @records # Return the loaded records
    end

    private

    # Returns the loaded entity class constant.
    attr_reader :entity_class

    # Flag indicating if records have been loaded from the API.
    def loaded?
      @loaded
    end

    # Determines the base API path for the entity.
    # Uses entity_path method if defined, otherwise uses the pluralized name.
    def determine_base_path(path_or_entity_name)
      klass = entity_class
      # Check if the class itself responds to entity_path (class method)
      return klass.entity_path if klass.respond_to?(:entity_path)

      # Check if instances respond to entity_path (instance method)
      # Need a dummy instance if the class is valid
      if klass && klass <= MOCO::BaseEntity && klass.instance_methods.include?(:entity_path)
        # We can't reliably call instance methods here without data.
        # This indicates entity_path should likely be a class method.
        # Falling back to default path generation.
        warn "Warning: entity_path is defined as an instance method on #{klass.name}. It should ideally be a class method. Falling back to default path."
      end

      # Fallback: Use the pluralized/tableized version of the entity name or the provided path.
      ActiveSupport::Inflector.tableize(path_or_entity_name.to_s)
    end

    # Wraps the raw API response (Hash or Array of Hashes) into entity objects.
    def wrap_response(response_body)
      klass = entity_class
      # Ensure we have a valid class derived from BaseEntity
      return [] unless klass && klass <= MOCO::BaseEntity # Return empty array if class invalid

      if response_body.is_a?(Array)
        # Convert array of hashes to array of entity objects
        response_body.map { |item_hash| klass.new(client, item_hash) if item_hash.is_a?(Hash) }.compact
      elsif response_body.is_a?(Hash)
        # Wrap single hash response in an array for consistency internally
        [klass.new(client, response_body)]
      else
        # Handle unexpected response types (like the String error we saw)
        warn "Warning: Unexpected API response type received in wrap_response: #{response_body.class}. Expected Hash or Array."
        response_body # Return the unexpected body as is
      end
    end
  end
end
