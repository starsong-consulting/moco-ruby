# frozen_string_literal: true

require_relative "collection_proxy"

module MOCO
  # Provides high-level collection operations for MOCO entities
  class EntityCollection
    include Enumerable
    attr_reader :client, :path, :entity_class_name

    def initialize(client, path, entity_class_name)
      @client = client
      @path = path
      @entity_class_name = entity_class_name
    end

    def all
      collection.all
    end

    def find(id)
      collection.find(id)
    end

    def where(filters = {})
      collection.where(filters)
    end

    def create(attributes)
      collection.create(attributes)
    end

    def each(&)
      collection.each(&)
    end

    def first
      all.first
    end

    def count
      all.count
    end

    def update(id, attributes)
      collection.update(id, attributes)
    end

    def delete(id)
      collection.delete(id)
    end

    private

    def collection
      @collection ||= CollectionProxy.new(client, path, entity_class_name)
    end
  end
end
