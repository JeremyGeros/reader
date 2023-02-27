class Article < ApplicationRecord
  belongs_to :source
  belongs_to :user

  has_one_attached :raw_html

  validates :url, presence: true
  validates :name, presence: true

  after_commit :parse

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

  def parse
    return if parse_progress_in_progress?
    if raw_html.attached? && parse_progress_not_started?
      update(parse_progress: :in_progress)
      ParseArticleJob.perform_later(self)
    end
  end
end
