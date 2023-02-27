class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :url
      t.string :name
      t.text :extracted_text
      t.string :subtitle
      t.references :source, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :status, null: false, default: 0
      t.datetime :read_at

      t.timestamps
    end
  end
end
