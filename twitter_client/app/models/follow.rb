class Follow < ActiveRecord::Base
  attr_accessible :twitter_followee_id, :twitter_follower_id
end
