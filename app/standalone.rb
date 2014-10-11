#!/usr/bin/env ruby

require 'haml'
require 'sinatra'
require_relative 'chompy'

set :bind, '0.0.0.0'

pic_dir = "/home/zan/images"
upload_dir = "uploads"

get('/'){ haml :index }
get('/stream', provides: 'text/event-stream') do
  db = Daybreak::DB.new 'chompy.db'
  stream do |out|
    #3.times do |num|
    #  out << "data: Number: #{num}.\n\n"
    #  sleep(1)
    #end
    Dir[File.join(pic_dir, '*')].each do |file|
      out << "data: #{File.basename(file)}...\n\n"
      result = upload(upload_dir, file)
      if result[:uploaded]
        out << "data: [<span class='green'>uploaded</span>]<br>\n\n"
      else
        out << "data: [<span class='red'>skipped</span>]<br>\n\n"
      end
    end
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
    %meta(charset="utf-8")
    %script(src="http://rightjs.org/hotlink/right.js")
    %script(src="/chompy.js")
    :css
      .red {color: red}
      .green {color: green}
  %body
    %h1 Chompy
    %input#btnStream(type="button" value="Start!")
    #stream
