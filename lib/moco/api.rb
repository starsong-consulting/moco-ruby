# frozen_string_literal: true

require 'faraday'
require_relative './entities'

module MOCO
  class API
    def initialize(subdomain, api_key)
      @subdomain = subdomain
      @api_key = api_key
      @conn = Faraday.new do |f|
        f.request :json
        f.response :json
        f.request :authorization, 'Token', "token=#{@api_key}" if @api_key
        f.url_prefix = "https://#{@subdomain}.mocoapp.com/api/v1"
      end
    end

    %w[get post put patch delete].each do |method|
      define_method(method) do |path, *args|
        @conn.send(method, path, *args)
      end
    end

    def get_projects(**args)
      response = @conn.get("projects?#{Faraday::Utils.build_query(args)}")
      parse_projects_response(response.body)
    end

    def get_assigned_projects(**args)
      response = @conn.get("projects/assigned?#{Faraday::Utils.build_query(args)}")
      parse_projects_response(response.body)
    end

    def get_activities(filters = {})
      response = @conn.get("activities?#{Faraday::Utils.build_query(filters)}")
      parse_activities_response(response.body)
    end

    def create_activity(activity)
      api_entity = activity.to_h.except(:id, :project, :user, :customer).tap do |h|
        h[:project_id] = activity.project.id
        h[:task_id] = activity.task.id
      end
      @conn.post('activities', api_entity)
    end

    def update_activity(activity)
      api_entity = activity.to_h.except(:project, :user, :customer).tap do |h|
        h[:project_id] = activity.project.id
        h[:task_id] = activity.task.id
      end
      @conn.put("activities/#{activity.id}", api_entity)
    end

    private

    def parse_projects_response(data)
      data.map do |project_data|
        Project.new.tap do |project|
          project.id = project_data['id']
          project.name = project_data['name']
          project.customer = parse_customer_reference(project_data['customer'])
          project.tasks = project_data['tasks'].map do |task_data|
            Task.new.tap do |task|
              task.id = task_data['id']
              task.name = task_data['name']
              task.project_id = task_data['project_id']
              task.billable = task_data['billable']
            end
          end
        end
      end
    end

    def parse_activities_response(data)
      data.map do |activity_data|
        Activity.new.tap do |activity|
          activity.id = activity_data['id']
          activity.date = activity_data['date']
          activity.description = activity_data['description']
          activity.user = parse_user_reference(activity_data['user'])
          activity.customer = parse_customer_reference(activity_data['customer'])
          activity.project = parse_project_reference(activity_data['project'])
          activity.task = parse_task_reference(activity_data['task'])
          activity.hours = activity_data['hours']
          activity.seconds = activity_data['seconds']
          activity.billable = activity_data['billable']
          activity.billed = activity_data['billed']
          activity.tag = activity_data['tag']
        end
      end
    end

    def parse_project_reference(project_data)
      Project.new.tap do |project|
        project.id = project_data['id']
        project.name = project_data['name']
      end
    end

    def parse_task_reference(task_data)
      Task.new.tap do |task|
        task.id = task_data['id']
        task.name = task_data['name']
      end
    end

    def parse_user_reference(user_data)
      User.new.tap do |user|
        user.id = user_data['id']
        user.firstname = user_data['firstname']
        user.lastname = user_data['lastname']
      end
    end

    def parse_customer_reference(customer_data)
      Customer.new.tap do |customer|
        customer.id = customer_data['id']
        customer.name = customer_data['name']
      end
    end
  end
end
