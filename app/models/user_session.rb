class UserSession < ApplicationRecord
  belongs_to :user

  has_secure_token :key, length: 64
  before_create :set_accessed_at

  validates :user_id, presence: true

  def self.authenticate(key)
    self.where(key: key).first
  end

  def access!
    set_accessed_at
    save
  end

  private
  
  def set_accessed_at
    self.accessed_at = Time.now.utc
  end
  
end
