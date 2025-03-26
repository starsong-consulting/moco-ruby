# Changelog

## [2.0.0] - 2025-04-02

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

### Changed
- Added ActiveSupport dependency for inflection methods
- Reorganized code structure for better maintainability
- Updated documentation with new API examples

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
