require 'uri'

class Source < ApplicationRecord
  include Faviconable

  belongs_to :user

  has_many :articles, dependent: :destroy

  has_rich_text :description

  validates :name, presence: true
  validates :url, presence: true

  scope :ready, -> { where(scan_progress: :complete) }
  scope :not_preview, -> { where(temporary_at: nil) }
  scope :common_preloads, -> { with_attached_favicon.with_rich_text_description}

  after_commit :scan, on: :create

  enum scan_progress: {
    not_scanned: 0,
    scanning: 1,
    complete: 2,
    failed: 3,
  }, _prefix: true


  enum scan_interval: {
    hourly: 0,
    daily: 1,
    weekly: 2,
    monthly: 3,
    never: 4,
  }


  before_validation :set_defaults

  def set_defaults
    self.name ||= url
  end

  def scan_interval_in_seconds
    case scan_interval
    when 'hourly'
      1.hour
    when 'daily'
      1.day
    when 'weekly'
      1.week
    when 'monthly'
      1.month
    end
  end

  def scan
    return if scan_interval == 'never'

    if (last_scanned_at.nil? || last_scanned_at < scan_interval_in_seconds.ago) 
      scan!
    end
  end

  def scan!
    if !scan_progress_scanning?
      update(scan_progress: :scanning)
      ScanSourceJob.perform_later(self)
    end
  end

  def full_rescan!
    update(last_scanned_at: nil, rss_url: nil, scan_progress: :not_scanned, description: nil)
    favicon.purge

    scan!
  end

  def pretty_name
    "#{name} (#{URI.parse(url).host})"
  end


end
