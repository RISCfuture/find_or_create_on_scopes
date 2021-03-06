require 'bundler'
Bundler.require :default, :development
require 'active_support/core_ext/module/delegation'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'find_or_create_on_scopes'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite'
)

class Option < ActiveRecord::Base
  attr_accessor :field
end

RSpec.configure do |config|
  config.before(:each) do
    Option.connection.execute "DROP TABLE IF EXISTS options"
    Option.connection.execute "CREATE TABLE options (id INTEGER PRIMARY KEY ASC, name VARCHAR(127) NOT NULL, value VARCHAR(255), uniq VARCHAR(127))"
    Option.connection.execute "CREATE UNIQUE INDEX IF NOT EXISTS options_unique ON options(uniq)"
  end
end
