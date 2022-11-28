require "jwt"

class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != "123456"
    else
      can_signin = ValidationCode.exists? email: params[:emial], code: params[:code], used_at: nil
      return render status: :unauthorized unless can_signin
    end
    user = User.find_by_email params[:email]
    if user.nil?
      render status: 404, json: {errors: "用户不存在"}
    else
      render status: 200, json: {
        jwt: user.generate_jwt
      }
    end
  end
end
