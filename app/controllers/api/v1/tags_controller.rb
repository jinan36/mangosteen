class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env["current_user_id"]
    return render status: :unauthorized if current_user.nil?

    tags = Tag.where(user_id: current_user.id, deleted_at: nil)
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

  def update
    tag = Tag.find params[:id]
    return render status: :forbidden if tag.user_id != request.env["current_user_id"]

    tag.update params.permit(:name, :sign)
    if tag.errors.empty?
      render json: {resource: tag}, status: :ok
    else
      render json: {errors: tag.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    tag = Tag.find params[:id]
    return render status: :forbidden if tag.user_id != request.env["current_user_id"]

    tag.deleted_at = Time.now
    if tag.save
      render status: :ok
    else
      render json: {errors: tag.errors}, status: :unprocessable_entity
    end
  end

  def show
    tag = begin
      Tag.find params[:id]
    rescue
      return render status: :not_found
    end

    return render status: :forbidden if tag.user_id != request.env["current_user_id"]
    render json: {resource: tag}, status: :ok
  end
end
