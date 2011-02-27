begin
  require 'rdoctest/task'

  Rdoctest::Task.new do |t|
    t.ruby_opts << '-rscantron -rrange_scanner'
  end

  task :default => :doctest
rescue LoadError
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

task :default => :test
