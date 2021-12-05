class CreateLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :links do |t|
      t.text :text
      t.text :domain
      t.text :password
      t.text :target
      t.timestamps null: false
    end
  end
end
