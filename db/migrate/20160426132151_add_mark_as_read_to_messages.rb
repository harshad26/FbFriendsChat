class AddMarkAsReadToMessages < ActiveRecord::Migration
  def self.up
  	add_column :messages, :mark_as_read, :boolean, default: false
  end
  def self.down
    remove_column :messages, :mark_as_read, :boolean, default: false
  end
end
