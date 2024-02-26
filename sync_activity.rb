#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require_relative './lib/moco'

options = {
  from: nil,
  to: nil,
  project: nil,
  match_project_threshold: 0.8,
  match_task_threshold: 0.55
}

OptionParser.new do |opts|
  opts.banner = "Usage: ./sync_activities.rb [options] source target"

  opts.on("-f", "--from DATE", "Start date (YYYY-MM-DD)") do |date|
    options[:from] = date 
  end

  opts.on("-t", "--to DATE", "End date (YYYY-MM-DD)") do |date|
    options[:to] = date 
  end

  opts.on("-p", "--project PROJECT_ID", "Project ID to filter by") do |project_id|
    options[:project] = project_id 
  end

  opts.on("--match-project-threshold VALUE", Float, "Project matching threshold (0.0 - 1.0)") do |val|
    options[:match_project_threshold] = val 
  end

  opts.on("--match-task-threshold VALUE", Float, "Task matching threshold (0.0 - 1.0)") do |val|
    options[:match_task_threshold] = val 
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

config = YAML.load_file('config.yml')
source_config = config['instances'].fetch(source_instance, nil)
target_config = config['instances'].fetch(target_instance, nil)

source_api = MOCO::API.new(source_instance, source_config['api_key'])
target_api = MOCO::API.new(target_instance, target_config['api_key'])

syncer = MOCO::Sync.new(source_api, target_api, config)
syncer.sync(options.slice(:from, :to, :project))
