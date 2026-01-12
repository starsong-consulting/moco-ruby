# MOCO Ruby Gem

[![Gem Version](https://badge.fury.io/rb/moco-ruby.svg)](https://badge.fury.io/rb/moco-ruby)

A Ruby Gem to interact with the [MOCO API](https://hundertzehn.github.io/mocoapp-api-docs/). This gem provides a modern, Ruby-esque interface (`MOCO::Client`) for interacting with the MOCO API.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add moco-ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install moco-ruby

## Usage

### Initialization

```ruby
require 'moco'

moco = MOCO::Client.new(
  subdomain: "your-subdomain", # Your MOCO subdomain
  api_key: "your-api-key"      # Your MOCO API key
)
```

### Accessing Collections

Collections are accessed dynamically using pluralized entity names (following Rails conventions):

```ruby
projects    = moco.projects
activities  = moco.activities
users       = moco.users
# ... and so on for all supported entities
```

### Fetching Entities

```ruby
# Get all entities in a collection
all_projects = moco.projects.all

# Get entities matching specific criteria
active_projects = moco.projects.where(active: true)
recent_activities = moco.activities.where(date: ">=2024-01-01")

# Get a specific entity by ID
project = moco.projects.find(12345)
user = moco.users.find(678)
```

### Creating Entities

```ruby
# Create a new project
new_project = moco.projects.create(
  name: "New Website Project",
  customer_id: 987,
  billable: true
)
puts "Created project: #{new_project.name} (ID: #{new_project.id})"

# Create a new time entry (activity)
new_activity = moco.activities.create(
  date: "2024-04-10",
  project_id: new_project.id,
  task_id: new_project.tasks.first.id, # Assumes project has tasks
  hours: 3.5,
  description: "Implemented feature X"
)
puts "Created activity: #{new_activity.description} on #{new_activity.date}"
```

### Updating Entities

Modify attributes and call `save`:

```ruby
project = moco.projects.find(12345)
project.name = "Updated Project Name"
project.billable = false

if project.save
  puts "Project updated successfully."
else
  puts "Failed to update project: #{project.errors.full_messages.join(", ")}" # Assuming error handling exists
end

# You can also update directly via the collection
moco.projects.update(12345, name: "Another Update", active: false)
```

### Deleting Entities

```ruby
# Delete by object
activity = moco.activities.find(9876)
if activity&.delete
  puts "Activity deleted."
end

# Delete by ID via collection
if moco.activities.delete(9876)
  puts "Activity deleted."
end
```

### Entity Associations

Entities provide methods to access related entities easily:

```ruby
project = moco.projects.find(12345)

# Get tasks associated with the project
tasks = project.tasks # Returns a collection proxy for tasks
puts "Tasks for project '#{project.name}': #{tasks.map(&:name).join(', ')}"

# Get activities for the project
project_activities = project.activities
puts "Activities count: #{project_activities.size}"

# Get the customer (company) for the project
customer = project.customer # Returns a MOCO::Company object
puts "Customer: #{customer.name}"

# ---

activity = moco.activities.find(9876)

# Get the associated project, task, and user
act_project = activity.project
act_task = activity.task
act_user = activity.user
puts "Activity by #{act_user.firstname} on project '#{act_project.name}' (Task: #{act_task.name})"
```

### Nested Resources

The gem supports ActiveRecord-style operations on nested resources:

```ruby
project = moco.projects.find(12345)

# Create a new task for the project
new_task = project.tasks.create(
  name: "New Feature Development",
  billable: true,
  active: true,
  budget: 40,
  hourly_rate: 120
)
puts "Created task: #{new_task.name} (ID: #{new_task.id})"

# Delete all tasks for a project
project.tasks.destroy_all

# Query tasks with conditions
billable_tasks = project.tasks.where(billable: true).all
puts "Billable tasks: #{billable_tasks.map(&:name).join(', ')}"

# Find a specific task
dev_task = project.tasks.find_by(name: "Development")
```

### Supported Entities

The gem supports all MOCO API entities with a Ruby-esque interface:

- `Project`
- `Activity`
- `User`
- `Company`
- `Task`
- `Invoice`
- `Deal`
- `Expense`
- `WebHook`
- `Schedule`
- `Presence`
- `Holiday`
- `PlanningEntry`

Access them via the moco using their plural, snake_case names (e.g., `moco.planning_entries`).

## Utilities

These command-line utilities provide helpful shortcuts. They can use credentials and configuration from a `config.yml` file (see `config.yml.sample`) in the current directory or accept parameters.

### `mocurl`

A wrapper around `curl` to easily make authenticated requests to your MOCO instance API. Useful for testing or exploring endpoints.

```
Usage: mocurl.rb [options] url
       mocurl.rb [options] subdomain path
    -X, --method METHOD              Set HTTP method to use (GET, POST, PUT, DELETE)
    -d, --data DATA                  Data to send to server (JSON format) for POST/PUT
    -a, --api-key API_KEY            Manually specify MOCO API key (overrides config.yml)
    -n, --no-format                  Disable JSON pretty-printing of the response
    -v, --verbose                    Show additional request and response information
    -h, --help                       Show this message
```
**Example:** `mocurl.rb your-subdomain projects/12345`

### `sync_activity`

Syncs activity data (time entries) between two MOCO instances (source and target). It uses fuzzy matching to map projects and tasks between the instances.

**Important:**
*   Always use `--dry-run` first to verify the matching and intended actions.
*   Use date filters (`--from`, `--to`) to limit the scope.

```
Usage: sync_activity.rb [options] source_subdomain target_subdomain
    -f, --from DATE                  Start date for sync (YYYY-MM-DD)
    -t, --to DATE                    End date for sync (YYYY-MM-DD)
    -p, --project PROJECT_ID         Source Project ID to filter by (optional)
    -c, --company COMPANY_ID         Source Company ID to filter by (optional)
    -g, --term TERM                  Term to filter source activities by (optional)
    -n, --dry-run                    Perform matching and show planned actions, but do not modify target instance
        --match-project-threshold VALUE
                                     Fuzzy match threshold for projects (0.0 - 1.0), default 0.8
        --match-task-threshold VALUE Fuzzy match threshold for tasks (0.0 - 1.0), default 0.45
        --default-task TASK_NAME     Map unmatched tasks to this default task instead of creating new tasks
    -d, --debug                      Enable debug output
    -h, --help                       Show this message
```
**Example:** `sync_activity.rb --from 2024-04-01 --to 2024-04-10 --dry-run source-instance target-instance`

**Using Default Task Mapping:** If your target account has limited permissions and cannot create tasks, or if you want to consolidate multiple source tasks into a single target task, use the `--default-task` flag:

```bash
sync_activity.rb --from 2024-04-01 --to 2024-04-10 --default-task "Other" source-instance target-instance
```

This will map any unmatched source tasks to a task named "Other" in the corresponding target project, avoiding the need to create new tasks.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

### Running Tests

The gem includes a comprehensive test suite with both unit tests (mocked) and integration tests (live API):

```bash
# Run all tests
ruby test/test_v2_api.rb              # Unit tests (mocked, fast)
ruby test/test_comprehensive.rb       # Integration tests (requires .env)
ruby test/test_holidays_expenses.rb   # Holidays & Expenses tests (requires .env)

# Or run individually
ruby test/test_v2_api.rb
```

For integration tests, create a `.env` file with your test instance credentials:
```
MOCO_API_TEST_SUBDOMAIN=your-test-subdomain
MOCO_API_TEST_API_KEY=your-test-api-key
```

**Note:** The MOCO API has rate limits (120 requests per 2 minutes on standard plans). Integration tests make real API calls.

### Installation

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, update the `CHANGELOG.md`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/starsong-consulting/moco-ruby.

## License

The gem is available as open source under the terms of the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
