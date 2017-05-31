ENV['RAILS_ENV'] ||= 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)
require 'bundler/setup'
require 'rails/all'
Bundler.require(:default, Rails.env)

module Dummy
  class Application < ::Rails::Application

    # Basic Engine
    config.root = File.join __FILE__, '..'
    config.cache_store = :memory_store
    config.assets.enabled = false
    config.secret_token = '012345678901234567890123456789'
    config.active_support.test_order = :random

    # Mimic Test Environment Config.
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.action_controller.allow_forgery_protection = false
    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
    config.allow_concurrency = true
    config.cache_classes = true
    config.dependency_loading = true
    config.preload_frameworks = true
    config.eager_load = true
    config.secret_key_base = '012345678901234567890123456789'

    # Keep pending test:prepare via pending migrations from running.
    config.active_record.maintain_test_schema = false if ActiveRecord::Base.respond_to?(:maintain_test_schema)

    config.active_record.schema_format = (ENV['SCHEMA_FORMAT'] || :ruby).to_sym

    if ENV['WITH_SECONDBASE_TASKS'].present?
      config.second_base.run_with_db_tasks = ENV['WITH_SECONDBASE_TASKS'] == 'true'
    end
  end
end

Dummy::Application.initialize!
