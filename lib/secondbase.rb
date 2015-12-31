require 'rails'
require 'active_record'
require 'secondbase/version'
require 'secondbase/railtie'
require 'secondbase/forced'

module SecondBase

  extend ActiveSupport::Autoload

  autoload :Base, 'secondbase/base'

  def self.config(env = nil)
    config = ActiveRecord::Base.configurations[config_name]
    config ? config[env || Rails.env] : nil
  end

  def self.config_name
    'secondbase'
  end

end
