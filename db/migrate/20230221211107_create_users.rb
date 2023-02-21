class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.string :time_zone, null: false, default: 'UTC'

      t.timestamps

      t.index :email, unique: true
    end
  end
end
