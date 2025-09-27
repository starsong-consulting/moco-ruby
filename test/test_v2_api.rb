#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "test_helper"
require "webmock/test_unit"

class TestV2API < Test::Unit::TestCase
  def setup
    WebMock.disable_net_connect!
    @client = MOCO::Client.new(subdomain: "example", api_key: "test-api-key")
  end

  def teardown
    WebMock.reset!
  end

  def test_get_projects
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects")
      .with(
        headers: {
          "Authorization" => "Token token=test-api-key"
        }
      )
      .to_return(
        status: 200,
        body: [
          {
            id: 123,
            name: "Test Project",
            customer: {
              id: 456,
              name: "Test Customer"
            },
            tasks: [
              {
                id: 789,
                name: "Development",
                project_id: 123,
                billable: true
              }
            ]
          }
        ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    projects = @client.projects.all
    assert_equal 1, projects.size
    assert_equal 123, projects.first.id
    assert_equal "Test Project", projects.first.name

    # Customer association
    assert_instance_of MOCO::Company, projects.first.customer
    assert_equal "Test Customer", projects.first.customer.name

    # Tasks are embedded in response but accessed via proxy
    # (Note: In production, embedded tasks are ignored in favor of fresh API calls)
    assert_respond_to projects.first, :tasks
  end

  def test_get_project
    stub_request(:get, "https://example.mocoapp.com/api/v1/projects/123")
      .with(
        headers: {
          "Authorization" => "Token token=test-api-key"
        }
      )
      .to_return(
        status: 200,
        body: {
          id: 123,
          name: "Test Project",
          customer: {
            id: 456,
            name: "Test Customer"
          },
          tasks: [
            {
              id: 789,
              name: "Development",
              project_id: 123,
              billable: true
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    project = @client.projects.find(123)
    assert_equal 123, project.id
    assert_equal "Test Project", project.name
    assert_equal "Test Customer", project.customer.name
  end

  def test_create_activity
    stub_request(:post, "https://example.mocoapp.com/api/v1/activities")
      .with(
        body: {
          date: "2023-01-01",
          project_id: 123,
          task_id: 456,
          hours: 2,
          description: "Test Activity"
        }.to_json,
        headers: {
          "Authorization" => "Token token=test-api-key",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 201,
        body: {
          id: 789,
          date: "2023-01-01",
          project: {
            id: 123,
            name: "Test Project"
          },
          task: {
            id: 456,
            name: "Development"
          },
          hours: 2,
          description: "Test Activity"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    activity = @client.activities.create(
      date: "2023-01-01",
      project_id: 123,
      task_id: 456,
      hours: 2,
      description: "Test Activity"
    )

    assert_equal 789, activity.id
    assert_equal "2023-01-01", activity.date
    assert_equal 123, activity.project.id
    assert_equal 456, activity.task.id
    assert_equal 2, activity.hours
    assert_equal "Test Activity", activity.description
  end

  def test_dynamic_collection_access
    assert_respond_to @client, :projects
    assert_respond_to @client, :activities
    assert_respond_to @client, :users
    assert_respond_to @client, :companies
    assert_respond_to @client, :tasks
    assert_respond_to @client, :invoices
    assert_respond_to @client, :deals
    assert_respond_to @client, :expenses
    assert_respond_to @client, :web_hooks
    assert_respond_to @client, :schedules
    assert_respond_to @client, :presences
    assert_respond_to @client, :holidays
    assert_respond_to @client, :planning_entries
  end
end
