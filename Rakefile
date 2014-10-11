task :clean do
  File.unlink('app/chompy.db') if File.exists? 'app/chompy.db'
  FileUtils.rm_rf(Dir['app/uploads/*'])
end

task :compact do
  if File.exists? 'app/chompy.db'
    require 'daybreak'
    db = Daybreak::DB.new('app/chompy.db')
    db.compact
    db.close
    puts "Database file compacted."
  else
    puts "Database file does not exist."
  end
end

task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
