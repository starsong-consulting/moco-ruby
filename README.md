# moco-ruby

A Ruby Gem to interact with the [MOCO API](https://hundertzehn.github.io/mocoapp-api-docs/).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add moco-ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install moco-ruby

## Usage

### v2.0.0 API (Recommended)

```ruby
# Initialize client
moco = MOCO::Client.new(subdomain: "your-subdomain", api_key: "your-api-key")

# Get all projects
projects = moco.projects.all

# Get a specific project
project = moco.projects.find(123)

# Chain operations
project.archive.assign_to_group(456)

# Work with activities
activities = project.activities
activity = activities.create(
  date: "2023-01-01",
  task_id: project.tasks.first.id,
  hours: 2,
  description: "Development work"
)

# Start and stop timers
activity.start_timer
# ... do work ...
activity.stop_timer

# Automatic entity creation from API responses
report = moco.get("projects/123/report")
```

### Entity Associations

Entities have association methods for related entities:

```ruby
# Project associations
project.tasks          # => Array of Task objects
project.activities     # => Array of Activity objects
project.customer       # => Company object

# Activity associations
activity.project       # => Project object
activity.task          # => Task object
activity.user          # => User object

# User associations
user.activities        # => Array of Activity objects
user.presences         # => Array of Presence objects
user.holidays          # => Array of Holiday objects
```

### Supported Entities

The gem supports all MOCO API entities with a Ruby-esque interface:

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

### Dynamic Collection Access

The client dynamically handles any collection name that follows Rails conventions:

```ruby
# These all work automatically
moco.projects.all
moco.activities.where(date: "2023-01-01")
moco.users.find(123)
moco.companies.create(name: "New Company")
moco.invoices.where(status: "draft")
moco.deals.all
moco.expenses.where(billable: true)
moco.web_hooks.all
moco.schedules.where(date: "2023-01-01")
moco.presences.all
moco.holidays.where(year: 2023)
moco.planning_entries.all
```

### Legacy API (v0.1.x)

The legacy API is still available but deprecated:

```ruby
moco = MOCO::API.new(subdomain, api_key)
assigned_projects = moco.get_assigned_projects(active: 'true')
assigned_projects.each do |project|
  puts "Project \##{project.id} #{project.name} for customer #{project.customer.name}"
  project.tasks.each do |task|
    puts "- Task #{task.name} is #{task.billable ? 'billable' : 'not billable'}"
  end
end
```

## Utilities

Utilities can use `config.yml` to fetch instance data and other configuration. For format, see `config.yml.sample`.

### mocurl

Run an API request against a MOCO instance and return the result nicely formatted.
Use config.yml or specify api key with `-a`.

```
Usage: mocurl.rb [options] url
       mocurl.rb [options] subdomain path
    -X, --method METHOD              Set HTTP method to use
    -d, --data DATA                  Data to send to server, JSON format
    -a, --api-key API_KEY            Manually specify MOCO API key
    -n, --no-format                  Disable JSON pretty-printing
    -v, --verbose                    Show additional request and response information
    -h, --help                       Show this message
```

### sync_activity

Sync activity data (time entries) from one instance to another, fuzzy matching projects and tasks.
It is highly recommended to use filter options (`--from`, `--to`) and to use `--dry-run` first to check the matching performance.

```
Usage: sync_activity.rb [options] source target
    -f, --from DATE                  Start date (YYYY-MM-DD)
    -t, --to DATE                    End date (YYYY-MM-DD)
    -p, --project PROJECT_ID         Project ID to filter by
    -c, --company COMPANY_ID         Company ID to filter by
    -g, --term TERM                  Term to filter for
    -n, --dry-run                    Match only, but do not edit data
        --match-project-threshold VALUE
                                     Project matching threshold (0.0 - 1.0), default 0.8
        --match-task-threshold VALUE Task matching threshold (0.0 - 1.0), default 0.45
```
