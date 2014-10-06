task :clean do
  File.unlink('chompy.db') if File.exists? 'chompy.db'
  FileUtils.rm_rf(Dir['./uploads/*'])
end

task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
