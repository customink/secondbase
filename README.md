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

#### Migrations

SecondBase migrations are stored in your application's `db/secondbase/migrate` directory. Likewise, SecondBase will also dump your schema/structure into a distinct file within `db/secondbase`. Full support for ActiveRecord's schema format being set to either `:ruby` or `:sql`.

Migrations can be generated using the `second_base:migration` name. Our generator is built on top of the core ActiveRecord one. This means that SecondBase migrations support whatever arguments is supported by your current Rails version. For example:

```shell
$ rails generate second_base:migration CreateWidgetsTable
$ rails generate second_base:migration AddTitleBodyToPost title:string body:text published:boolean
```

To run both your application's base and SecondBase migrations, simply run:

```shell
$ rake db:migrate
```

If, you only want to migrate your SecondBase database, run:

```shell
$ rake db:second_base:migrate
```

Please note that migrating up and migrating down must be done specifically on your first or second database. As usual, to migrate your first database up or down to version 20151203211338, you could run:

```shell
$ rake db:migrate:up VERSION=20151203211338
$ rake db:migrate:down VERSION=20151203211338
```

To migrate your second database up or down to version 20151203211338, you would run:

```shell
$ rake db:second_base:migrate:up VERSION=20151203211338
$ rake db:second_base:migrate:down:secondbase VERSION=20151203211338
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

