#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require "fuzzy_match"
require_relative "lib/moco"

options = {
  dry_run: false,
  verbose: false,
  copy_activities: true
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] source_instance target_instance project_identifier"

  opts.on("-n", "--dry-run", "Show what would be copied without making changes") do
    options[:dry_run] = true
  end

  opts.on("-v", "--verbose", "Enable verbose output") do
    options[:verbose] = true
  end

  opts.on("--no-activities", "Skip copying activities (only copy project and tasks)") do
    options[:copy_activities] = false
  end

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

source_instance = ARGV.shift
target_instance = ARGV.shift
project_identifier = ARGV.shift

if source_instance.nil? || target_instance.nil? || project_identifier.nil?
  warn "Error: source_instance, target_instance, and project_identifier are required"
  warn "Usage: #{$PROGRAM_NAME} [options] source_instance target_instance project_identifier"
  exit 1
end

# Load configuration
config = YAML.load_file("config.yml")
source_config = config["instances"].fetch(source_instance, nil)
target_config = config["instances"].fetch(target_instance, nil)

if source_config.nil?
  warn "Error: Source instance '#{source_instance}' not found in config.yml"
  exit 1
end

if target_config.nil?
  warn "Error: Target instance '#{target_instance}' not found in config.yml"
  exit 1
end

# Initialize clients
puts "Connecting to instances..."
source_client = MOCO::Client.new(subdomain: source_instance, api_key: source_config["api_key"])
target_client = MOCO::Client.new(subdomain: target_instance, api_key: target_config["api_key"])

def log(message, verbose: false, options:)
  return if verbose && !options[:verbose]
  puts message
end

def get_id(obj)
  return nil if obj.nil?
  return obj[:id] if obj.is_a?(Hash)
  return obj.id if obj.respond_to?(:id)
  nil
end

def find_or_create_customer(source_customer, target_client, options)
  log("Looking for customer '#{source_customer.name}' in target...", options: options)

  # Try to find the customer by name
  target_customers = target_client.companies.all
  target_customer = target_customers.find { |c| c.name == source_customer.name }

  if target_customer
    log("✅ Found existing customer: #{target_customer.name} (ID: #{target_customer.id})", options: options)
    return target_customer
  end

  log("Customer not found, creating new customer...", options: options)

  if options[:dry_run]
    log("🔍 [DRY RUN] Would create customer: #{source_customer.name}", options: options)
    return nil
  end

  # Create the customer
  customer_attrs = {
    name: source_customer.name,
    type: "customer"
  }

  # Add optional attributes if they exist
  customer_attrs[:type] = source_customer.type if source_customer.respond_to?(:type) && source_customer.type
  customer_attrs[:currency] = source_customer.currency if source_customer.respond_to?(:currency) && source_customer.currency
  customer_attrs[:website] = source_customer.website if source_customer.respond_to?(:website) && source_customer.website
  customer_attrs[:address] = source_customer.address if source_customer.respond_to?(:address) && source_customer.address
  customer_attrs[:info] = source_customer.info if source_customer.respond_to?(:info) && source_customer.info
  customer_attrs[:custom_properties] = source_customer.custom_properties if source_customer.respond_to?(:custom_properties) && source_customer.custom_properties
  customer_attrs[:labels] = source_customer.labels if source_customer.respond_to?(:labels) && source_customer.labels

  log("Creating customer: #{customer_attrs[:name]}", verbose: true, options: options)
  new_customer = target_client.companies.create(customer_attrs)
  log("✅ Created customer: #{new_customer.name} (ID: #{new_customer.id})", options: options)

  new_customer
end

