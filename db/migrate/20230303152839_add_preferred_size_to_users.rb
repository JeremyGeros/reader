class AddPreferredSizeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :preferred_size, :integer, default: 1, null: false
    add_column :users, :preferred_code_style, :integer, default: 0, null: false
    add_column :users, :preferred_font, :integer, default: 0, null: false
    add_column :users, :preferred_theme, :integer, default: 0, null: false
    add_column :users, :preferred_font_size, :integer, default: 1, null: false
  end
end
