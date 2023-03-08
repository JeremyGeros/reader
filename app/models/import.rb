require 'csv'
class Import < ApplicationRecord
  belongs_to :user

  has_many :articles, dependent: :nullify

  has_one_attached :file

  validates :file, presence: true
  validates :user, presence: true

  enum import_type: {
    instapaper: 0,
    pocket: 1,
    readwise: 2,
  }

  enum status: {
    pending: 0,
    processing: 1,
    imported: 2,
    failed: 3,
  }

  before_validation :set_defaults, on: :create

  def set_defaults
    self.status ||= :pending
    self.name ||= "Import #{Time.now.strftime('%c')} from #{import_type.humanize}"
  end

  def import!
    self.processing!


    articles_count = 0

    rows = case import_type
    when 'instapaper'
      import_instapaper
    when 'pocket'
      import_pocket
    when 'readwise'
      import_readwise
    end

    rows.each do |row|
      next if row['url'].blank? || user.articles.where(url: row['url']).exists?

      article = user.articles.new(url: row['url'])
      article.name = row['name']
      article.published_at = row['published_at']
      article.starred = row['starred']
      article.read_status = :read if row['starred']
      article.user = user
      article.import = self
      article.save!

      articles_count += 1
    end

    self.update(status: :imported, articles_count: articles_count)
  rescue => e
    self.update(status: :failed, failed_message: e.message)
    raise e if Rails.env.development?
  end

  def import_instapaper
    rows = []
    CSV.parse(self.file.download, headers: true).map do |row|
      next unless ['Starred', 'Unread'].include?(row['Folder'])

      rows << {
        'name' => row['Title'],
        'url' => row['URL'],
        'published_at' => row['Timestamp'],
        'starred' => row['Folder'] == 'Starred',
      }
    end

    rows
  end
end
