class AddRssUrlToSource < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :rss_url, :string
  end
end
