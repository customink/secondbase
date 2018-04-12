class FeedForced < ActiveRecord::Base
  self.table_name = 'feeds'
  belongs_to :user
end

FeedForced.extend ThirdBase::Forced
