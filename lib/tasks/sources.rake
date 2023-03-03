desc "Manage sources"

namespace :sources do
  task :remove_temporary_sources do
    Source.where.not(temporary_at: nil).where("temporary_at < ?", 1.day.ago).destroy_all
  end

  task :scan do
    Source.where(scan_progress: [:complete, :not_started]).find_each do |source|
      source.scan
    end
  end

end