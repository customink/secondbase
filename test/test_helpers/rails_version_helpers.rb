module SecondBase
  module RailsVersionHelpers

    extend ActiveSupport::Concern

    included { extend RailsVersionHelpers }

    private

    def rails_version
      Rails.version.to(2)
    end

    ['4.0', '4.1', '4.2', '5.0', '5.1'].each do |v|

      vm = v.sub '.', ''

      define_method :"rails_#{vm}?" do
        rails_version == v
      end

      define_method :"rails_#{vm}_up?" do
        rails_version >= v
      end

    end

  end
end
