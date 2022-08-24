require 'optparse'
require 'uri'
require 'net/http'
require 'dotenv'
require 'json'

options = {
  source_org: 'kuadrant',
  source_repo: 'limitador',
  target_org: 'kuadrant',
  renames_file_path: 'renames',
  dotenv_file_path: '.env',
  dry_run: false,
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: run.rb --target-repo=myrepo [options]"

  opts.on("--source-org VALUE", "Source GitHub organization (default: '#{options[:source_org]}')") { |v| options[:source_org] = v }
  opts.on("--source-repo VALUE", "Source GitHub repo (default: '#{options[:source_repo]}')") { |v| options[:source_repo] = v }
  opts.on("--target-org VALUE", "Target GitHub organization (default: '#{options[:target_org]}')") { |v| options[:target_org] = v }
  opts.on("--target-repo VALUE", "Target GitHub repo") { |v| options[:target_repo] = v }
  opts.on("--renames-file-path VALUE", "Path to the key/value renames file (default: '#{options[:renames_file_path]}')") { |v| options[:renames_file_path] = v }
  opts.on("--dotenv-file-path VALUE", "Path to the .env file (default: '#{options[:dotenv_file_path]}')") { |v| options[:dotenv_file_path] = v }
  opts.on("--dry-run", "Dry run (default: '#{options[:dry_run]}')") { |v| options[:dry_run] = v }

  opts.on('-h', '--help', 'Displays this help') do
    puts opts
    exit
  end
end

optparse.parse!
raise OptionParser::MissingArgument unless options[:target_repo]

Dotenv.load(options[:dotenv_file_path])

github_token = ENV['GITHUB_TOKEN']
github_endpoint = 'https://api.github.com/repos'

renames = File.exist?(options[:renames_file_path]) ? File.read(options[:renames_file_path]).split("\n").map { |kv| kv.split("=") }.to_h.invert : {}

source_uri = URI.parse([github_endpoint, options[:source_org], options[:source_repo], 'labels'].join('/'))
req = Net::HTTP::Get.new(source_uri)
req['Accept'] = 'application/vnd.github+json'
req['Authorization'] = "token #{github_token}"
http = Net::HTTP.new(source_uri.hostname, source_uri.port)
http.use_ssl = true
res = http.request(req)
source = JSON.parse(res.body)
source_labels = source.map do |label|
  [label['name'], label.slice('color', 'description', 'default')]
end.to_h

target_uri = URI.parse([github_endpoint, options[:target_org], options[:target_repo], 'labels'].join('/'))

if options[:dry_run]
  uri_padding = target_uri.to_s.size + source_labels.keys.map(&URI::Parser.new.method(:escape)).map(&:size).max + 2
end

source_labels.each do |label_name, label_data|
  if renames.key?(label_name)
    klass = Net::HTTP::Patch
    uri = URI::join(target_uri, URI::Parser.new.escape(label_name))
    data = label_data.merge(new_name: label_name)
  else
    klass = Net::HTTP::Post
    uri = target_uri
    data = label_data.merge(name: label_name)
  end

  req = klass.new(uri)
  req['Accept'] = 'application/vnd.github+json'
  req['Authorization'] = "token #{github_token}"
  req.body = data.to_json
  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true

  if options[:dry_run]
    puts "#{req.method.ljust(6)} #{uri.to_s.ljust(uri_padding)} #{req.body}"
    next
  end

  res = http.request(req)
end
