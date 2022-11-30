class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env["current_user_id"]
    return render status: :unauthorized if current_user.nil?

    tags = Tag.where(user_id: current_user.id)
    render json: {resources: tags.page(params[:page]), pager: {
      page: params[:page] || 1,
      per_page: Tag.default_per_page,
      count: tags.count
    }}
  end

  def create
    current_user = User.find request.env["current_user_id"]
    return render status: :unauthorized if current_user.nil?

    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user.id
    if tag.save
      render json: {resource: tag}, status: :ok
    else
      render json: {errors: tag.errors}, status: :unprocessable_entity
    end
  end
end
