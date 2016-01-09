require 'test_helper'

class GeneratorTest < SecondBase::TestCase

  teardown { generated_migration_delete }

  def test_initialization_via_help
    output = Dir.chdir(dummy_root) { `rails g -h` }
    assert_match /second_base\:migration/, output
  end

  def test_description_uses_rails_base
    output = Dir.chdir(dummy_root) { `rails g second_base:migration -h` }
    assert_match %r{db/migrate/20080514090912_add_ssl_flag\.rb}, output
  end

  def test_migration
    output = Dir.chdir(dummy_root) { `rails g second_base:migration CreateFavorites post_id:integer count:integer` }
    assert_match %r{create.*db/secondbase/migrate/.*create_favorites\.rb}, output
    migration = generated_migration_data
    assert_match %r{create_table :favorites}, migration
    assert_match %r{t.integer :post_id}, migration
    assert_match %r{t.integer :count}, migration
  end


  private

  def generated_migration
    Dir["#{dummy_db}/secondbase/migrate/*favorites.{rb}"].first
  end

  def generated_migration_data
    generated_migration ? File.read(generated_migration) : ''
  end

  def generated_migration_delete
    FileUtils.rm_rf(generated_migration) if generated_migration
  end

end
