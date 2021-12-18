class AddIndexToIps < ActiveRecord::Migration[6.1]
  def change
    add_index :ips, [:ip, :user_id], unique: true
  end
end
