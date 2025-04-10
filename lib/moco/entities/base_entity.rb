# frozen_string_literal: true

require "active_support/inflector" # Ensure ActiveSupport::Inflector is available

module MOCO
  # Base class for all MOCO API entities
  class BaseEntity
    attr_reader :client, :attributes

    # Initializes an entity instance from raw API response data (Hash).
    # Recursively processes nested hashes and arrays, converting known
    # entity structures into corresponding MOCO::Entity instances.
    def initialize(client, response_data)
      @client = client

      # Ensure response_data is a Hash before proceeding
      unless response_data.is_a?(Hash)
        raise ArgumentError, "BaseEntity must be initialized with a Hash, got: #{response_data.class}"
      end

      # Process the top-level hash: transform keys and process nested values.
      @attributes = response_data.transform_keys(&:to_sym)
                                 .each_with_object({}) do |(k, v), acc|
                                   # Use process_value only for the *values* within the hash
                                   acc[k] = process_value(v, k)
                                 end

      # Define attribute methods based on the processed attributes hash
      define_attribute_methods
    end

    # Returns the entity's ID.
    def id
      attributes[:id] || attributes["id"]
    end

    # Compares two entities based on class and ID.
    def ==(other)
      self.class == other.class && !id.nil? && id == other.id
    end

    # Converts the entity to a Hash, recursively converting nested entities.
    def to_h
      attributes.transform_values do |value|
        case value
        when BaseEntity then value.to_h
        when Array then value.map { |item| item.is_a?(BaseEntity) ? item.to_h : item }
        else value
        end
      end
    end

    # Converts the entity to a JSON string.
    def to_json(*options)
      to_h.to_json(*options)
    end

    # Provides a string representation of the entity.
    def inspect
      "#<#{self.class.name}:#{object_id} @attributes=#{@attributes.inspect}>"
    end

    private

    # Helper method to fetch associated objects based on data in attributes.
    # Uses memoization to avoid repeated API calls.
    # association_name: Symbol representing the association (e.g., :project, :customer).
    # target_class_name_override: String specifying the target class if it differs
    #                             from the classified association name (e.g., "Company" for :customer).
    def association(association_name, target_class_name_override = nil)
      # Initialize cache if it doesn't exist
      @_association_cache ||= {}
      # Return cached object if available
      return @_association_cache[association_name] if @_association_cache.key?(association_name)

      association_data = attributes[association_name]

      # If data is already a BaseEntity object (processed during initialization), use it directly.
      return @_association_cache[association_name] = association_data if association_data.is_a?(MOCO::BaseEntity)

      # If data is a hash containing an ID, fetch the object.
      if association_data.is_a?(Hash) && association_data[:id]
        assoc_id = association_data[:id]
        target_class_name = target_class_name_override || ActiveSupport::Inflector.classify(association_name.to_s)
        collection_name = ActiveSupport::Inflector.tableize(target_class_name).to_sym # e.g., "Project" -> :projects

        # Check if the client responds to the collection method (e.g., client.projects)
        if client.respond_to?(collection_name)
          # Fetch the object using the appropriate collection proxy
          fetched_object = client.send(collection_name).find(assoc_id)
          return @_association_cache[association_name] = fetched_object
        else
          warn "Warning: Client does not respond to collection '#{collection_name}' for association '#{association_name}'."
          return @_association_cache[association_name] = nil
        end
      end

      # If data is not an object or a hash with an ID, return nil.
      @_association_cache[association_name] = nil
    end

    # Defines getter and setter methods for each key in the @attributes hash.
    def define_attribute_methods
      attributes.each_key do |key|
        # Skip if the key is nil or a method with this name already exists.
        next if key.nil? || respond_to?(key)

        define_singleton_method(key) { attributes[key] }
        define_singleton_method("#{key}=") { |v| attributes[key] = process_value(v, key) } # Process assigned value too
      end
    end

    # Recursively processes a value from the API response.
    # - Hashes representing known entities are converted to Entity instances.
    # - Other Hashes have their values processed recursively.
    # - Arrays have their items processed recursively.
    # - Primitives are returned as is.
    # key_hint: The key under which this value was found in its parent Hash.
    def process_value(value, key_hint = nil)
      case value
      when Hash
        # Check if this hash represents a known MOCO entity class
        klass = entity_class_for(value, key_hint)
        if klass
          # If yes, create an instance of that class (recursive initialize)
          klass.new(client, value)
        else
          # If no, treat as a generic hash: process its values recursively
          value.transform_keys(&:to_sym)
               .each_with_object({}) do |(k, v), acc|
                 # Pass the key 'k' as a hint for nested processing
                 acc[k] = process_value(v, k)
               end
        end
      when Array
        # Recursively process each item in the array.
        # Pass a singularized key_hint if available (e.g., :tasks -> :task)
        singular_hint = key_hint ? ActiveSupport::Inflector.singularize(key_hint.to_s).to_sym : nil
        value.map { |item| process_value(item, singular_hint) }
      else
        # Return primitive values (String, Integer, Boolean, nil, etc.) as is
        value
      end
    end

    # Determines the specific MOCO::Entity class for a given hash, if possible.
    # Returns the class constant or nil if no specific entity type is identified.
    # data: The hash to analyze.
    # key_hint: The key under which this hash was found in its parent.
    def entity_class_for(data, key_hint = nil)
      # data is always a Hash when called from process_value
      type_name = data[:type] || data["type"]

      # Infer type from the key_hint if :type attribute is missing
      # Example: If key_hint is :customer, infer type "company" or "customer"
      # Example: If key_hint is :tasks, infer type "task" (singular)
      type_name = ActiveSupport::Inflector.singularize(key_hint.to_s) if type_name.nil? && key_hint

      # If no type name could be determined, it's not a known entity structure
      return nil unless type_name

      # Convert type name (e.g., "project", "user", "company") to class name
      class_name = ActiveSupport::Inflector.classify(type_name)

      # Check if the class exists within the MOCO module and is a BaseEntity subclass
      if MOCO.const_defined?(class_name, false)
        klass = MOCO.const_get(class_name)
        return klass if klass.is_a?(Class) && klass <= MOCO::BaseEntity
      end

      # Fallback: No matching entity class found
      nil
    end
  end
end
