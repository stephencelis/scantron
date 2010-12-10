require 'rake/testtask'
require 'rdoctest/task'

Rdoctest::Task.new do |t|
  t.ruby_opts << '-rscantron -rrange_scanner'
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

task :default => [:doctest, :test]
