class ChangeTwitterIdsToString < ActiveRecord::Migration
  def up
    change_column :users, :twitter_user_id, :string
    change_column :statuses, :twitter_status_id, :string
    change_column :statuses, :user_id, :string
  end

  def down
    change_column :users, :twitter_user_id, :integer
    change_column :statuses, :twitter_status_id, :integer
    change_column :statuses, :user_id, :integer
  end
end
