#!/usr/bin/env ruby

require 'haml'
require 'json'
require 'net/dav'
require 'sinatra'
require 'yaml'
require_relative 'chompy_helper'

config = YAML.load_file('chompy.yml')

set :bind, config['bind'] if config['bind']
set :port, config['port'] if config['port']

pic_dir = "/home/zan/images"
upload_dir = "uploads"

# Sinatra routes
get('/'){ haml :index }

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

get('/check') { haml :check }
post('/check') { JSON.generate(check_hash(params['md5'])) }
get('/check/:hash') { |hash| JSON.generate(check_hash(hash)) }

get('/upload') { haml :upload }
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

__END__

@@ layout
!!! 5
%html
  %head
    %title Chompy
    %meta{charset:"utf-8"}
    %meta{name:"viewport", content:"width=device-width, minimum-scale=1.0, maximum-scale=1.0"}
    %link{rel:'stylesheet', type:'text/css', href: '/css/style.css'}
    %script(src="http://rightjs.org/hotlink/right.js")
    %script(src="/js/chompy.js")
  %body
    %h1 Chompy
    = yield

@@ index
%h2 Upload From Directory
%input#btnStream(type="button" value="Start!")
#stream

@@ check
%h2 Check File
%form(method="post")
  %label MD5:
  %input(name="md5")
  %br
  %input(type="submit" value="Check")

@@ upload
%h2 Upload File
%form(method='post' enctype='multipart/form-data')
  %label File:
  %input(type='file' name='file')
  %br
  %input(type='submit' value='Upload')
