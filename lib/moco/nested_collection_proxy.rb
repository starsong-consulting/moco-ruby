# frozen_string_literal: true

module MOCO
  # Provides ActiveRecord-style query interface for nested MOCO entities
  # For example, project.tasks is a nested collection of tasks under a project
  class NestedCollectionProxy < CollectionProxy
    attr_reader :parent, :records

    def initialize(client, parent, path_or_entity_name, entity_class_name)
      @parent = parent
      super(client, path_or_entity_name, entity_class_name)
    end

    # Override determine_base_path to include the parent's path
    # For nested resources, we ignore any custom entity_path and just use simple pluralization
    def determine_base_path(path_or_entity_name)
      parent_type = ActiveSupport::Inflector.underscore(parent.class.name.split("::").last)
      # Use simple tableized name, not entity_path (which might include 'projects/' prefix)
      nested_path = ActiveSupport::Inflector.tableize(path_or_entity_name.to_s)
      "#{parent_type.pluralize}/#{parent.id}/#{nested_path}"
    end

    # Create a new entity in this nested collection
    def create(attributes)
      klass = entity_class
      return nil unless klass && klass <= MOCO::BaseEntity

      klass.new(client, client.post(@base_path, attributes))
    end

    # Delete all entities in this nested collection
    def destroy_all
      client.delete("#{@base_path}/destroy_all")
      true
    rescue StandardError => e
      warn "Warning: Failed to destroy all entities in #{@base_path}: #{e.message}"
      false
    end

    # Make these methods public so they can be accessed by Project#tasks
    public :load_records, :loaded?
  end
end
