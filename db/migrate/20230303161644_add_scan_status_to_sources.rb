class AddScanStatusToSources < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :scan_progress, :integer, default: 0, null: false
  end
end
