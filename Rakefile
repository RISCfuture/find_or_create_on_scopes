require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "find_or_create_on_scopes"
  gem.summary = %Q{find_or_create-type methods on ActiveRecord scopes}
  gem.description = %Q{Adds methods to ActiveRecord for conditionally finding, creating, or updating records.}
  gem.email = "git@timothymorgan.info"
  gem.homepage = "http://github.com/riscfuture/find_or_create_on_scopes"
  gem.authors = [ "Tim Morgan" ]
  gem.required_ruby_version = '>= 1.9'
  gem.add_dependency "activerecord", ">= 0"
  gem.files = %w( lib/**/* README.textile LICENSE find_or_create_on_scopes.gemspec )
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << "-m" << "textile"
  doc.options << "--protected"
  doc.options << "-r" << "README.textile"
  doc.options << "-o" << "doc"
  doc.options << "--title" << "find_or_create_on_scopes Documentation"
  
  doc.files = [ 'lib/**/*', 'README.textile' ]
end

task(default: :spec)
