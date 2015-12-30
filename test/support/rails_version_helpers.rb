module SecondBase
  module RailsVersionHelpers

    extend ActiveSupport::Concern

    included { extend RailsVersionHelpers }

    private

    def rails_40?
      Rails.version =~ /4\.0\.\d/
    end

    def rails_41?
      Rails.version =~ /4\.1\.\d/
    end

    def rails_42?
      Rails.version =~ /4\.2\.\d/
    end

  end
end
