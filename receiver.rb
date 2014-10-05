#!/usr/bin/env ruby

require 'daybreak'
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
    result = { uploaded: true, filename: db[md5][:filename], upload_date: db[md5][:upload_date] }
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
  db = Daybreak::DB.new 'chompy.db'
  md5 = Digest::MD5.hexdigest(File.read(params['file'][:tempfile]))
  if not db.keys.include? md5
    File.open(File.join(root_dir, params['file'][:filename]), 'w') do |f|
      f.write(params['file'][:tempfile].read)
    end
    db.set! md5, { filename: params['file'][:filename], upload_date: Time.now }
    outcome = "Uploaded."
  else
    outcome = "File already uploaded on #{db[md5][:upload_date].strftime('%F %r')} with filename #{db[md5][:filename]}."
  end
  db.close
  outcome
end
