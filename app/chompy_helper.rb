require 'daybreak'
require 'fileutils'
require 'mini_exiftool'

def upload(dav, filename, tempfile=nil)
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
      destpath = time.strftime("%Y/%m/")
      destfn = time.strftime("%FT%H%M%S#{fileinfo[:ext]}")
      destination = destpath + destfn
      fileinfo[:destination] = destination
      #FileUtils.mkdir_p destpath if not File.directory? destpath
      if not dav.exists?(destpath)
        stack = []
        until destpath == stack.last
          stack.push destpath
          destpath = File.dirname(destpath)
        end
        stack.pop # Remove '.' from the end because we can't create
        stack.reverse_each do |dir|
          begin
            dav.mkdir(dir)
          rescue
            raise unless dav.exists?(dir)
          end
        end
      end
      File.open(tempfile, 'rb') do |stream|
        dav.put(destination, stream, File.size(tempfile))
      end
      #FileUtils.cp tempfile, destination
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
