# SecondBase

[![Gem Version](https://badge.fury.io/rb/secondbase.png)](http://badge.fury.io/rb/secondbase)
[![Build Status](https://secure.travis-ci.org/customink/secondbase.png)](http://travis-ci.org/customink/secondbase)

SecondBase adds a second database to your application. While Rails enables you to establish connections to as many external databases as you like, Rails can only manage a single database with it's migration and testing tasks.

SecondBase enables Rails to work with, and manage, a second database. As a developer, you should not even realize a second database is in play. Core tasks such as `db:create`, `db:migrate`, and `test` will continue to work seamlessly with both databases.


## Usage

Customize your database.yml to include a `secondbase` config key. All SecondBase configurations per Rails environment for your second database will go under this config key.

```yaml
# Default configurations:
development:
  adapter: sqlserver
  database: myapp_development
test:
  adapter: sqlserver
  database: myapp_test
# SecondBase configurations:
secondbase:
  development:
    adapter: mysql
    database: myapp_development
  test:
    adapter: mysql
    database: myapp_test
```

#### Database Tasks

SecondBase wants to work seamlessly within your Rails application. When it makes sense, we run a mirrored `db:second_base` task for you when you run a standard ActiveRecord base database task. For example:

```shell
$ rake db:create
```

This will not only create your base development database, but it will also create your second development database as specified by the configuration within the `secondbase` section of your database.yml. Here is a full list of `db:...` tasks that automatically run a mirrored `db:second_base:...` task. Some private tasks, like schema/structure dump and loading, are not listed.

* db:create
* db:drop
* db:migrate
* db:test:purge

Here is a list of supported SecondBase database tasks that have to be run explicitly. These tasks only operate on your SecondBase database. All support every feature that their root `db` counterparts do. For example, using `VERSION=123` to target a specific migration.

* db:second_base:migrate:up
* db:second_base:migrate:down
* db:second_base:migrate:reset
* db:second_base:migrate:redo
* db:second_base:migrate:status
* db:second_base:rollback
* db:second_base:forward

#### Migration Generator

SecondBase migrations are stored in your application's `db/secondbase/migrate` directory. Likewise, SecondBase will also dump your schema/structure file into the `db/secondbase` directory. Full support for ActiveRecord's schema format being set to either `:ruby` or `:sql` is supported.

Migrations can be generated using the `second_base:migration` name. Our generator is a subclass of ActiveRecord's. This means that SecondBase migration generator supports whatever features and arguments is supported by your current Rails version. For example:

```shell
$ rails generate second_base:migration CreateWidgetsTable
$ rails generate second_base:migration AddTitleBodyToPost title:string body:text published:boolean
```

#### Models

Every model in your project that extends ActiveRecord::Base will point to the database defined by Rails.env. This is the default Rails behavior and should be of no surprise to you. So how do we point our models to the second database? SecondBase offers a base model that you can simply extend:

```ruby
require 'secondbase/model'

class Widget < SecondBase::Base

end
```

You're Widget model is now pointing to your second database table 'widgets'. ActiveRecord associations will still work between your Firstbase and SecondBase models!

```ruby
class User < ActiveRecord::Base
  has_many :widgets
end
```

#### Forced Connections

Sometimes you want to force a model that inherits from `ActiveRecord::Base` to use the `SecondBase::Base` connection. Using the `SecondBase::Forced` module is a great way to accomplish this. By using this module, we do all the work to ensure the connection, management, and pool are properly freedom patched.

We recomend forcing modules using a Rails initializer. This example forces both the [DelayedJob ActiveRecord Backend](https://github.com/collectiveidea/delayed_job_active_record) and ActiveRecord session store to use your second DB connection.

```ruby
# In config/initializers/second_base.rb
Delayed::Backend::ActiveRecord::Job.extend SecondBase::Forced
ActiveRecord::SessionStore::Session.extend SecondBase::Forced
```

#### Configurations

All SecondBase railtie settings are best done in a `config/initializers/secondbase.rb` file. We support the following configurations:

```ruby
config.second_base.path        # Default: 'db/secondbase'
config.second_base.config_key  # Default: 'secondbase'
```

* `path` - Used as location for migrations & schema. Path is relative to application root.
* `config_key` - The key to in database.yml/configurations to search for SecondBase configs.


## Versions

The current master branch is for Rails v4.0.0 and up and. We have older work in previous v1.0 releases which partial work for Rails 3.2 or lower. These old versions are feature incomplete and are not supported.


## Contributing

We use the [Appraisal](https://github.com/thoughtbot/appraisal) gem from Thoughtbot to help us test different versions of Rails. The `rake appraisal test` command actually runs our test suite against all Rails versions in our `Appraisal` file. So after cloning the repo, running the following commands.

```shell
$ bundle install
$ bundle exec appraisal update
$ bundle exec appraisal rake test
```

If you want to run the tests for a specific Rails version, use one of the appraisal names found in our `Appraisals` file. For example, the following will run our tests suite for Rails 4.1.x.

```shell
$ bundle exec appraisal rails41 rake test
```

