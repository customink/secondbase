require 'test_helper'

class GeneratorTest < SecondBase::TestCase

  teardown do
    generated_migration_delete
    generated_migration_base_delete
  end

  def test_initialization_via_help
    output = Dir.chdir(dummy_root) { `rails g -h` }
    assert_match(/second_base\:migration/, output)
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

  def test_base_migration_generator
    output = Dir.chdir(dummy_root) { `rails g migration AddBaseColumn` }
    assert_match %r{create.*db/migrate/.*add_base_column\.rb}, output
    migration = generated_migration_base_data
    assert_match %r{class AddBaseColumn}, migration
    assert_match %r{def change}, migration
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

  def generated_migration_base
    Dir["#{dummy_db}/migrate/*add_base*.{rb}"].first
  end

  def generated_migration_base_data
    generated_migration_base ? File.read(generated_migration_base) : ''
  end

  def generated_migration_base_delete
    FileUtils.rm_rf(generated_migration_base) if generated_migration_base
  end

end
