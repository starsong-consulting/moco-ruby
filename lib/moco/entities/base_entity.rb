# frozen_string_literal: true

module MOCO
  # Base class for all MOCO API entities
  # Provides common functionality for attribute access, persistence, and serialization
  class BaseEntity
    attr_reader :client, :attributes

    def initialize(client, attributes = {})
      @client = client
      @attributes = attributes.transform_keys(&:to_sym)

      # Define attribute accessors dynamically
      attributes.each_key do |key|
        key_sym = key.to_sym
        unless respond_to?(key_sym)
          define_singleton_method(key_sym) { attributes[key_sym] }
          define_singleton_method("#{key}=") { |value| attributes[key_sym] = value }
        end
      end
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
