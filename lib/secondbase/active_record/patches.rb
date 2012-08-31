####################
## ActiveRecord patches for all versions of rails
require 'secondbase/active_record/base'


####################
## ActiveRecord patches for specific versions of rails
if Rails.env.test?
  require 'secondbase/active_record/fixtures'
  require 'secondbase/active_record/test_fixtures' 
end

require 'secondbase/active_record/associations/has_and_belongs_to_many_association' 