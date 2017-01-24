
![SecondBase Logo](https://cloud.githubusercontent.com/assets/2381/12219457/5a5aab4e-b712-11e5-92e1-de6487aa0809.png)
<hr>
Seamless second database integration for Rails. SecondBase provides support for Rails to manage dual databases by extending ActiveRecord tasks that create, migrate, and test your databases.

* [Using SecondBase To Provide Some Level Of Sanity](http://technology.customink.com/blog/2016/01/10/two-headed-cat-using-secondbase-to-provide-some-level-of-sanity-in-a-two-database-rails-application/)
* [Rails Multi-Database Best Practices Roundup](http://technology.customink.com/blog/2015/06/22/rails-multi-database-best-practices-roundup/)

[![Gem Version](https://badge.fury.io/rb/secondbase.png)](http://badge.fury.io/rb/secondbase)
[![Build Status](https://travis-ci.org/customink/secondbase.svg?branch=master)](https://travis-ci.org/customink/secondbase)


## Usage

To get started with your new second database, update your database.yml to include a `secondbase` config key. All SecondBase configurations per Rails environment go under this config key.

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

SecondBase aims to work seamlessly within your Rails application. When it makes sense, we run a mirrored `db:second_base` task for matching ActiveRecord base database task. These can all be deactivated by setting `config.second_base.run_with_db_tasks = false` in your Application's configuration. For example:

```shell
$ rake db:create
```

This will not only create your base development database, but it will also create your second database as specified by the configuration within the `:secondbase` section of your database.yml. Below is a complete list of `:db` tasks that automatically run a mirrored `:db:second_base` task. Some private or over lapping tasks, like schema dump/loading or `db:setup`, are not listed.

* db:create
* db:create:all
* db:drop
* db:drop:all
* db:purge
* db:purge:all
* db:migrate
* db:test:purge
* db:test:prepare
* db:schema:cache:dump

Not all base database tasks make sense to run a mirrored SecondBase task. These include tasks that move a single migration up/down, reporting on your database's current status/version, and others. These tasks have to be run explicitly and only operate on your SecondBase database. Each support any feature that their matching `:db` task has. For example, using `VERSION=123` to target a specific migration.

* db:second_base:migrate:up
* db:second_base:migrate:down
* db:second_base:migrate:reset
* db:second_base:migrate:redo
* db:second_base:migrate:status
* db:second_base:rollback
* db:second_base:forward
* db:second_base:version

#### Migration Generator

SecondBase migrations are stored in your application's `db/secondbase/migrate` directory. Likewise, SecondBase will also dump your schema/structure file into the `db/secondbase` directory. Full support for ActiveRecord's schema format being set to either `:ruby` or `:sql` is supported.

Migrations can be generated using the `second_base:migration` name. Our generator is a subclass of ActiveRecord's. This means the SecondBase migration generator supports whatever features and arguments are supported by your current Rails version. For example:

```shell
$ rails generate second_base:migration CreateWidgetsTable
$ rails generate second_base:migration AddTitleBodyToPost title:string body:text
```

#### Models

Any model who's table resides in your second database needs to inherit from `SecondBase::Base`. ActiveRecord associations will still work between your base ActiveRecord and SecondBase models!

```ruby
class Widget < SecondBase::Base

end

class User < ActiveRecord::Base
  has_many :widgets
end
```

#### Forced Connections

Sometimes you want to force a model that inherits from `ActiveRecord::Base` to use the `SecondBase::Base` connection. Using the `SecondBase::Forced` module is a great way to accomplish this. By using this module, we do all the work to ensure the connection, management, and pool are properly freedom patched.

We recomend forcing modules using a Rails initializer. This example below forces both the [DelayedJob ActiveRecord Backend](https://github.com/collectiveidea/delayed_job_active_record) and ActiveRecord session store to use your SecondBase database.

```ruby
# In config/initializers/second_base.rb
Delayed::Backend::ActiveRecord::Job.extend SecondBase::Forced
ActiveRecord::SessionStore::Session.extend SecondBase::Forced
```

#### Testing & DB Synchronization

Rails 4.2 brought about a new way to keep your test database in sync by checking schema migrations. Where previously forcing a full test database schema load, Rails 4.2 and up is able to run your tests much faster. In order for SecondBase to take advantage of this, you will need to include our test help file directly following the Rails one. Open your `test_helper.rb` and add our `second_base/test_help` after `rails/test_help`.

```ruby
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'second_base/test_help'
```

#### Configurations

All SecondBase railtie settings are best done in a `config/application.rb` file. We support the following configurations:

```ruby
config.second_base.path        # Default: 'db/secondbase'
config.second_base.config_key  # Default: 'secondbase'
```

* `path` - Used as location for migrations & schema. Path is relative to application root.
* `config_key` - The key to in database.yml/configurations to search for SecondBase configs.


## Advanced Usage

#### Twelve-Factor & DATABASE_URL

We love the [Twelve Factors](http://12factor.net) principals and using tools like Dotenv with Rails. Using SecondBase does not mean you have to abandon these best practices. You will however need to take advantage of a [new feature](https://github.com/rails/rails/pull/14633) in Rails 4.1 and upward that allows database.yml configurations to leverage a `:url` key that will resolve and merge the same connection string format consumed by `DATABASE_URL`. For example: 

```yaml
development:
  database: encom-pg_development
  url: <%= ENV.fetch('DATABASE_URL') %>
test:
  database: encom-pg_test
  url: <%= ENV.fetch('DATABASE_URL') %>
production:
  url: <%= ENV.fetch('DATABASE_URL') %>

secondbase:
  development:
    database: encom-mysql_development
    url: <%= ENV.fetch('DATABASE_URL_SECONDBASE') %>
  test:
    database: encom-mysql_test
    url: <%= ENV.fetch('DATABASE_URL_SECONDBASE') %>
  production:
    url: <%= ENV.fetch('DATABASE_URL_SECONDBASE') %>
```

There are many ways to use Dotenv and enviornment variables. This is only one example and we hope it helps you decide on which is best for you.

#### The ActiveRecord Query Cache

Rails only knows about your base connection for the Rack-based query cache. In order to take advantage of this feature for your SecondBase, you will need to set an arround filter in your controller.

```ruby
class ApplicationController < ActionController::Base
  around_filter :query_cache_secondBase
  private
  def query_cache_secondBase
    SecondBase::Base.connection.cache { yield }
  end
end
```

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

