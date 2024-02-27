# frozen_string_literal: true

module MOCO
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

    def to_json(*arg)
      to_h.map do |k, v|
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

  class Project < BaseEntity
    attr_accessor :id, :active, :name, :customer, :tasks

    def to_s
      [customer&.name, name].join(' / ')
    end
  end

  class Task < BaseEntity
    attr_accessor :id, :active, :name, :project_id, :billable

    def to_s
      name
    end
  end

  class Activity < BaseEntity
    attr_accessor :id, :active, :date, :description, :project, :task, :seconds, :hours, :billable, :billed, :user, :customer, :tag

    def to_s
      "#{date} - #{hours}h (#{seconds}s) - #{project&.name} - #{task&.name}#{(!description.empty? ? " (#{description})" : '')}" +
      " (#{%i{billable billed}.map{ |x| (self.send(x) ? '' : 'not ') + x.to_s}.join(', ')})"
    end
  end

  class Customer < BaseEntity
    attr_accessor :id, :name
  end

  class User < BaseEntity
    attr_accessor :id, :firstname, :lastname
  end
end
