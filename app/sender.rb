#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'rest-client'

checkpoint = 'http://localhost:4567/check'
endpoint = 'http://localhost:4567/upload'
files = ARGV

start_time = Time.now
cnt = { uploaded: 0, skipped: 0 }

files.each do |file|
  if not File.exists? file
    puts "#{file} does not exist on the file system."
    next
  end
  md5 = Digest::MD5.hexdigest(File.read(file))
  begin
    result = JSON.parse(open(checkpoint + "/#{md5}").read)
    if result['uploaded'] == true
      cnt[:skipped] += 1
      puts "#{file} already uploaded... skipping."
      next
    end
  rescue => e
    puts "Error during check: #{e}"
  end
  puts "Uploading #{file}..."
  begin
    result = JSON.parse(RestClient.post(endpoint, file: File.new(file)))
    cnt[:uploaded] += 1
    p result
  rescue => e
    puts "Error: #{e}"
  end
end
elapsed_time = Time.now - start_time
puts "Uploaded: #{cnt[:uploaded]}, Skipped: #{cnt[:skipped]}, Elapsed: #{elapsed_time}s"
