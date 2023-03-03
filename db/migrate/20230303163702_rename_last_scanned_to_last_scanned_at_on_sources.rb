class RenameLastScannedToLastScannedAtOnSources < ActiveRecord::Migration[7.0]
  def change
    rename_column :sources, :last_scanned, :last_scanned_at
  end
end
