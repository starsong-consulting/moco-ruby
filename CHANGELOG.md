# # Changelog

## [Unreleased]

## [1.0.0] - 2025-10-08

### Fixed
- Fixed Project `leader` and `co_leader` associations to return User objects instead of Hashes
- Fixed Expense associations to use proper `association()` method for embedded objects
- Fixed nested resource proxy caching issue - tasks and expenses now always return fresh data
- Fixed `NestedCollectionProxy` path construction for expenses (was double-prefixing with "projects/")
- Fixed `entity_path` warnings by converting instance methods to class methods in Holiday and WebHook classes
- Fixed embedded entity conversion for leader, co_leader, and user associations in BaseEntity

### Added
- Added comprehensive test suite using test-unit framework:
  - `test/test_comprehensive.rb` - 27 integration tests covering all CRUD operations
  - `test/test_holidays_expenses.rb` - 9 tests for holidays and expenses (nested resources)
  - `test/test_v2_api.rb` - 4 unit tests with mocked API responses
  - `test/test_helper.rb` - Shared test configuration
- Added `Project#expenses` method for nested expense access
- Added proper entity type mappings for `:leader`, `:co_leader`, and `:user` in BaseEntity
- Added dotenv gem as development dependency for test environment configuration

### Changed
- Moved all `require_relative` statements out of methods and into file-level requires
- Improved load order in `lib/moco.rb` - core classes now load before entities
- Updated `Expense` entity to use `association()` method for project and user relationships
- Refactored nested resource access in Project class to return fresh proxies instead of cached ones
- Enhanced `NestedCollectionProxy` to properly handle nested resource paths without double-prefixing

### Removed
- Removed manual test scripts (converted to proper test-unit tests)

## [1.0.0.beta] - 2025-04-10

### Fixed
- Fixed activity synchronization to properly identify existing activities in target system
- Added remote_id accessor to Activity class to prevent duplicate activity creation

## [1.0.0.alpha] - 2025-04-10

### Added
- Added support for nested resources with `NestedCollectionProxy` class:
  - Enables ActiveRecord-style operations on nested resources (e.g., `project.tasks.create`)
  - Supports proper path construction for nested API endpoints
  - Implements `destroy_all` method for bulk deletion of nested resources

## [1.0.0.alpha-initial] - 2025-04-10

### Added
- Implemented ActiveRecord-style query interface (`where`, `find`, `find_by`, `first`, `all`, `each`) via `CollectionProxy`.
- Added ActiveRecord-style persistence methods to `BaseEntity`:
  - `save` - Persist changes to an entity
  - `update` - Update attributes and save in one step
  - `destroy` - Delete an entity
  - `reload` - Refresh an entity from the API
- Added `has_many` method to `BaseEntity` for handling one-to-many associations, complementing the existing `association` method for one-to-one associations.
- Refactored entity association methods in `Project`, `User`, and `Company` classes to use the new `has_many` method.
- Added comprehensive project lifecycle test that creates a project, adds tasks and activities, then cleans up.
- Added support for nested resources with `NestedCollectionProxy` class:
  - Enables ActiveRecord-style operations on nested resources (e.g., `project.tasks.create`)
  - Supports proper path construction for nested API endpoints
  - Implements `destroy_all` method for bulk deletion of nested resources
- Complete redesign with Ruby-esque API
- Chainable methods for fluent interface
- Dynamic entity creation with Rails-style inflection
- Comprehensive entity coverage for all MOCO API endpoints:
  - Project
  - Activity
  - User
  - Company
  - Task
  - Invoice
  - Deal
  - Expense
  - WebHook
  - Schedule
  - Presence
  - Holiday
  - PlanningEntry
- Entity association methods for related entities
- Automatic entity creation from API responses
- Struct-based fallback for unknown entity types
- Generic association method for handling relationships between entities

### Changed
- Added ActiveSupport dependency for inflection methods
- Reorganized code structure for better maintainability
- Updated documentation with new API examples
- `MOCO::Activity#to_s` now uses `Helpers.decimal_hours_to_civil` for improved time display.
- Refined core components like `Client`, `CollectionProxy`, and `Connection`.
- Updated various entity classes (`Activity`, `BaseEntity`, `Presence`, `Project`) with internal improvements.
- Updated utility scripts (`mocurl.rb`, `sync_activity.rb`).

### Removed
- Legacy API (`lib/moco/api.rb`) as part of the transition to the new client.

## [0.1.2] - 2025-04-02

### Added
- Complete Activities API implementation:
  - Single activity retrieval
  - Bulk activity creation
  - Activity timer control (start/stop)
  - Activity disregard endpoint
  - Activity deletion
- Project management API endpoints:
  - Archive/unarchive projects
  - Project report operations
  - Project group assignment

## [0.1.1] - 2024-02-27

### Added
- Prepared for Gem release

### Changed
- Changed target Ruby version to 2.6 (from 3.x)
- Applied Rubocop configuration and fixed style errors

### Security
- Bumped `uri` dependency to 0.13.0

## [0.1.0] - 2024-02-27
- Initial release

[Unreleased]: https://github.com/starsong-consulting/moco-ruby/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/starsong-consulting/moco-ruby/compare/v1.0.0.beta...v1.0.0
[1.0.0.beta]: https://github.com/starsong-consulting/moco-ruby/compare/v1.0.0.alpha...v1.0.0.beta
[1.0.0.alpha]: https://github.com/starsong-consulting/moco-ruby/compare/v1.0.0.alpha-initial...v1.0.0.alpha
[1.0.0.alpha-initial]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.2...v1.0.0.alpha-initial
[0.1.2]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/starsong-consulting/moco-ruby/releases/tag/v0.1.0
