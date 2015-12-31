require 'rails'
require 'active_record'
require 'second_base/version'
require 'second_base/railtie'
require 'second_base/forced'

module SecondBase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env = nil)
    config = ActiveRecord::Base.configurations[config_name]
    config ? config[env || Rails.env] : nil
  end

  def self.config_name
    'secondbase'
  end

end
