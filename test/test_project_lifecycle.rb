#!/usr/bin/env ruby
# frozen_string_literal: true

require "English"
require_relative "../lib/moco"

# Initialize client with test credentials from .env
client = MOCO::Client.new(
  subdomain: ENV.fetch("MOCO_API_TEST_SUBDOMAIN", nil),
  api_key: ENV.fetch("MOCO_API_TEST_API_KEY", nil)
)

puts "MOCO API Project Lifecycle Test"
puts "=============================="
puts "This test will create a project, add tasks and activities, then clean up."

# Track created resources for cleanup
created_resources = {
  project: nil,
  tasks: [],
  activities: []
}

begin
  # Step 1: Find a company to associate with our project
  puts "\n== Finding a company =="
  companies = client.companies.all
  if companies.empty?
    puts "No companies found. Cannot create a project without a company."
    exit 1
  end

  company = companies.first
  puts "Using company: #{company.name} (ID: #{company.id})"

  # Step 2: Create a new project
  puts "\n== Creating a test project =="
  project_name = "Test Project #{Time.now.strftime("%Y%m%d%H%M%S")}"

  project = client.projects.create(
    name: project_name,
    customer_id: company.id,
    currency: "EUR",
    leader_id: 933_705_689, # Teal Bauer
    fixed_price: false,
    retainer: false,
    start_date: Date.today.strftime("%Y-%m-%d"),
    finish_date: (Date.today + 30).strftime("%Y-%m-%d"),
    hourly_rate: 100,
    budget: 5000
  )

  created_resources[:project] = project

  puts "Created project: #{project.name} (ID: #{project.id})"
  puts "Project attributes: #{project.attributes.inspect}"

  # Verify project was created correctly
  fetched_project = client.projects.find(project.id)
  puts "Verified project exists: #{fetched_project.name} (ID: #{fetched_project.id})"
  puts "Project customer: #{fetched_project.customer.name}" if fetched_project.customer

  # Step 3: Create tasks for the project
  puts "\n== Creating tasks =="
  task_names = %w[Development Design Testing]

  # Create tasks using the ActiveRecord-style interface
  task_names.each do |task_name|
    # Using project.tasks.create to create tasks
    task = project.tasks.create(
      name: task_name,
      billable: true,
      active: true,
      budget: 1000,
      hourly_rate: 100
    )

    created_resources[:tasks] << task
    puts "Created task: #{task.name} (ID: #{task.id})"
  end

  # Verify tasks were created
  project_tasks = project.tasks.all
  puts "Project has #{project_tasks.size} tasks"
  project_tasks.each do |task|
    puts "- Task: #{task.name} (ID: #{task.id})"
  end

  # Step 4: Create activities (time entries) for the tasks
  puts "\n== Creating activities =="

  # Find a user to associate with activities
  users = client.users.all
  if users.empty?
    puts "No users found. Cannot create activities without a user."
    exit 1
  end

  user = users.first
  puts "Using user: #{user.firstname} #{user.lastname} (ID: #{user.id})"

  # Create an activity for each task
  project_tasks.each_with_index do |task, index|
    # Create activities for different days
    date = Date.today - index

    activity = client.activities.create(
      date: date.strftime("%Y-%m-%d"),
      project_id: project.id,
      task_id: task.id,
      user_id: user.id,
      hours: 2.5,
      description: "Test activity for #{task.name}",
      billable: true
    )

    created_resources[:activities] << activity
    puts "Created activity: #{activity.date} - #{activity.hours}h - #{activity.description} (ID: #{activity.id})"
  end

  # Verify activities were created
  project_activities = project.activities.all
  puts "Project has #{project_activities.size} activities"
  project_activities.each do |activity|
    puts "- Activity: #{activity.date} - #{activity.hours}h - #{activity.task&.name} - #{activity.description} (ID: #{activity.id})"
  end

  # Step 5: Test filtering activities
  puts "\n== Testing activity filtering =="

  # Filter activities by date
  today = Date.today.strftime("%Y-%m-%d")
  todays_activities = client.activities.where(date: today).all
  puts "Found #{todays_activities.size} activities for today (#{today})"

  # Filter activities by project
  project_filtered_activities = client.activities.where(project_id: project.id).all
  puts "Found #{project_filtered_activities.size} activities for project #{project.name}"

  # Filter activities by user
  user_activities = client.activities.where(user_id: user.id).all
  puts "Found #{user_activities.size} activities for user #{user.firstname} #{user.lastname}"

  # Step 6: Test updating a project
  puts "\n== Testing project update =="

  # NOTE: Project updates are restricted in the API, so we'll just print the current name
  puts "Current project name: #{project.name}"
  puts "Skipping update test as it requires additional permissions"

  puts "\n== Test completed successfully! =="
rescue StandardError => e
  puts "Error during test: #{e.message}"
  puts e.backtrace.join("\n")
ensure
  # Cleanup: Delete all created resources
  puts "\n== Cleaning up =="

  # Delete activities first (they depend on tasks and project)
  created_resources[:activities].each do |activity|
    puts "Deleting activity: #{activity.id}"
    activity.destroy
  rescue StandardError => e
    puts "Error deleting activity #{activity.id}: #{e.message}"
  end

  # Delete tasks next (they depend on project)
  if created_resources[:project]
    puts "Deleting all tasks for project: #{created_resources[:project].id}"
    begin
      # Use the destroy_all method on the tasks collection
      created_resources[:project].tasks.destroy_all
    rescue StandardError => e
      puts "Error deleting tasks: #{e.message}"

      # Fallback to individual deletion if bulk deletion fails
      created_resources[:tasks].each do |task|
        puts "Deleting task: #{task.id}"
        begin
          # Delete individual task through the project endpoint
          created_resources[:project].tasks.delete(task.id)
        rescue StandardError => e
          puts "Error deleting task #{task.id}: #{e.message}"
        end
      end
    end
  end

  # Delete project last
  if created_resources[:project]
    begin
      puts "Deleting project: #{created_resources[:project].id}"
      created_resources[:project].destroy
    rescue StandardError => e
      puts "Error deleting project #{created_resources[:project].id}: #{e.message}"
    end
  end

  puts "Cleanup completed."
end

puts "\nProject lifecycle test completed!"
