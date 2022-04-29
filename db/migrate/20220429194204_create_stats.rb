class CreateStats < ActiveRecord::Migration[6.1]
  def change
    create_table :stats do |t|
      t.references :task, null: false, foreign_key: true
      t.float :percent
      t.float :time
      t.integer :calls
      t.float :min
      t.float :max

      t.timestamps
    end
  end
end
