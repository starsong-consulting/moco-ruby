# frozen_string_literal: true

module MOCO
  # Provides ActiveRecord-style query interface for MOCO entities
  class CollectionProxy
    include Enumerable
    attr_reader :client, :entity_class_name

    def initialize(client, path_or_entity_name, entity_class_name)
      @client = client
      @entity_class_name = entity_class_name
      @entity_class = load_entity_class # Load and store the class

      # Determine the base API path
      @base_path = determine_base_path(path_or_entity_name)
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
    # If needed later, they would require careful handling of the base_path.

    def all(params = {})
      wrap_response(client.get(@base_path, params))
    end

    def find(id)
      # Ensure entity_class is loaded and valid before calling new
      klass = entity_class
      return nil unless klass && klass <= MOCO::BaseEntity

      klass.new(client, client.get("#{@base_path}/#{id}"))
    end

    def where(filters = {})
      wrap_response(client.get(@base_path, filters))
    end

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

    def each(&)
      # Ensure all returns an array before calling each
      result = all
      result.is_a?(Array) ? result.each(&) : [result].compact.each(&)
    end

    private

    # Returns the loaded entity class constant.
    attr_reader :entity_class

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
      return response_body unless klass && klass <= MOCO::BaseEntity

      if response_body.is_a?(Array)
        response_body.map { |item_hash| klass.new(client, item_hash) if item_hash.is_a?(Hash) }.compact
      elsif response_body.is_a?(Hash)
        klass.new(client, response_body)
      else
        # Handle unexpected response types (like the String error we saw)
        warn "Warning: Unexpected API response type received in wrap_response: #{response_body.class}. Expected Hash or Array."
        response_body # Return the unexpected body as is
      end
    end
  end
end
