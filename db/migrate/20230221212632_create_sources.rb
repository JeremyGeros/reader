class CreateSources < ActiveRecord::Migration[7.0]
  def change
    create_table :sources do |t|
      t.string :url, null: false
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :scan_interval, null: false, default: 0
      t.datetime :last_scanned
      t.datetime :enabled_at

      t.timestamps
    end
  end
end
