class Api::V1::MesController < ApplicationController
  def show
    user_id = begin
      request.env["current_user_id"]
    rescue
      nil
    end
    user = User.find user_id
    return head 404 if user.nil?
    render json: {resource: user}
  end
end
