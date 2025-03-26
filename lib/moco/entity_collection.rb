# frozen_string_literal: true

module MOCO
  # Provides collection-level operations for entity types
  # Handles querying, creating, updating, and deleting entities
  class EntityCollection
    attr_reader :client, :path, :entity_class_name

    def initialize(client, path, entity_class_name)
      @client = client
      @path = path
      @entity_class_name = entity_class_name
    end

    def all(filters = {})
      client.get(path, filters)
    end

    def find(id)
      client.get("#{path}/#{id}")
    end

    def create(attributes)
      client.post(path, attributes)
    end

    def where(filters = {})
      all(filters)
    end

    def first(filters = {})
      result = where(filters)
      result.is_a?(Array) && !result.empty? ? result.first : nil
    end

    def count(filters = {})
      result = where(filters)
      result.is_a?(Array) ? result.size : 0
    end

    def exists?(id)
      find(id)
      true
    rescue MOCO::Error
      false
    end

    def update(id, attributes)
      client.put("#{path}/#{id}", attributes)
    end

    def delete(id)
      client.delete("#{path}/#{id}")
    end
  end
end
