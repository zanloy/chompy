#!/usr/bin/env ruby

require 'json'
require 'net/dav'
require 'slim'
require 'sinatra'
require 'yaml'
require_relative 'chompy_helper'

config = YAML.load_file('chompy.yml')

set :bind, config['bind'] if config['bind']
set :port, config['port'] if config['port']

pic_dir = "/home/zan/images"
upload_dir = "uploads"

# Sinatra routes
get('/'){ slim :index }

get('/stream', provides: 'text/event-stream') do
  stream do |out|
    start_time = Time.now
    cnt = { uploaded: 0, skipped: 0 }
    Dir[File.join(pic_dir, '*')].each do |file|
      out << "data: #{File.basename(file)}...\n\n"
      dav = Net::DAV.new(config['owncloud']['davurl'])
      dav.verify_server = false
      dav.credentials(config['owncloud']['user'], config['owncloud']['password'])
      result = upload(dav, file)
      if result[:uploaded]
        cnt[:uploaded] += 1
        out << "data: [<span class='green'>uploaded</span>]<br>\n\n"
      else
        cnt[:skipped] += 1
        out << "data: [<span class='red'>skipped</span>]<br>\n\n"
      end
    end
    elapsed_time = Time.now - start_time
    out << "data: Uploaded: #{cnt[:uploaded]}, Skipped: #{cnt[:skipped]}, Elapsed: #{elapsed_time}s\n\n"
    out << "event: close\n"
    out << "data: close\n\n"
  end
end

get('/check') { slim :check }
post('/check') { JSON.generate(check_hash(params['md5'])) }
get('/check/:hash') { |hash| JSON.generate(check_hash(hash)) }

get('/upload') { slim :upload }
post '/upload' do
  # Validate input
  return "Error: File not in params." if not params['file']
  # Validate it is an image
  #return "Error: Filetype is not image/* (#{params['file'][:type]})" if not params['file'][:type] =~ /^image\//
  # Process
  dav = Net::DAV.new(config['owncloud']['davurl'])
  dav.verify_server = false
  dav.credentials(config['owncloud']['user'], config['owncloud']['password'])
  result = upload(dav, params['file'][:filename], params['file'][:tempfile].path)
  JSON.generate result
end
