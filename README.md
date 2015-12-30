# SecondBase

SecondBase adds a second database to your application. While Rails enables you to establish connections to as many external databases as you like, Rails can only manage a single database with it's migration and testing tasks.

SecondBase enables Rails to work with, and manage, a second database. As a developer, you should not even realize a second database is in play. Core tasks such as `db:create`, `db:migrate`, and `test` will continue to work seamlessly with both databases.


## Usage

Configure your database.yml to define your SecondBase:

```yaml
# Your normal rails definitions...
development:
  adapter: mysql  #postgres, oracle, etc
  encoding: utf8
  database: development

test:
  adapter: mysql  #postgres, oracle, etc
  encoding: utf8
  database: test

# Your secondbase database configurations...
secondbase:
  development:
    adapter: mysql
    encoding: utf8
    database: secondbase_development

  test:
    adapter: mysql
    encoding: utf8
    database: secondbase_test
```

#### Migrations

SecondBase comes with a generator to assist in managing your migrations

```
$ rails generate secondbase:migration CreateWidgetsTable
```

The generator will organize your second database migrations alongside of your primary database. The above command will generate the file `db/secondbase/20151203211338_create_widgets_table.rb`

To run your migrations, simply run:

```
rake db:migrate
```

This will migrate your first and second databases. If, for some reason, you only want to migrate your second database, run:

```
rake db:migrate:secondbase
```

Please note that migrating up and migrating down must be done specifically on your first or second database. As usual, to migrate your first database up or down to version 20151203211338, you could run:

```
$ rake db:migrate:up VERSION=20151203211338
$ rake db:migrate:down VERSION=20151203211338
```

To migrate your second database up or down to version 20151203211338, you would run:

```
$ rake db:migrate:up:secondbase VERSION=20151203211338
$ rake db:migrate:down:secondbase VERSION=20151203211338
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

#### Tasks & Custom Classes

If you need to write rake tasks, or some other code that does not extend ActiveRecord, you can simply establish a connection to your second database:

```ruby
SecondBase::has_runner(Rails.env)
```

Please note that this is equivalent to using ActiveRecord::Base.establish_connection(config) and will reset the base connection of your ENTIRE application. No worries, to move the runner back to first you can use:

```ruby
FirstBase::has_runner(Rails.env)
```

#### Testing

Tests can still be run using `rake test` or `rake test:models`, etc. However, if you are using fixtures, you will need to update your TestHelper class to include:

```ruby
require 'secondbase/fixtures'
```

This is patch to fixtures that will identify the fixtures which belong to models that extend SecondBase::Base. The patch will then ensure that the table descendants of SecondBase::Base get loaded into your second test database.

At this time, I can verify that SecondBase works with Fixtures, Machinist and FactoryGirl. Conceivably, other test factories should work, but there is currently no support for this. If you have the time to update this gem to be test object compatible, by all means...


## TODO

* Migration generator in Rails 3.x needs support for attribute generation (similar to rails generate migration). For example:

```
$ rails generate secondbase:migration AddTitleBodyToPost title:string body:text published:boolean
```

Fix rake db:fixtures:load is currently broken. Like many other things I have fixed, it assumes you only one a single database and attempts to load all fixtures into it. I don't believe we can get away with alias chaining this one, I think (like the Fixtures class), we'll have to freedom patch it.
