class CreateLeaves < ActiveRecord::Migration[5.0]
  def change
    create_table :leaves do |t|
      t.integer :status, :limit => 1		  
  	  t.text :reason
  	  t.date :applied_date
  	  t.string :from_to
      t.integer :user_id
      t.timestamps
    end
  end
end
