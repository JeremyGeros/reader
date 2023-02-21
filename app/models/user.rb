class User < ApplicationRecord
  ADMIN_EMAILS = ['jeremy453@gmail.com', 'ivette.yanez@gmail.com']

  has_secure_password

  has_many :user_sessions, dependent: :destroy

  # Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }

    
  before_validation :tidy_up_details

  validate :allow_signup?

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
