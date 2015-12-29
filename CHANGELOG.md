
# Change Log

Please follow the format set down in http://keepachangelog.com


## v1.0

Initial re-write supporting Rails 4.x. Please see README.md for full details.


## v0.6

Support for Rails 3.x. For 2.x support, check out the branch `rails_2_3` or version v0.5 of the gem.

#### Fixed

 * The `has_and_belongs_to_many` associations, for secondbase models.
 * Patched `ActiveRecord::TestFixtures` so that transactional fixture support is respected for the SecondBase.
 * Reorganized monkey patches to make it easier to work in fixes for different versions of Rails.
