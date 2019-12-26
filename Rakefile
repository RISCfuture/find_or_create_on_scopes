require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  gem.name = 'find_or_create_on_scopes'
  gem.summary = %(find_or_create-type methods on ActiveRecord scopes)
  gem.description = %(Adds methods to ActiveRecord for conditionally finding, creating, or updating records.)
  gem.email = 'git@timothymorgan.info'
  gem.homepage = 'http://github.com/riscfuture/find_or_create_on_scopes'
  gem.authors = ["Tim Morgan"]
  gem.required_ruby_version = '>= 1.9'
  gem.files = %w[lib/**/* README.md LICENSE find_or_create_on_scopes.gemspec]
end
Juwelier::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'yard'

# bring sexy back (sexy == tables)
module YARD::Templates::Helpers::HtmlHelper
  def html_markup_markdown(text)
    markup_class(:markdown).new(text, :gh_blockcode, :fenced_code, :autolink, :tables, :no_intraemphasis).to_html
  end
end

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << '-m' << 'markdown'
  doc.options << '-M' << 'redcarpet'
  doc.options << '--protected' << '--no-private'
  doc.options << '-r' << 'README.md'
  doc.options << '-o' << 'doc'
  doc.options << '--title' << 'find_or_create_on_scopes Documentation'

  doc.files = %w[lib/**/* README.md]
end

task(default: :spec)
