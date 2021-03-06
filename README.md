find_or_create_on_scopes
========================

**Conditional creators for ActiveRecord**

|             |                                 |
|:------------|:--------------------------------|
| **Author**  | Tim Morgan                      |
| **Version** | 1.2 (Sep 12, 2011)              |
| **License** | Released under the MIT license. |

About
-----

`find_or_create_on_scopes` adds handy `find_or_create`-type methods to
`ActiveRecord`. You can use these methods to conditionally create, initialize,
or update records depending on the presence of similar records. They work on
your base model class and any scopes derived therefrom. (See _Usage_ for
examples.)

Installation
------------

**Important Note:** This gem requires Ruby 1.9+. Ruby 1.8 is not and will never
be supported.

To install, simply add the `find_or_create_on_scopes` gem to your Rails
application's `Gemfile`:

```` ruby
gem 'find_or_create_on_scopes'
````

Usage
-----

See the {FindOrCreateOnScopes} module documentation for the complete list of
conditional creators/updaters. Some basic examples to give you an overview:

```` ruby
# Tries to find a user named 'riscfuture'. If such a User exists, returns it. If
# not, creates a user and sets its password to '123'.
User.where(login: 'riscfuture').find_or_create(password: '123')

# Tries to find a user named 'riscfuture'. If such a User exists, updates its
# password to '123'. If not, creates a new user and sets its password to '123'.
# Raises an exception if validation fails.
User.where(login: 'riscfuture').create_or_update!(password: '123')
````
