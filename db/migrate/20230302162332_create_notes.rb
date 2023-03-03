class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.text :text, null: false
      t.references :article, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :position
      t.integer :highlight_type, default: 0, null: false

      t.timestamps
    end
  end
end
