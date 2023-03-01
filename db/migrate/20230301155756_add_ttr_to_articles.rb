class AddTtrToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :ttr, :integer, default: 0, null: false
  end
end