def copy_tasks(source_project, target_project, target_client, options)
  log("\nCopying tasks...", options: options)
  task_mapping = {}

  source_tasks = source_project.tasks
  log("Found #{source_tasks.count} tasks in source project", options: options)

  source_tasks.each do |source_task|
    log("  Task: #{source_task.name}", verbose: true, options: options)

    if options[:dry_run]
      log("  🔍 [DRY RUN] Would create task: #{source_task.name}", options: options)
      next
    end

    # Create the task in the target project
    task_attrs = {
      name: source_task.name,
      billable: source_task.billable,
      active: source_task.active
    }

    # Add optional attributes if they exist
    source_task_attrs = source_task.instance_variable_get(:@attributes)
    task_attrs[:budget] = source_task_attrs[:budget] if source_task_attrs[:budget]
    task_attrs[:hourly_rate] = source_task_attrs[:hourly_rate] if source_task_attrs[:hourly_rate]

    log("  Creating task: #{task_attrs[:name]}", verbose: true, options: options)
    # Use the NestedCollectionProxy to create the task
    task_proxy = MOCO::NestedCollectionProxy.new(target_client, target_project, :tasks, "Task")
    new_task = task_proxy.create(task_attrs)
    task_mapping[source_task.id] = new_task
    log("  ✅ Created task: #{new_task.name} (ID: #{new_task.id})", options: options)
  end

  task_mapping
end

def copy_activities(source_project, target_project, task_mapping, source_client, target_client, options)
  log("\nCopying activities...", options: options)

  # Get all activities for the source project
  source_activities = source_client.activities.where(project_id: source_project.id).all
  log("Found #{source_activities.count} activities in source project", options: options)

  created_count = 0
  skipped_count = 0

  source_activities.each do |source_activity|
    log("  Activity: #{source_activity.date} - #{source_activity.hours}h - #{source_activity.description}", verbose: true, options: options)

    if options[:dry_run]
      log("  🔍 [DRY RUN] Would create activity: #{source_activity.date} - #{source_activity.hours}h", options: options)
      next
    end

    # Map the task
    target_task = task_mapping[source_activity.task&.id]

    if source_activity.task && !target_task
      log("  ⚠️  Skipping activity - task not mapped: #{source_activity.task.name}", options: options)
      skipped_count += 1
      next
    end

    # Create the activity in the target project
    activity_attrs = {
      date: source_activity.date,
      hours: source_activity.hours,
      description: source_activity.description,
      project_id: target_project.id,
      billable: source_activity.billable,
      tag: source_activity.tag,
      remote_service: source_activity.remote_service,
      remote_id: source_activity.id.to_s # Store original ID for reference
    }

    activity_attrs[:task_id] = target_task.id if target_task

    log("  Creating activity: #{activity_attrs[:date]} - #{activity_attrs[:hours]}h", verbose: true, options: options)

    begin
      new_activity = target_client.activities.create(activity_attrs)
      created_count += 1
      log("  ✅ Created activity: #{new_activity.date} - #{new_activity.hours}h (ID: #{new_activity.id})", verbose: true, options: options)
    rescue => e
      log("  ❌ Error creating activity: #{e.message}", options: options)
      skipped_count += 1
    end
  end

  log("\n✅ Created #{created_count} activities", options: options)
  log("⚠️  Skipped #{skipped_count} activities", options: options) if skipped_count > 0
end

