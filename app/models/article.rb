class Article < ApplicationRecord
  belongs_to :source, optional: true
  belongs_to :user

  has_one_attached :raw_html

  validates :url, presence: true

  after_commit :parse
  after_commit :read_later_save, on: :create

  # Most recent scope either by coalcesed published_at or created_at
  scope :most_recent, -> { order(Arel.sql('COALESCE(articles.published_at, articles.created_at) DESC')) }

  scope :ready, -> { where(parse_progress: :complete) }
  
  enum parse_progress: {
    not_started: 0,
    in_progress: 1,
    complete: 2,
    failed: 3,
  }, _prefix: true

  enum read_status: {
    new: 0,
    read: 1,
    archived: 2,
    deleted: 3,
  }, _prefix: true

  def display_date
    published_at || created_at
  end

  def read_later_save
    if source.nil?
      raw_html.attach(
        io: URI.open(url, "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/36.0  Mobile/15E148 Safari/605.1.15"),
        filename: "#{id}.html"
      )
    end
  end

  def parse
    parse! if parse_progress_not_started?
  end

  def parse!
    return if parse_progress_in_progress?
    if raw_html.attached?
      update(parse_progress: :in_progress)
      ParseArticleJob.perform_now(self)
    end
  end
end
