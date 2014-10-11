#!/usr/bin/env ruby

require 'haml'
require 'json'
require 'sinatra'
require_relative 'chompy'

upload_dir = 'uploads'

set :bind, '0.0.0.0'

# Sinatra routes
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
  result = upload(upload_dir, params['file'][:filename], params['file'][:tempfile].path)
  JSON.generate result
end

__END__
@@ check
!!! 5
%html
  %body
    %h1 Check File
    %form(method="post")
      %label MD5:
      %input(name="md5")
      %br
      %input(type="submit" value="Check")

@@ upload
!!! 5
%html
  %body
    %h1 Upload File
    %form(method='post' enctype='multipart/form-data')
      %label File:
      %input(type='file' name='file')
      %br
      %input(type='submit' value='Upload')
