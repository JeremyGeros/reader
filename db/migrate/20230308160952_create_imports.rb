class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.integer :import_from
      t.integer :status, default: 0, null: false
      t.integer :articles_count
      t.string :failed_message

      t.timestamps
    end

    add_column :articles, :import_id, :bigint
    add_column :articles, :starred, :boolean, default: false, null: false
  end
end
