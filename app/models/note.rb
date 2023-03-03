class Note < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :text, presence: true

  enum highlight_type: {
    highlight: 0,
    note: 1,
  }, _prefix: true

  before_validation :set_defaults

  validate :user_must_be_article_user

  def set_defaults
    self.highlight_type ||= :highlight
    self.user ||= Current.user
  end

  def user_must_be_article_user
    if user != article.user
      errors.add(:user, "must be the same as the article user")
    end
  end


  def hash_link
    "note-#{id}"
  end
end
