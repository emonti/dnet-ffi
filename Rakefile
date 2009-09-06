require 'rubygems'
require 'rake'

require 'rake/clean'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dnet-ffi"
    gem.summary = %Q{Ruby FFI bindings for libdnet}
    gem.description = %Q{Ruby FFI bindings for the libdnet raw network library}
    gem.email = "emonti@matasano.com"
    gem.homepage = "http://github.com/emonti/dnet-ffi"
    gem.authors = ["Eric Monti"]
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_development_dependency "yard"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
