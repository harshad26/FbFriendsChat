class Invitefriends < ActiveRecord::Migration
  def change
  	create_table :invitefriends do |t|
      t.integer :user_id
      t.integer :inviteid
      t.boolean :invite_accepted

      t.timestamps null: false
    end
  end
end
