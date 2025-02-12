# frozen_string_literal: true

module MOCO
  class Client
    attr_reader :connection
    
    def initialize(subdomain:, api_key:)
      @connection = Connection.new(self, subdomain, api_key)
      @collections = {}
    end
    
    # Dynamically handle entity collection access (e.g., client.projects)
    def method_missing(name, *args, &block)
      if collection_name?(name)
        @collections[name] ||= EntityCollection.new(
          self, 
          name.to_s, 
          ActiveSupport::Inflector.classify(name.to_s)
        )
      else
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
