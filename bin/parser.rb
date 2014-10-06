#!/usr/bin/env ruby

require 'json'
require 'rest-client'

endpoint = 'http://localhost:4567/upload'
files = ARGV

files.each do |file|
  if not File.exists? file
    puts "#{file} does not exist on the file system."
    next
  end
  puts "Uploading #{file}..."
  result = JSON.parse(RestClient.post(endpoint, file: File.new(file)))
  p result
end
