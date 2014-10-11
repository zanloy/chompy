#!/usr/bin/env ruby

require 'haml'
require 'sinatra'
require_relative 'chompy'

set :bind, '0.0.0.0'

pic_dir = "/home/zan/images"
upload_dir = "uploads"

get('/'){ haml :index }
get('/stream', provides: 'text/event-stream') do
  stream do |out|
    start_time = Time.now
    cnt = { uploaded: 0, skipped: 0 }
    Dir[File.join(pic_dir, '*')].each do |file|
      out << "data: #{File.basename(file)}...\n\n"
      result = upload(upload_dir, file)
      if result[:uploaded]
        cnt[:uploaded] += 1
        out << "data: [<span class='green'>uploaded</span>]<br>\n\n"
      else
        cnt[:skipped] += 1
        out << "data: [<span class='red'>skipped</span>]<br>\n\n"
      end
    end
    end_time = Time.now
    elapsed_time = end_time - start_time
    out << "data: Uploaded: #{cnt[:uploaded]}, Skipped: #{cnt[:skipped]}, Elapsed: #{elapsed_time}s\n\n"
    out << "event: close\n"
    out << "data: close\n\n"
  end
end

__END__

@@ index
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
    %input#btnStream(type="button" value="Start!")
    #stream
