class CreateUserSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :key, null: false
      t.datetime :accessed_at

      t.timestamps

      t.index :key, unique: true
    end
  end
end
