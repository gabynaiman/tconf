require 'bundler/gem_tasks'

desc 'Pry console'
task :console do
  require 'tconf'
  include Tconf
  require 'pry'
  ARGV.clear
  Pry.start
end
