# CHANGELOG

## 0.6

 * This version of the gem ONLY SUPPORTS Rails 3.x.  For 2.x support, check out the branch 'rails_2_3' (or version .5 of the gem)
 * patched has_and_belongs_to_many associations, for secondbase models, so that ActiveRecord understands that the join table is in the secondbase.
 * patched ActiveRecord::TestFixtures so that transactional fixture support is respected for the SecondBase.
 * reorganized monkey patches to make it easier to work in fixes for different versions of rails.