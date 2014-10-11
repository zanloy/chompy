#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'rest-client'

checkpoint = 'http://localhost:4567/check'
endpoint = 'http://localhost:4567/upload'
files = ARGV

files.each do |file|
  if not File.exists? file
    puts "#{file} does not exist on the file system."
    next
  end
  md5 = Digest::MD5.hexdigest(File.read(file))
  begin
    result = JSON.parse(open(checkpoint + "/#{md5}").read)
    if result['uploaded'] == true
      puts "#{file} already uploaded... skipping."
      next
    end
  rescue => e
    puts "Error during check: #{e}"
  end
  puts "Uploading #{file}..."
  begin
    result = JSON.parse(RestClient.post(endpoint, file: File.new(file)))
    p result
  rescue => e
    puts "Error: #{e}"
  end
end
