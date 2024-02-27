# moco.rb

## Library

A Ruby library to abstract the [MOCO API](https://hundertzehn.github.io/mocoapp-api-docs/).

### MOCO::API

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

### MOCO::Entities

The following entities are currently defined:

- Project (:id, :active, :name, :customer, :tasks)
- Task (:id, :active, :name, :project_id, :billable)
- Activity (:id, :active, :date, :description, :project, :task, :seconds, :hours, :billable, :billed, :user, :customer, :tag)
- Customer (:id, :name)
- User (:id, :firstname, :lastname)

The entities implement comparison, hash and JSON conversion.

### MOCO::Sync

Intelligently matches and syncs data from one MOCO instance to another.
Currently supports activities (time entries) only.
See `sync_activity.rb` for a more detailed example.

```ruby
source_api = MOCO::API.new(source_instance, source_api_key)
target_api = MOCO::API.new(target_instance, target_api_key)

syncer = MOCO::Sync.new(
  source_api,
  target_api,
  project_match_threshold: options[:match_project_threshold],
  task_match_threshold: options[:match_task_threshold],
  filters: {
    source: options.slice(:from, :to, :project_id, :company_id, :term),
    target: options.slice(:from, :to)
  },
  dry_run: options[:dry_run]
)
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
