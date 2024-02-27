#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'json'
require_relative 'lib/moco'

options = { method: 'GET', data: {}, api_key: nil, no_format: false, verbose: false }
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] url\n" +
                "       #{$0} [options] subdomain path"

  opts.on('-X', '--method METHOD', 'Set HTTP method to use') do |method|
    options[:method] = method.upcase
  end

  opts.on('-d', '--data DATA', 'Data to send to server, JSON format') do |data|
    options[:data] = JSON.parse(data)
  end

  opts.on('-a', '--api-key API_KEY', 'Manually specify MOCO API key') do |key|
    options[:api_key] = key
  end

  opts.on('-n', '--no-format', 'Disable JSON pretty-printing') do
    options[:no_format] = true
  end

  opts.on('-v', '--verbose', 'Show additional request and response information') do
    options[:verbose] = true
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
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

if ARGV.size > 0
  subdomain = url
  path = ARGV.shift
  url = "https://#{subdomain}.mocoapp.com/api/v1/#{path.gsub(/\A\//, '')}"
else
  subdomain = extract_subdomain(url)
end

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

if options[:verbose]
  puts "> #{options[:method]} #{result.env.url}"
  puts(result.env.request_headers.map{ |k, v| "> #{k}: #{k == 'Authorization' ? v[0...16] + '<REDACTED>' + v[-4..-1] : v}" })
  puts '>'
  if result.env.request_body
    puts result.env.request_body.split.map{ |l| "> #{l}" }.join
  end
  puts '---'
  puts "< #{result.status} #{result.reason_phrase}"
  puts(result.headers.map{ |k, v| "< #{k}: #{v}" })
  puts ''
end
if options[:no_format]
  puts result.body.to_json
else
  puts JSON.pretty_generate(result.body)
end
