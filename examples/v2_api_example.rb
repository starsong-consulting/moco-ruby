#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "moco"
require "yaml"

# Load configuration from config.yml
config = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config.yml"))
instance = config["instances"].first

# Initialize client
moco = MOCO::Client.new(
  subdomain: instance["subdomain"],
  api_key: instance["api_key"]
)

puts "Connected to MOCO instance: #{instance["subdomain"]}"

# Get all active projects
puts "\nActive Projects:"
projects = moco.projects.where(active: "true")
projects.each do |project|
  puts "- #{project.id}: #{project.name} (#{project.customer&.name})"
end

# Get a specific project
if projects.any?
  project = projects.first
  puts "\nProject Details for #{project.name}:"
  puts "  Customer: #{project.customer&.name}"

  # Get tasks for the project
  puts "  Tasks:"
  project.tasks.each do |task|
    puts "  - #{task.name} (#{task.billable ? "Billable" : "Non-billable"})"
  end

  # Get recent activities for the project
  puts "\nRecent Activities for #{project.name}:"
  activities = project.activities
  activities.each do |activity|
    puts "  - #{activity.date}: #{activity.hours}h - #{activity.description} (#{activity.user&.full_name})"
  end

  # Demonstrate chaining (commented out to avoid modifying data)
  # project.archive.assign_to_group(123).unarchive
end

# Get users
puts "\nUsers:"
users = moco.users.all
users.each do |user|
  puts "- #{user.id}: #{user.full_name}"
end

# Dynamic access to any collection
puts "\nDemonstrating dynamic collection access:"
collections = %w[companies deals invoices expenses schedules presences holidays planning_entries]
collections.each do |collection|
  if moco.respond_to?(collection)
    count = begin
      moco.send(collection).count
    rescue StandardError
      0
    end
    puts "- #{collection}: #{count} items"
  else
    puts "- #{collection}: not available"
  end
end

puts "\nExample completed successfully!"
