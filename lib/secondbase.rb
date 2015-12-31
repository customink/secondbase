require 'rails'
require 'active_record'
require 'secondbase/version'
require 'secondbase/railtie'
require 'secondbase/forced'

module SecondBase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env)
    config = ActiveRecord::Base.configurations[config_name]
    config ? config[env] : nil
  end

  def self.config_name
    'secondbase'
  end

end
