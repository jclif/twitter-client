class Status < ActiveRecord::Base
  attr_accessible :body, :twitter_status_id, :user_id

  validates :body, presence: true
  validates :twitter_status_id, presence: true

  belongs_to(
    :user,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :twitter_user_id
  )

  def self.fetch_statuses_for_user(user)
    url = Addressable::URI.new(
        scheme: "https",
        host: "api.twitter.com",
        path: "1.1/statuses/user_timeline.json",
        query_values: {
          user_id: user.twitter_user_id
        }
      ).to_s

    Status.parse_twitter_status(user.twitter_user_id, TwitterSession.get(url))
  end

  def self.parse_twitter_status(user_id, params)
    parsed = JSON.parse(params.body)
    parsed.map do |tweet|
      Status.new(
      body: tweet["text"],
      twitter_status_id: tweet["id_str"],
      user_id: user_id
      )
    end
  end
end
