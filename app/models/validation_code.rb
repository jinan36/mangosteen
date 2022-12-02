class ValidationCode < ApplicationRecord
  validates :email, presence: true
  enum kind: {sign_in: 0, reset_password: 1}

  before_create :generate_code
  after_create :send_email

  def generate_code
    self.code = SecureRandom.random_number.to_s[2..7]
  end

  def send_email
    UserMailer.welcome_email(email).deliver
  end
end
