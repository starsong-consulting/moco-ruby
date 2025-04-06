# frozen_string_literal: true

module MOCO
  # Provides ActiveRecord-style query interface for MOCO entities
  class CollectionProxy
    include Enumerable
    attr_reader :client, :path, :entity_class_name

    def initialize(client, path, entity_class_name)
      @client = client
      @path = path
      @entity_class_name = entity_class_name
      load_entity_class
    end

    def load_entity_class
      entity_file = "moco/entities/#{entity_class_name.downcase}"
      require entity_file
      MOCO.const_get(entity_class_name)
    rescue LoadError
      MOCO::BaseEntity
    end

    def method_missing(method_name, *args, &)
      if method_name.to_s.match?(/^[a-z_]+$/) && args.empty?
        CollectionProxy.new(client, "#{path}/#{method_name}", entity_class_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.match?(/^[a-z_]+$/) || super
    end

    def all(params = {})
      wrap_response(client.get(path, params))
    end

    def find(id)
      entity_class.new(client, client.get("#{path}/#{id}"))
    end

    def where(filters = {})
      wrap_response(client.get(path, filters))
    end

    def create(attributes)
      entity_class.new(client, client.post(path, attributes))
    end

    def update(id, attributes)
      entity_class.new(client, client.put("#{path}/#{id}", attributes))
    end

    def delete(id)
      client.delete("#{path}/#{id}")
    end

    def each(&)
      all.each(&)
    end

    private

    def entity_class
      @entity_class ||= MOCO.const_get(entity_class_name)
    end

    def wrap_response(response)
      response.is_a?(Array) ? response.map { |i| entity_class.new(client, i) } : entity_class.new(client, response)
    end
  end
end
