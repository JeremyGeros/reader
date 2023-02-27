class ChangeStatusEnumOnArticles < ActiveRecord::Migration[7.0]
  def change
    rename_column :articles, :status, :read_status
    add_column :articles, :parse_progress, :integer, default: 0, null: false
  end
end
