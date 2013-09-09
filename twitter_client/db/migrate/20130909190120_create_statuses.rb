class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :body, :null => false
      t.integer :twitter_status_id, :null => false

      t.timestamps
    end

    add_index :statuses, :twitter_status_id, unique: true
  end
end
