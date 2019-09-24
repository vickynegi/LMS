class AddfieldsToUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :taken_leaves, :integer, :limit => 2, :default => 0
    add_column :users, :credited_leaves, :integer, :limit => 2, :default => 0
  end
end
