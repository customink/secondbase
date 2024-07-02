module SecondBase
  module RailsVersionHelpers

    extend ActiveSupport::Concern

    included { extend RailsVersionHelpers }

    private

    def formatVersionDate(version_date, delimiter = '')
      year = version_date[0,4]
      month = version_date[4,2]
      day = version_date[6,2]
      rest = version_date[8, version_date.length]
      [year, month, day, rest].join(delimiter)
    end

    def rails_version
      Rails.version.to(2)
    end

    ['4.0', '4.1', '4.2', '5.0', '5.1', '5.2'].each do |v|

      vm = v.sub '.', ''

      define_method :"rails_#{vm}?" do
        rails_version == v
      end

      define_method :"rails_#{vm}_up?" do
        rails_version >= v
      end

    end

    def schemaVersionByRailsVersion(version_date)
      rails_52_up? ? formatVersionDate(version_date, "_") : version_date
    end

  end
end
