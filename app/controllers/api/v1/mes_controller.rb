class Api::V1::MesController < ApplicationController
  def show
    authorization = request.headers["Authorization"]
    token = begin
      authorization.split(" ")[1]
    rescue
      ""
    end

    payload = begin
      JWT.decode token, Rails.application.credentials.hmac_secret, true, {algorithm: "HS256"}
    rescue
      nil
    end

    return head 400 if payload.nil?

    user_id = begin
      payload[0]["user_id"]
    rescue
      nil
    end
    user = User.find user_id
    return head 404 if user.nil?
    render status: 200, json: {
      resource: user
    }
  end
end
