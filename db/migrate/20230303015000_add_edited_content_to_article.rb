class AddEditedContentToArticle < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :edited_content, :text

    remove_column :notes, :position
  end
end
