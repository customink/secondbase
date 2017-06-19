require 'rails'
require 'active_record'
require 'active_record/railtie'
require 'second_base/version'
require 'second_base/railtie'
require 'second_base/on_base'
require 'second_base/forced'

module SecondBase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env = nil)
    config = Rails.application.config.database_configuration[Railtie.config_key]
    config ? config[env || Rails.env] : nil
  end

end
