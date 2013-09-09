class Status < ActiveRecord::Base
  attr_accessible :body, :twitter_status_id

  validates :body, presence: true
  validates :twitter_status_id, presence: true
end
