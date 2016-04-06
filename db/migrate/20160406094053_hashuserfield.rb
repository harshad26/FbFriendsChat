class Hashuserfield < ActiveRecord::Migration
  	def self.up
	   add_column :users, :multi_friends, :text
	end

	def self.down
	   add_column :users, :multi_friends, :text
	end
end
