class Addfieldstouser < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :name, :string
  	add_column :users, :head_id, :integer
  end
end
