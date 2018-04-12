class FeedForced < ApplicationRecord
  self.table_name = 'feeds'
  belongs_to :user
end

FeedForced.extend ThirdBase::Forced
