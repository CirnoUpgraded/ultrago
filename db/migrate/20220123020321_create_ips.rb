class CreateIps < ActiveRecord::Migration[6.1]
  def change
      create_table :ips do |t|
        t.text :ip
        t.text :arg
        t.text :domain
        t.timestamps null: false
    end
  end
end
