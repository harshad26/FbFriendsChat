class AddTimeoutToInviteFriends < ActiveRecord::Migration
  def self.up
  	add_column :invitefriends, :invite_timeout, :boolean, default: false
  end
  def self.down
    remove_column :invitefriends, :invite_timeout, :boolean, default: false
  end

end
