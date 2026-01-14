# frozen_string_literal: true

module MOCO
  # Represents a MOCO webhook for event notifications
  #
  # == Required attributes for create:
  #   target - String, entity type to watch:
  #            "Activity", "Company", "Contact", "Project",
  #            "Invoice", "Offer", "Deal", "Expense"
  #   event  - String, event type: "create", "update", "delete"
  #   hook   - String, URL to receive webhook payloads (e.g., "https://example.org/callback")
  #
  # == Read-only attributes:
  #   id, disabled, disabled_at, created_at, updated_at
  #
  # == Instance methods:
  #   enable   - Enable the webhook
  #   disable  - Disable the webhook
  #
  # == Example:
  #   # Create webhook for new activities
  #   moco.web_hooks.create(
  #     target: "Activity",
  #     event: "create",
  #     hook: "https://example.org/moco-activity-webhook"
  #   )
  #
  #   # Disable a webhook
  #   webhook = moco.web_hooks.find(123)
  #   webhook.disable
  #
  # == Note:
  #   Only the `hook` URL can be updated after creation.
  #   To change target/event, delete and recreate the webhook.
  #
  class WebHook < BaseEntity
    # Override entity_path to match API path
    def self.entity_path
      "account/web_hooks"
    end

    # Instance methods for webhook-specific operations
    def enable
      client.put("account/web_hooks/#{id}/enable")
      self
    end

    def disable
      client.put("account/web_hooks/#{id}/disable")
      self
    end

    def to_s
      "#{target} - #{url}"
    end
  end
end
