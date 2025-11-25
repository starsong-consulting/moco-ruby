#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require_relative "lib/moco"

options = {
  from: nil,
  to: nil,
  project: nil,
  match_project_threshold: 0.8,
  match_task_threshold: 0.45,
  debug: false,
  default_task: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] source target"

  opts.on("-f", "--from DATE", "Start date (YYYY-MM-DD)") do |date|
    options[:from] = date
  end

  opts.on("-t", "--to DATE", "End date (YYYY-MM-DD)") do |date|
    options[:to] = date
  end

  opts.on("-p", "--project PROJECT_ID", "Project ID to filter by") do |project_id|
    options[:project_id] = project_id
  end

  opts.on("-c", "--company COMPANY_ID", "Company ID to filter by") do |company_id|
    options[:company_id] = company_id
  end

  opts.on("-g", "--term TERM", "Term to filter for") do |term|
    options[:term] = term
  end

  opts.on("-n", "--dry-run", "Match only, but do not edit data") do
    options[:dry_run] = true
  end

  opts.on("--match-project-threshold VALUE", Float, "Project matching threshold (0.0 - 1.0), default 0.8") do |val|
    options[:match_project_threshold] = val
  end

  opts.on("--match-task-threshold VALUE", Float, "Task matching threshold (0.0 - 1.0), default 0.45") do |val|
    options[:match_task_threshold] = val
  end

  opts.on("-d", "--debug", "Enable debug output") do
    options[:debug] = true
  end

  opts.on("--default-task TASK_NAME", "Default task name to map unmatched tasks to (avoids creating new tasks)") do |task_name|
    options[:default_task] = task_name
  end
end.parse!

source_instance = ARGV.shift
target_instance = ARGV.shift
if source_instance.nil?
  warn "Source instance is required"
  exit 1
end
if target_instance.nil?
  warn "Target instance is required"
  exit 1
end

config = YAML.load_file("config.yml")
source_config = config["instances"].fetch(source_instance, nil)
target_config = config["instances"].fetch(target_instance, nil)

source_client = MOCO::Client.new(subdomain: source_instance, api_key: source_config["api_key"], debug: options[:debug])
target_client = MOCO::Client.new(subdomain: target_instance, api_key: target_config["api_key"], debug: options[:debug])

syncer = MOCO::Sync.new(
  source_client,
  target_client,
  project_match_threshold: options[:match_project_threshold],
  task_match_threshold: options[:match_task_threshold],
  filters: {
    source: options.slice(:from, :to, :project_id, :company_id, :term),
    target: options.slice(:from, :to)
  },
  dry_run: options[:dry_run],
  debug: options[:debug],
  default_task_name: options[:default_task]
)

syncer.source_projects.each do |project|
  if syncer.project_mapping[project.id]
    puts "✅ Project #{project} --> #{syncer.project_mapping[project.id]}"
    project.tasks.each do |task|
      if syncer.task_mapping[task.id]
        puts "  ✅ Task #{task} --> #{syncer.task_mapping[task.id]}"
      else
        puts "  ❌ Task #{task} not mapped"
      end
    end
  else
    puts "❌ Project #{project} not mapped"
  end
  puts ""
end

syncer.sync do |event, source, target|
  case event
  when :equal
    puts "👀 EXISTS\n     #{source}\n  == #{target}"
  when :update
    puts "📝 UPDATE\n     #{source}\n  -> #{target}"
  when :updated
    puts "UPDATED"
  when :create
    puts "🆕 CREATE\n     #{target}"
  when :created
    puts "CREATED"
  end
end
