# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string           not null
#  email           :string           not null
#  password_digest :string
#  session_token   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :username, :email, :password_digest, :session_token, presence: true
  validates :username, :email, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  attr_reader :password

  after_initialize :ensure_session_token

  def self.find_by_credentials(username_email, password)
    user = User.find_by(username: username_email) || User.find_by(email: username_email)
    return nil unless user
    user && user.is_password?(password) ? user : nil
  end

  def reset_session_token!
    generate_unique_session_token
    save!
    self.session_token
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end
  private

  def new_token
    SecureRandom.urlsafe_base64
  end

  def generate_unique_session_token
    self.session_token = new_token
    while User.find_by(session_token: self.session_token)
      self.session_token = new_token
    end
    self.session_token
  end

  def ensure_session_token
    generate_unique_session_token unless self.session_token
  end
end
