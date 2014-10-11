require 'daybreak'
require 'fileutils'
require 'mini_exiftool'

def upload(upload_dir, filename, tempfile=nil)
  tempfile ||= filename
  db = Daybreak::DB.new 'chompy.db'
  md5 = Digest::MD5.hexdigest(File.read(tempfile))
  if not db.keys.include? md5
    outcome = { uploaded: false }
    begin
      fileinfo = { filename: filename, md5: md5 }
      fileinfo[:ext] = File.extname(filename).downcase
      # Parse exif data
      exif = MiniExiftool.new(tempfile)
      time = exif.date_time_original
      destpath = File.join(upload_dir, time.strftime("%Y/%m/"))
      destfn = time.strftime("%FT%H%M%S#{fileinfo[:ext]}")
      destination = File.join(destpath, destfn)
      fileinfo[:destination] = destination
      FileUtils.mkdir_p destpath if not File.directory? destpath
      #File.open(destination, 'w') do |f|
      #  f.write(params['file'][:tempfile].read)
      #end
      FileUtils.cp tempfile, destination
      #params['file'][:tempfile].unlink
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
  outcome
end

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
  result
end
