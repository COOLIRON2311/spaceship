class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :task_hash
      t.string :result
      t.boolean :ready

      t.timestamps
    end
  end
end
