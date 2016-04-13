class ColumnAccceptedInviteFriend < ActiveRecord::Migration
  def change
  	change_column :invitefriends, :invite_accepted, :boolean, default: false
  end
end
