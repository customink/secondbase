require 'rails'
require 'active_record'
require 'active_record/railtie'
require 'third_base/version'
require 'third_base/railtie'
require 'third_base/on_base'
require 'third_base/forced'

module ThirdBase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env = nil)
    config = Rails.application.config.database_configuration[Railtie.config_key]
    config ? config[env || Rails.env] : nil
  end

end
