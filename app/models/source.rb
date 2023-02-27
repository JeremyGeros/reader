class Source < ApplicationRecord
  belongs_to :user

  has_many :articles, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true


  enum scan_interval: {
    hourly: 0,
    daily: 1,
    weekly: 2,
    monthly: 3,
    never: 4,
    always: 5,
  }


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
    else
      1.second
    end
  end

  def scan
    return if scan_interval == 'never'

    if last_scanned.nil? || last_scanned < scan_interval_in_seconds.ago
      update(last_scanned: Time.now)
      ScanSourceJob.perform_later(self)
    end
  end

  def pretty_name
    "#{name} (#{URI.parse(url).host})"
  end

end
