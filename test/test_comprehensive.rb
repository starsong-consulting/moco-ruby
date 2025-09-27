#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "test_helper"

class TestComprehensive < Test::Unit::TestCase
  def setup
    @client = MOCO::Client.new(
      subdomain: ENV["MOCO_API_TEST_SUBDOMAIN"],
      api_key: ENV["MOCO_API_TEST_API_KEY"]
    )
  end

  # Client Initialization
  sub_test_case "Client Initialization" do
    test "client instance created" do
      assert_instance_of MOCO::Client, @client
    end

    test "connection established" do
      connection = @client.instance_variable_get(:@connection)
      assert_instance_of MOCO::Connection, connection
    end

    test "can make basic API request" do
      users = @client.users.all
      assert_instance_of Array, users
    end
  end

  # Users API
  sub_test_case "Users API" do
    test "fetch all users" do
      users = @client.users.all
      assert_instance_of Array, users
      assert users.size > 0
    end

    test "find specific user" do
      user = @client.users.all.first
      found_user = @client.users.find(user.id)
      assert_equal user.id, found_user.id
    end

    test "user has expected attributes" do
      user = @client.users.all.first
      assert_respond_to user, :id
      assert_respond_to user, :firstname
      assert_respond_to user, :lastname
      assert_respond_to user, :email
    end
  end

  # Companies API (CRUD)
  sub_test_case "Companies API" do
    test "full CRUD lifecycle" do
      # CREATE
      company = @client.companies.create(
        name: "Test Company #{Time.now.to_i}",
        type: "customer"
      )
      assert_not_nil company.id

      # READ
      found = @client.companies.find(company.id)
      assert_equal company.id, found.id

      # UPDATE
      new_name = "Updated Company #{Time.now.to_i}"
      updated = @client.companies.update(company.id, name: new_name)
      assert_equal new_name, updated.name

      # DELETE
      result = @client.companies.delete(company.id)
      assert result
    end
  end

  # Projects API (CRUD)
  sub_test_case "Projects API" do
    setup do
      @test_company = @client.companies.all.first
      @test_user = @client.users.all.first
    end

    test "full CRUD lifecycle" do
      # CREATE
      project = @client.projects.create(
        name: "Test Project #{Time.now.to_i}",
        customer_id: @test_company.id,
        currency: "EUR",
        finish_date: (Date.today + 90).to_s,
        fixed_price: false,
        retainer: false,
        leader_id: @test_user.id,
        billable: true
      )
      assert_not_nil project.id

      # READ
      found = @client.projects.find(project.id)
      assert_equal project.id, found.id

      # UPDATE
      new_name = "Updated Project #{Time.now.to_i}"
      updated = @client.projects.update(project.id, name: new_name)
      assert_equal new_name, updated.name

      # ARCHIVE (cleanup)
      @client.projects.update(project.id, active: false)
    end

    test "query with filters" do
      active_projects = @client.projects.where(active: true).all
      assert_instance_of Array, active_projects
    end
  end

  # Tasks API (Nested Resources)
  sub_test_case "Tasks API (Nested Resources)" do
    setup do
      @project = @client.projects.all.first
    end

    test "full CRUD lifecycle through project" do
      # CREATE
      task = @project.tasks.create(
        name: "Test Task #{Time.now.to_i}",
        billable: true,
        active: true
      )
      assert_not_nil task.id

      # READ
      tasks = @project.tasks.all
      assert tasks.any? { |t| t.id == task.id }

      # UPDATE
      new_name = "Updated Task #{Time.now.to_i}"
      updated = @project.tasks.update(task.id, name: new_name)
      assert_equal new_name, updated.name

      # DELETE
      result = @project.tasks.delete(task.id)
      assert result
    end
  end

  # Activities API
  sub_test_case "Activities API (Time Entries)" do
    setup do
      @project = @client.projects.all.first
      @task = @project.tasks.all.first
    end

    test "full CRUD lifecycle" do
      # CREATE
      activity = @client.activities.create(
        date: Date.today.to_s,
        project_id: @project.id,
        task_id: @task.id,
        hours: 2.5,
        description: "Test activity #{Time.now.to_i}"
      )
      assert_not_nil activity.id

      # READ
      found = @client.activities.find(activity.id)
      assert_equal activity.id, found.id

      # UPDATE
      new_desc = "Updated activity #{Time.now.to_i}"
      updated = @client.activities.update(activity.id, description: new_desc)
      assert_equal new_desc, updated.description

      # Query with date range
      activities = @client.activities.where(
        from: Date.today.to_s,
        to: Date.today.to_s
      ).all
      assert_instance_of Array, activities

      # DELETE
      result = @client.activities.delete(activity.id)
      assert result
    end
  end

  # Entity Associations
  sub_test_case "Entity Associations" do
    setup do
      @project = @client.projects.all.first
    end

    test "project to customer association" do
      customer = @project.customer
      assert_instance_of MOCO::Company, customer
    end

    test "project to leader association" do
      leader = @project.leader
      assert_instance_of MOCO::User, leader
    end

    test "project to tasks association" do
      tasks = @project.tasks.all
      assert_instance_of Array, tasks
    end

    test "activity associations" do
      activity = @client.activities.where(from: (Date.today - 30).to_s).all.first
      return unless activity

      proj = activity.project
      assert_instance_of MOCO::Project, proj if proj

      task = activity.task
      assert_true task.nil? || task.is_a?(MOCO::Task)

      user = activity.user
      assert_true user.is_a?(MOCO::User) || user.is_a?(Hash)
    end
  end

  # Query & Filtering Features
  sub_test_case "Query & Filtering Features" do
    test "where clause with conditions" do
      projects = @client.projects.where(active: true).all
      assert_instance_of Array, projects
    end

    test "find_by with conditions" do
      project = @client.projects.all.first
      return unless project

      found = @client.projects.find_by(name: project.name)
      assert_equal project.name, found.name if found
    end

    test "limit records" do
      users = @client.users.limit(1).all
      assert users.size <= 1
    end

    test "first record" do
      user = @client.users.first
      assert_instance_of MOCO::User, user
    end
  end

  # Other API Endpoints
  sub_test_case "Other API Endpoints" do
    test "fetch schedules" do
      schedules = @client.schedules.all
      assert_instance_of Array, schedules
    end

    test "fetch invoices" do
      invoices = @client.invoices.all
      assert_instance_of Array, invoices
    end

    test "fetch deals" do
      deals = @client.deals.all
      assert_instance_of Array, deals
    end

    test "fetch presences" do
      presences = @client.presences.all
      assert_instance_of Array, presences
    end
  end

  # Data Formats & Conversions
  sub_test_case "Data Formats & Conversions" do
    setup do
      @project = @client.projects.all.first
    end

    test "entity to_h conversion" do
      hash = @project.to_h
      assert_instance_of Hash, hash
      assert hash.key?(:id)
    end

    test "entity to_json conversion" do
      json = @project.to_json
      parsed = JSON.parse(json)
      assert_instance_of Hash, parsed
    end

    test "entity to_s conversion" do
      str = @project.to_s
      assert_instance_of String, str
      assert str.length > 0
    end

    test "entity attributes accessible" do
      attrs = @project.attributes
      assert_instance_of Hash, attrs
    end
  end
end
