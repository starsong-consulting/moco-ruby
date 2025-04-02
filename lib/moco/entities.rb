# frozen_string_literal: true

require_relative "helpers"

module MOCO
  # Base entity class others inherit from, providing comparison, to_h, to_json
  class BaseEntity
    def eql?(other)
      return false unless other.is_a? self.class

      id == other.id
    end

    def hash
      id.hash
    end

    def ==(other)
      id == other.id
    end

    def to_h
      hash = {}
      instance_variables.each do |var|
        key = var.to_s.delete_prefix("@")
        hash[key.to_sym] = instance_variable_get(var)
      end
      hash
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(*arg)
      to_h do |k, v|
        if v.is_a? Hash
          if v.key?(:id) && !v[:id].nil?
            ["#{k}_id", v[:id]]
          else
            [k, v.except(:id)]
          end
        else
          [k, v]
        end
      end.to_h.to_json(arg)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # https://hundertzehn.github.io/mocoapp-api-docs/sections/projects.html
  class Project < BaseEntity
    attr_accessor :id, :active, :name, :customer, :tasks

    def to_s
      [customer&.name, name].join(" / ")
    end
  end

  # https://hundertzehn.github.io/mocoapp-api-docs/sections/project_tasks.html
  class Task < BaseEntity
    attr_accessor :id, :active, :name, :project_id, :billable

    def to_s
      name
    end
  end

  # https://hundertzehn.github.io/mocoapp-api-docs/sections/activities.html
  class Activity < BaseEntity
    attr_accessor :id, :active, :date, :description, :project, :task, :seconds, :hours, :billable, :billed, :user,
                  :customer, :tag

    def to_s
      "#{date} - #{Helpers.decimal_hours_to_civil(hours)}h (#{seconds}s) - #{project&.name} - #{task&.name}#{description.empty? ? "" : " (#{description})"} " \
        "(#{%i[billable billed].map { |x| (send(x) ? "" : "not ") + x.to_s }.join(", ")})"
    end
  end

  # https://hundertzehn.github.io/mocoapp-api-docs/sections/companies.html
  class Customer < BaseEntity
    attr_accessor :id, :name
  end

  # https://hundertzehn.github.io/mocoapp-api-docs/sections/users.html
  class User < BaseEntity
    attr_accessor :id, :firstname, :lastname
  end
end
