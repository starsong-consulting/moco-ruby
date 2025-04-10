#!/usr/bin/env ruby
# frozen_string_literal: true

require "English"
require_relative "lib/moco"

# Initialize client with test credentials
client = MOCO::Client.new(
  subdomain: ENV.fetch("MOCO_API_TEST_SUBDOMAIN", nil),
  api_key: ENV.fetch("MOCO_API_TEST_API_KEY", nil)
)

puts "Testing MOCO API v2 (Read-only operations with ActiveRecord-style queries)"
puts "========================================================================"

# Test projects
puts "\n== Projects =="
begin
  # Test collection proxy functionality
  projects_proxy = client.projects # Should return CollectionProxy
  puts "client.projects.class: #{projects_proxy.class}"
  puts "*** ERROR: client.projects did not return a CollectionProxy! ***" unless projects_proxy.is_a?(MOCO::CollectionProxy)

  # Test fetching all (triggers API call)
  all_projects = projects_proxy.all # Should return Array
  puts "projects_proxy.all.class: #{all_projects.class}"
  puts "*** ERROR: projects_proxy.all did not return an Array! ***" unless all_projects.is_a?(Array)
  puts "Found #{all_projects.size} projects via .all"

  if all_projects.any?
    # Test enumerable methods on the proxy (triggers API call via each)
    puts "Project names (via map on proxy): #{projects_proxy.map(&:name).join(", ")}"

    # Test finding a specific project using find on the proxy
    first_project_from_all = all_projects.first
    project = projects_proxy.find(first_project_from_all.id) # Fetches directly by ID
    puts "Found project by ID (#{first_project_from_all.id}): #{project.name} (Class: #{project.class})"
    puts "*** ERROR: find(id) did not return a MOCO::Project object! ***" unless project.is_a?(MOCO::Project)

    # Test finding the first project using first on the proxy
    first_project = projects_proxy.first # Fetches with limit=1
    puts "First project (via .first): #{first_project.name} (ID: #{first_project.id})"
    puts "First project attributes: #{first_project.attributes.inspect}"

    # Test filtering with where (chainable)
    active_projects_proxy = client.projects.where(active: true)
    puts "client.projects.where(active: true).class: #{active_projects_proxy.class}"
    puts "*** ERROR: where did not return a CollectionProxy! ***" unless active_projects_proxy.is_a?(MOCO::CollectionProxy)
    # Now fetch the results
    active_projects = active_projects_proxy.all
    puts "Found #{active_projects.size} active projects via .where(active: true).all"
    puts "First active project name: #{active_projects.first.name}" if active_projects.any?

    # Test find_by
    found_by_name = client.projects.find_by(name: first_project.name)
    puts "Found project via find_by(name: '#{first_project.name}'): #{found_by_name&.name} (ID: #{found_by_name&.id})"
    puts "*** ERROR: find_by(name: ...) did not return the correct project! ***" unless found_by_name&.id == first_project.id

    # Test modifying and saving
    original_name = project.name

    # Test direct attribute modification and save
    project.name = "#{project.name} (test)"
    project.save
    puts "Updated project name to: #{project.name}"

    # Test update method
    project.update(name: original_name)
    puts "Restored project name via update(): #{project.name}"

    # Test reload method
    project.reload
    puts "Reloaded project from API: #{project.name}"

    # Test destroy method (commented out to prevent actual deletion)
    # if project.destroy
    #   puts "Project successfully deleted"
    # else
    #   puts "Failed to delete project"
    # end

    # Test project tasks
    tasks_proxy = project.tasks
    if tasks_proxy.is_a?(MOCO::CollectionProxy)
      tasks = tasks_proxy.all # Fetch the actual tasks
      puts "  - Tasks: #{tasks.size} tasks (via CollectionProxy)"
      puts "    - First task: #{tasks.first.name}" if tasks.any?
    elsif tasks_proxy.is_a?(Array)
      puts "  - Tasks: #{tasks_proxy.size} tasks (via Array)"
      puts "    - First task: #{tasks_proxy.first.name}" if tasks_proxy.any?
    else
      puts "  - Tasks: Not available (#{tasks_proxy.class})"
    end

    # Test project activities
    activities_proxy = project.activities
    if activities_proxy.is_a?(MOCO::CollectionProxy)
      activities = activities_proxy.all # Fetch the actual activities
      puts "  - Activities: #{activities.size} activities (via CollectionProxy)"
      puts "    - First activity: #{activities.first.date} - #{activities.first.hours}h" if activities.any?
    elsif activities_proxy.is_a?(Array)
      puts "  - Activities: #{activities_proxy.size} activities (via Array)"
      puts "    - First activity: #{activities_proxy.first.date} - #{activities_proxy.first.hours}h" if activities_proxy.any?
    else
      puts "  - Activities: Not available (#{activities_proxy.class})"
    end

    # Test project customer association
    customer = project.customer
    if customer
      puts "  - Customer: #{customer.name} (Class: #{customer.class})" # Should be MOCO::Company
      puts "  *** ERROR: Customer is not a MOCO::Company object! ***" unless customer.is_a?(MOCO::Company)
    else
      puts "  - Customer: Not available or project has no customer"
    end
  end
rescue StandardError => e
  puts "Error fetching projects: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test companies
