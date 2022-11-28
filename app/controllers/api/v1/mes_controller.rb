class Api::V1::MesController < ApplicationController
  def show
    authorization = request.headers["Authorization"]
    token = authorization.split(" ")[1]

    payload = JWT.decode token, Rails.application.credentials.hmac_secret, true, {algorithm: "HS256"}
    user_id = payload[0]["user_id"]
    user = User.find user_id

    render status: 200, json: {
      resource: user
    }
  end
end
