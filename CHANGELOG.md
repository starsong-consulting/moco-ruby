# Changelog

## [Unreleased]

### Fixed
- Ensure `EntityCollection#update` and `EntityCollection#delete` delegate to `CollectionProxy` for consistent behavior.

## [1.0.0] - 2025-04-02

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

### Changed
- Added ActiveSupport dependency for inflection methods
- Reorganized code structure for better maintainability
- Updated documentation with new API examples

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
