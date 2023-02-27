class AddExtraFieldsToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :byline, :string
    add_column :articles, :extracted_content, :text
    add_column :articles, :excerpt, :text
    add_column :articles, :language, :string
  end
end
