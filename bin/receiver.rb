#!/usr/bin/env ruby

require 'daybreak'
require 'fileutils'
require 'haml'
require 'json'
require 'mini_exiftool'
require 'sinatra'

root_dir = 'uploads'

set :bind, '0.0.0.0'

# Helper functions
def check_hash (md5)
  md5 = md5.downcase
  db = Daybreak::DB.new 'chompy.db'
  present = db.keys.include? md5
  if present
    result = { uploaded: true, fileinfo: db[md5] }
  else
    result = { uploaded: false }
  end
  db.close
  return result
end

# Sinatra routes
get '/check' do
  haml :check
end

post '/check' do
  JSON.generate(check_hash(params['md5']))
end

get '/check/:hash' do |hash|
  JSON.generate(check_hash(hash))
end

get '/upload' do
  haml :upload
end

post '/upload' do
  # Validate input
  return "Error: File not in params." if not params['file']
  # Validate it is an image
  #return "Error: Filetype is not image/* (#{params['file'][:type]})" if not params['file'][:type] =~ /^image\//
  # Process
  db = Daybreak::DB.new 'chompy.db'
  md5 = Digest::MD5.hexdigest(File.read(params['file'][:tempfile]))
  if not db.keys.include? md5
    outcome = { uploaded: false }
    begin
      fileinfo = { filename: params['file'][:filename], md5: md5 }
      fileinfo[:ext] = File.extname(params['file'][:filename]).downcase
      # Parse exif data
      exif = MiniExiftool.new(params['file'][:tempfile].path)
      time = exif.date_time_original
      destpath = File.join(root_dir, time.strftime("%Y/%m/"))
      destfn = time.strftime("%FT%H%M%S#{fileinfo[:ext]}")
      destination = File.join(destpath, destfn)
      fileinfo[:destination] = destination
      FileUtils.mkdir_p destpath if not File.directory? destpath
      File.open(destination, 'w') do |f|
        f.write(params['file'][:tempfile].read)
      end
      params['file'][:tempfile].unlink
      fileinfo[:upload_date] = Time.now
      db.set! md5, fileinfo
      outcome[:fileinfo] = fileinfo
      outcome[:uploaded] = true
    ensure
      db.close
    end
  else
    outcome = { uploaded: false, fileinfo: db[md5] }
    db.close
  end
  JSON.generate outcome
end

__END__
@@check
!!! 5
%html
  %body
    %h1 Validate File
    %form(method="post")
      %label MD5:
      %input(name="md5")
      %br
      %input(type="submit" value="Check")

@@upload
!!! 5
%html
  %body
    %h1 Upload File
    %form(method='post' enctype='multipart/form-data')
      %label File:
      %input(type='file' name='file')
      %br
      %input(type='submit' value='Upload')
