task :clean do
  File.unlink('chompy.db') if File.exists? 'chompy.db'
  FileUtils.rm_rf(Dir['./uploads/*'])
end

task :compact do
  if File.exists? 'chompy.db'
    require 'daybreak'
    db = Daybreak::DB.new('chompy.db')
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
