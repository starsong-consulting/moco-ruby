# frozen_string_literal: true

module MOCO
  # Base class for all MOCO API entities
  # Provides common functionality for attribute access, persistence, and serialization
  class BaseEntity
    attr_reader :client, :attributes

    def initialize(client, attributes = {})
      @client = client

      # Ensure attributes is a hash
      attributes = {} unless attributes.is_a?(Hash)
      @attributes = attributes.transform_keys(&:to_sym)

      # Define attribute accessors dynamically
      @attributes.each_key do |key_sym|
        next if key_sym.nil?

        # Skip if method already defined
        next if respond_to?(key_sym)

        # Define getter method
        self.class.send(:define_method, key_sym) do
          @attributes[key_sym]
        end

        # Define setter method
        self.class.send(:define_method, "#{key_sym}=") do |value|
          @attributes[key_sym] = value
        end
      end
    end

    # Generic method to handle associations
    # This method can be used by subclasses to handle nested objects
    # Example: association(:project) will look for project_id or project.id
    def association(name, entity_class_name = nil)
      name_sym = name.to_sym
      id_sym = :"#{name}_id"
      ivar_name = "@#{name}"

      # Return cached value if already loaded
      return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)

      # Determine the entity class name if not provided
      entity_class_name ||= name.to_s.classify

      # Try to find the association by ID
      result = if attributes[id_sym]
                 # Get the collection name by pluralizing the entity class name
                 collection_name = ActiveSupport::Inflector.pluralize(
                   ActiveSupport::Inflector.underscore(entity_class_name)
                 )
                 client.send(collection_name).find(attributes[id_sym])
               # Or handle an embedded entity
               elsif attributes[name_sym].is_a?(Hash) && attributes[name_sym][:id]
                 MOCO.const_get(entity_class_name).new(client, attributes[name_sym])
               end

      # Cache the result
      instance_variable_set(ivar_name, result)

      result
    end

    def id
      attributes[:id]
    end

    # Common methods for all entities
    def reload
      response = client.get("#{entity_path}/#{id}")
      @attributes = response.attributes
      self
    end

    def save
      if id
        client.put("#{entity_path}/#{id}", attributes)
      else
        response = client.post(entity_path, attributes)
        @attributes[:id] = response.id
      end
      self
    end

    def to_h
      attributes
    end

    def to_json(*)
      to_h.to_json(*)
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      id == other.id
    end

    def eql?(other)
      self == other
    end

    def hash
      id.hash
    end

    private

    def entity_path
      @entity_path ||= self.class.name.split("::").last
                           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                           .downcase
                           .pluralize
    end
  end
end
