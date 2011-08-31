require 'rake'
begin
  require 'bundler'
rescue LoadError
  puts "Bundler is not installed; install with `gem install bundler`."
  exit 1
end

Bundler.require :default, :development

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
Jeweler::GemcutterTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << "-m" << "textile"
  doc.options << "--protected"
  doc.options << "-r" << "README.textile"
  doc.options << "-o" << "doc"
  doc.options << "--title" << "find_or_create_on_scopes Documentation"
  
  doc.files = [ 'lib/**/*', 'README.textile' ]
end

task(default: :spec)
