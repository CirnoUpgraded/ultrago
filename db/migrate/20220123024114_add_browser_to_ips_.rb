class AddBrowserToIps < ActiveRecord::Migration[6.1]
  def change
    add_column(:ips,:browser,:text)
  end
end
