class User < ApplicationRecord
  validates :email, presence: true

  def generate_jwt
    payload = {user_id: id}
    JWT.encode payload, Rails.application.credentials.hmac_secret, "HS256"
  end

  def generate_auth_header
    {Authorization: "Bearer #{generate_jwt}"}
  end
end
