# frozen_string_literal: true

module MOCO
  # Represents a MOCO comment
  # Comments can be attached to various entities (projects, activities, etc.)
  class Comment < BaseEntity
    # Bulk create comments
    # @param client [MOCO::Client] the client instance
    # @param comments [Array<Hash>] array of comment attributes
    # @return [Array<Comment>] created comments
    def self.bulk_create(client, comments)
      response = client.post("comments/bulk", { bulk: comments })
      response.map { |data| new(client, data) }
    end

    # Associations
    def user
      association(:user)
    end

    def to_s
      text.to_s.truncate(50)
    end
  end
end
