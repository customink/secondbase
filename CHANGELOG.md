# Change Log

Please follow the format set down in http://keepachangelog.com

## v2.2.0

- Added `structure:dump` task. Thanks @shqear93

## v2.1.6

- Descriptions for Rake tasks. Fixes #60. Thanks @roolo.

## v2.1.5

- Allow custom db paths to work. Fixes #51 #52. Thanks @MrJoy.

## v2.1.4

- Rails v5.1 support.

## v2.1.3

#### Fixed

- Issue with explicit secondbase tasks not loading config. Fixes #43

## v2.1.2

#### Changed

- Tested w Rails 5.0 release.

#### Added

- Support for schema cache. Fixes #40

## v2.1.1

#### Changed

- Test updates to track rails 5 rc2.

## v2.1.0

#### Added

- Ability to disable the database task patching (thanks [@agrberg](https://github.com/agrberg))

## v2.0.0

#### Added

- Rails 5 support.

## v1.0.1

#### Fixed

- Fix base Rails migration generator. Fixes #25.

## v1.0

Initial re-write supporting Rails 4.x. Please see README.md for full details.

## v0.6

Support for Rails 3.x. For 2.x support, check out the branch `rails_2_3` or version v0.5 of the gem.

#### Fixed

- The `has_and_belongs_to_many` associations, for SecondBase models.
- Patched `ActiveRecord::TestFixtures` so that transactional fixture support is respected for the SecondBase.
- Reorganized monkey patches to make it easier to work in fixes for different versions of Rails.