puts "\n== Companies =="
begin
  companies = client.companies.all
  puts "Found #{companies.size} companies"
  if companies.any?
    company = companies.first
    puts "First company: #{company.name} (ID: #{company.id})"
    puts "Company attributes: #{company.attributes.inspect}"

    # Test company projects
    projects_proxy = company.projects
    if projects_proxy.is_a?(MOCO::CollectionProxy)
      projects = projects_proxy.all # Fetch the actual projects
      puts "  - Projects: #{projects.size} projects (via CollectionProxy)"
      puts "    - First project: #{projects.first.name}" if projects.any?
    elsif projects_proxy.is_a?(Array)
      puts "  - Projects: #{projects_proxy.size} projects (via Array)"
      puts "    - First project: #{projects_proxy.first.name}" if projects_proxy.any?
    else
      puts "  - Projects: Not available (#{projects_proxy.class})"
    end

    # Test company invoices
    invoices_proxy = company.invoices
    if invoices_proxy.is_a?(MOCO::CollectionProxy)
      invoices = invoices_proxy.all # Fetch the actual invoices
      puts "  - Invoices: #{invoices.size} invoices (via CollectionProxy)"
      puts "    - First invoice: #{invoices.first.title}" if invoices.any?
    elsif invoices_proxy.is_a?(Array)
      puts "  - Invoices: #{invoices_proxy.size} invoices (via Array)"
      puts "    - First invoice: #{invoices_proxy.first.title}" if invoices_proxy.any?
    else
      puts "  - Invoices: Not available (#{invoices_proxy.class})"
    end
  end
rescue StandardError => e
  puts "Error fetching companies: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test users
puts "\n== Users =="
begin
  users = client.users.all
  puts "Found #{users.size} users"
  if users.any?
    user = users.first
    puts "First user: #{user.firstname} #{user.lastname} (ID: #{user.id})"
    puts "User attributes: #{user.attributes.inspect}"

    # Test user activities
    activities_proxy = user.activities
    if activities_proxy.is_a?(MOCO::CollectionProxy)
      activities = activities_proxy.all # Fetch the actual activities
      puts "  - Activities: #{activities.size} activities (via CollectionProxy)"
      puts "    - First activity: #{activities.first.date} - #{activities.first.hours}h" if activities.any?
    elsif activities_proxy.is_a?(Array)
      puts "  - Activities: #{activities_proxy.size} activities (via Array)"
      puts "    - First activity: #{activities_proxy.first.date} - #{activities_proxy.first.hours}h" if activities_proxy.any?
    else
      puts "  - Activities: Not available (#{activities_proxy.class})"
    end

    # Test user presences
    presences_proxy = user.presences
    if presences_proxy.is_a?(MOCO::CollectionProxy)
      presences = presences_proxy.all # Fetch the actual presences
      puts "  - Presences: #{presences.size} presences (via CollectionProxy)"
      puts "    - First presence: #{presences.first.date}" if presences.any?
    elsif presences_proxy.is_a?(Array)
      puts "  - Presences: #{presences_proxy.size} presences (via Array)"
      puts "    - First presence: #{presences_proxy.first.date}" if presences_proxy.any?
    else
      puts "  - Presences: Not available (#{presences_proxy.class})"
    end
  end
rescue StandardError => e
  puts "Error fetching users: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test activities
puts "\n== Activities =="
begin
  activities = client.activities.all
  puts "Found #{activities.size} activities"
  if activities.any?
    activity = activities.first
    puts "First activity: #{activity.date} - #{activity.hours}h (ID: #{activity.id})"
    puts "Activity attributes: #{activity.attributes.inspect}"

    # Test activity associations
    act_project = activity.project
    act_task = activity.task
    act_user = activity.user
    puts "  - Project: #{act_project&.name} (Class: #{act_project&.class})" # Should be MOCO::Project
    puts "  - Task: #{act_task&.name} (Class: #{act_task&.class})" # Should be MOCO::Task
    puts "  - User: #{act_user&.firstname} #{act_user&.lastname} (Class: #{act_user&.class})" # Should be MOCO::User

    # Test filtering activities with where (using a generic date range)
    recent_activities_proxy = client.activities.where(date: ">=2023-01-01")
    recent_activities = recent_activities_proxy.all # Fetch results
    puts "Found #{recent_activities.size} activities since 2023-01-01."
    puts "First recent activity: #{recent_activities.first.date} - #{recent_activities.first.hours}h" if recent_activities.any?
  end
rescue StandardError => e
  puts "Error fetching activities: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test invoices
puts "\n== Invoices =="
begin
  invoices = client.invoices.all
  puts "Found #{invoices.size} invoices"
  if invoices.any?
    invoice = invoices.first
    puts "First invoice: #{invoice.title} (ID: #{invoice.id})"
    puts "Invoice attributes: #{invoice.attributes.inspect}"
    puts "  - Company: #{invoice.company.name}" if invoice.company
    puts "  - Project: #{invoice.project.name}" if invoice.project
  end
rescue StandardError => e
  puts "Error fetching invoices: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test deals
puts "\n== Deals =="
begin
  deals = client.deals.all
  puts "Found #{deals.size} deals"
  if deals.any?
    deal = deals.first
    puts "First deal: #{deal.name} (ID: #{deal.id})"
    puts "Deal attributes: #{deal.attributes.inspect}"
    puts "  - Company: #{deal.company.name}" if deal.company
    puts "  - User: #{deal.user.firstname} #{deal.user.lastname}" if deal.user
  end
rescue StandardError => e
  puts "Error fetching deals: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "\nAPI test completed successfully!"
