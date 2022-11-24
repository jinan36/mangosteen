class ValidationCode < ApplicationRecord
  validates :email, presence: true

  after_initialize :generate_code
  after_save :send_email

  def generate_code
    self.code = SecureRandom.random_number.to_s[2..7]
  end

  def send_email
    UserMailer.welcome_email(email)
  end
end
