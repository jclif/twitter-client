require 'twitter_session'

class User < ActiveRecord::Base
  attr_accessible :screen_name, :twitter_user_id

  validates :screen_name, presence: true
  validates :twitter_user_id, presence: true

  has_many(
    :statuses,
    class_name: "Status",
    foreign_key: :user_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :inbound_follows,
    class_name: "Follow",
    foreign_key: :twitter_followee_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :outbound_follows,
    class_name: "Follow",
    foreign_key: :twitter_follower_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :followed_users,
    through: :outbound_follows,
    source: :followee
  )

  has_many(
    :followers,
    through: :inbound_follows,
    source: :follower
  )

  def self.fetch_by_screen_name(screen_name)
    url = Addressable::URI.new(
        scheme: "https",
        host: "api.twitter.com",
        path: "1.1/users/show.json",
        query_values: {
          screen_name: screen_name
        }
      ).to_s
    TwitterSession.get(url)
  end

  def self.parse_twitter_params(params)
    parsed = JSON.parse(params.body)
    User.new(
      screen_name: parsed["screen_name"],
      twitter_user_id: parsed["id_str"]
    )
  end

  def self.fetch_by_ids(ids)
    ids.map do |id|
      user = User.find_by_twitter_user_id(id)
      if user.nil?
        url = Addressable::URI.new(
            scheme: "https",
            host: "api.twitter.com",
            path: "1.1/users/show.json",
            query_values: {
              id: id
            }
        ).to_s
        user = User.parse_twitter_params(TwitterSession.get(url))
        user.save
      end

      user
    end
  end

  def fetch_followers
  end

  def sync_followers
  end

  def sync_statuses
    tweets = Status.fetch_statuses_for_user(self)

    tweets.each do |tweet|
      unless self.statuses.any? do |status|
        status.twitter_status_id == tweet.twitter_status_id
      end
        tweet.save
      end
    end
  end
end
