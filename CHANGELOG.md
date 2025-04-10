# Changelog

## [Unreleased]

### Added
- Implemented ActiveRecord-style query interface (`where`, `find`, `find_by`, `first`, `all`, `each`) via `CollectionProxy`.
- Added ActiveRecord-style persistence methods to `BaseEntity`:
  - `save` - Persist changes to an entity
  - `update` - Update attributes and save in one step
  - `destroy` - Delete an entity
  - `reload` - Refresh an entity from the API

### Fixed
- Correctly handle `:customer` key hint during entity initialization to return `MOCO::Company` object.

## [1.0.0] - 2025-04-10

### Added
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
- `MOCO::Helpers.decimal_hours_to_civil` for converting decimal hours to HH:MM format.

### Changed
- Added ActiveSupport dependency for inflection methods
- Reorganized code structure for better maintainability
- Updated documentation with new API examples
- `MOCO::Activity#to_s` now uses `Helpers.decimal_hours_to_civil` for improved time display.
- Refined core components like `Client`, `CollectionProxy`, and `Connection`.
- Updated various entity classes (`Activity`, `BaseEntity`, `Presence`, `Project`) with internal improvements.
- Updated utility scripts (`mocurl.rb`, `sync_activity.rb`).

### Removed
- Legacy V1 API (`lib/moco/api.rb`) as part of the transition to the new V2 client.

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
[1.0.0]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.2...v1.0.0
[0.1.2]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/starsong-consulting/moco-ruby/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/starsong-consulting/moco-ruby/releases/tag/v0.1.0
