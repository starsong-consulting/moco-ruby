# frozen_string_literal: true

module MOCO
  # Represents a MOCO webhook
  # Provides methods for webhook-specific operations
  class WebHook < BaseEntity
    # Override entity_path to match API path
    def entity_path
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
