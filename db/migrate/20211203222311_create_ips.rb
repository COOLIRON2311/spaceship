class CreateIps < ActiveRecord::Migration[6.1]
  def change
    create_table :ips do |t|
      t.string :ip
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