# Main execution
begin
  log("=" * 80, options: options)
  log("MOCO Project Copy Tool", options: options)
  log("=" * 80, options: options)
  log("Source: #{source_instance}", options: options)
  log("Target: #{target_instance}", options: options)
  log("Project: #{project_identifier}", options: options)
  log("Mode: #{options[:dry_run] ? 'DRY RUN' : 'LIVE'}", options: options)
  log("=" * 80, options: options)

  # Find the source project
  log("\nFinding source project...", options: options)
  source_project = source_client.projects.where(identifier: project_identifier).all.first

  if source_project.nil?
    warn "Error: Project '#{project_identifier}' not found in source instance"
    exit 1
  end

  log("✅ Found project: #{source_project.name} (ID: #{source_project.id})", options: options)
  log("   Identifier: #{source_project.identifier}", verbose: true, options: options)
  log("   Status: #{source_project.active ? 'Active' : 'Inactive'}", verbose: true, options: options)

  # Get the customer
  source_customer = source_project.customer
  if source_customer.nil?
    warn "Error: Project has no associated customer"
    exit 1
  end

  log("   Customer: #{source_customer.name} (ID: #{source_customer.id})", options: options)

  # Find or create the customer in the target
  target_customer = find_or_create_customer(source_customer, target_client, options)

  if options[:dry_run]
    log("\n🔍 [DRY RUN] Would create project: #{source_project.name}", options: options)
    log("   Identifier: #{source_project.identifier}", options: options)
    log("   Customer: #{source_customer.name}", options: options)

    # Still show what tasks would be copied
    copy_tasks(source_project, source_project, target_client, options)

    if options[:copy_activities]
      log("\n🔍 [DRY RUN] Would copy activities...", options: options)
      source_activities = source_client.activities.where(project_id: source_project.id).all
      log("   Found #{source_activities.count} activities to copy", options: options)
    end

    log("\n" + "=" * 80, options: options)
    log("DRY RUN COMPLETE - No changes made", options: options)
    log("=" * 80, options: options)
    exit 0
  end

  # Create the project in the target
  log("\nCreating project in target...", options: options)

  # Access attributes directly from the source project
  source_attrs = source_project.instance_variable_get(:@attributes)

  project_attrs = {
    name: source_project.name,
    identifier: source_project.identifier,
    customer_id: target_customer.id,
    currency: source_project.currency,
    billable: source_project.billable,
    fixed_price: source_attrs[:fixed_price] || false,
    retainer: source_attrs[:retainer] || false,
    finish_date: source_attrs[:finish_date],
    start_date: source_attrs[:start_date]
  }

  # Get a default user from the target instance as leader
  # TODO: implement proper user mapping between instances (match by name/email)
  target_users = target_client.users.all
  if target_users.empty?
    raise "No users found in target instance - cannot set project leader"
  end
  project_attrs[:leader_id] = target_users.first.id
  log("Using default leader: #{target_users.first.firstname} #{target_users.first.lastname} (ID: #{target_users.first.id})", verbose: true, options: options)

  # Add optional attributes if they exist
  project_attrs[:co_leader_id] = get_id(source_attrs[:co_leader]) if source_attrs[:co_leader]
  project_attrs[:budget] = source_attrs[:budget] if source_attrs[:budget]
  project_attrs[:budget_monthly] = source_attrs[:budget_monthly] if source_attrs[:budget_monthly]
  project_attrs[:budget_expenses] = source_attrs[:budget_expenses] if source_attrs[:budget_expenses]
  project_attrs[:hourly_rate] = source_attrs[:hourly_rate] if source_attrs[:hourly_rate]
  project_attrs[:custom_properties] = source_attrs[:custom_properties] if source_attrs[:custom_properties]
  project_attrs[:labels] = source_attrs[:labels] if source_attrs[:labels]
  project_attrs[:tags] = source_attrs[:tags] if source_attrs[:tags]
  project_attrs[:info] = source_attrs[:info] if source_attrs[:info]
  project_attrs[:billing_address] = source_attrs[:billing_address] if source_attrs[:billing_address]
  project_attrs[:billing_variant] = source_attrs[:billing_variant] if source_attrs[:billing_variant]

  log("Creating project: #{project_attrs[:name]}", verbose: true, options: options)
  target_project = target_client.projects.create(project_attrs)
  log("✅ Created project: #{target_project.name} (ID: #{target_project.id})", options: options)

  # Copy tasks
  task_mapping = copy_tasks(source_project, target_project, target_client, options)

  # Copy activities if requested
  if options[:copy_activities]
    copy_activities(source_project, target_project, task_mapping, source_client, target_client, options)
  else
    log("\nSkipping activities (--no-activities specified)", options: options)
  end

  log("\n" + "=" * 80, options: options)
  log("✅ PROJECT COPY COMPLETE", options: options)
  log("=" * 80, options: options)
  log("Source project: #{source_project.name} (#{source_instance})", options: options)
  log("Target project: #{target_project.name} (#{target_instance})", options: options)
  log("Target project ID: #{target_project.id}", options: options)
  log("Target project URL: https://#{target_instance}.mocoapp.com/projects/#{target_project.id}", options: options)
  log("=" * 80, options: options)

rescue => e
  warn "\n❌ Error: #{e.message}"
  warn e.backtrace.join("\n") if options[:verbose]
  exit 1
end
