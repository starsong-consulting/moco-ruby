#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'json'
require_relative 'lib/moco'

options = { method: 'GET', data: {}, api_key: nil }
OptionParser.new do |opts|
  opts.banner = 'Usage: mocurl [-X method] [-d data] [-a api_key] url'

  opts.on('-X', '--method METHOD', 'Set HTTP method to use') do |method|
    options[:method] = method.upcase
  end

  opts.on('-d', '--data DATA', 'Data to send to server, JSON format') do |data|
    options[:data] = JSON.parse(data)
  end

  opts.on('-a', '--api-key API_KEY', 'API Key (overrides config)') do |key|
    options[:api_key] = key
  end

  opts.on('-n', '--no-format', 'Disable JSON formatting') do
    options[:no_format] = true
  end
end.parse!

def extract_subdomain(url)
  url.match(%r{https?://([^.]+)\.mocoapp\.com})[1]
end

# Ensure we have a URL
url = ARGV.shift
if url.nil?
  warn 'Error: URL is required'
  exit 1
end

subdomain = extract_subdomain(url)

# Load default API key from config
config = YAML.load_file('config.yml')
options[:api_key] ||= config['instances'].fetch(subdomain, nil)&.fetch('api_key', nil)

warn "Error: No API key found for `#{subdomain}' and none given, continuing without" if options[:api_key].nil?

api = MOCO::API.new(subdomain, options[:api_key])

case options[:method]
when 'GET'
  result = api.get(url)
when 'DELETE'
  result = api.get(url)
when 'POST'
  result = api.post(url, options[:data])
when 'PUT'
  result = api.put(url, options[:data])
when 'PATCH'
  result = api.put(url, options[:data])
else
  puts "Error: Invalid HTTP Method: #{options[:method]}"
  exit 1
end

if options.key?(:no_format)
  puts result.body
else
  puts JSON.pretty_generate(result.body)
end
