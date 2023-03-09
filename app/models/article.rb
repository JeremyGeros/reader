require 'open-uri'

class Article < ApplicationRecord
  include Faviconable

  belongs_to :source, optional: true
  belongs_to :user
  belongs_to :import, optional: true

  has_many :notes, dependent: :destroy, inverse_of: :article

  has_one_attached :raw_html
  has_one_attached :header_image do |attachable|
    attachable.variant :head, resize: "750x400^", gravity: "center", extent: "750x400"
  end

  validates :url, presence: true

  after_commit :parse
  after_commit :read_later_save_delayed, on: :create

  # Most recent scope either by coalcesed published_at or created_at
  scope :most_recent, -> { order(Arel.sql('COALESCE(articles.published_at, articles.created_at) DESC')) }

  scope :ready, -> { where(parse_progress: :complete).left_outer_joins(:source).where('articles.source_id IS NULL or sources.temporary_at IS NULL') }
  scope :common_preloads, -> { with_attached_header_image.with_attached_favicon.preload(source: { favicon_attachment: :blob }) }
  
  enum parse_progress: {
    not_started: 0,
    in_progress: 1,
    complete: 2,
    failed: 3,
  }, _prefix: true

  enum read_status: {
    new: 0,
    read: 1,
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

  def read_later_save_delayed
    ReadLaterSaveJob.perform_later(self)
  end

  def content
    edited_content.presence || extracted_content
  end

  def parse
    parse! if parse_progress_not_started?
  end

  def parse!
    return if parse_progress_in_progress?
    if raw_html.attached?
      notes.destroy_all
      update(parse_progress: :in_progress, name: nil, edited_content: nil, excerpt: nil, extracted_content: nil, extracted_text: nil, ttr: 0, header_image: nil)
      ParseArticleJob.perform_later(self)
    end
  end

  def excerpt_or_content
    excerpt.presence || extracted_text.truncate(340)
  end

  def header_image_url=(url)
    url = URI.parse(url)
    filename = File.basename(url.path)
    file = URI.open(url)
    header_image.attach(io: file, filename: filename)
  rescue => e
    Rails.logger.info "Article header image url: #{e}"
    nil
  end

  def favicon_or_source_favicon
    favicon.attached? ? favicon : source&.favicon
  end
end
