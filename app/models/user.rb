class User < ApplicationRecord
  ADMIN_EMAILS = ['jeremy453@gmail.com', 'ivette.yanez@gmail.com']

  has_secure_password

  has_many :user_sessions, dependent: :destroy

  has_many :sources, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :imports, dependent: :destroy

  # Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }

    
  before_validation :tidy_up_details

  validate :allow_signup?

  enum preferred_size: {
    small: 0,
    medium: 1,
    large: 2,
    xlarge: 3,
    full: 4,
  }, _prefix: true

  enum preferred_code_style: {
    dimmed: 0,
    bright: 1,
    dark: 2,
  }, _prefix: true

  enum preferred_font: {
    default: 0,
    monospace: 1,
  }, _prefix: true

  enum preferred_theme: {
    system: 0,
    light: 1,
    dark: 2,
  }, _prefix: true

  enum preferred_font_size: {
    md: 0,
    lg: 1,
    xl: 2,
    sm: 3,
  }, _prefix: true


  def tidy_up_details
    self.email = email.strip.downcase
  end

  # Only allow us to sign up
  def allow_signup?
    ADMIN_EMAILS.include?(email)
  end

  def admin?
    ADMIN_EMAILS.include?(email)
  end
end
