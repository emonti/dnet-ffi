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
    gem.add_development_dependency "rspec"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_opts = ['--colour', '--format', 'nested']
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec


begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

require 'rake/rdoctask' 
Rake::RDocTask.new do |rdoc| 
  if File.exist?('VERSION') 
    version = File.read('VERSION') 
  else 
    version = "" 
  end 
 
  rdoc.rdoc_dir = 'rdoc' 
  rdoc.title = "dnet-ffi #{version}" 
  rdoc.rdoc_files.include('README*') 
  rdoc.rdoc_files.include('lib/**/*.rb') 
end

