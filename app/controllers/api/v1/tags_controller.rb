class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env["current_user_id"]
    return render status: :not_found if current_user.nil?

    tags = Tag.where(user_id: current_user.id)
    render json: {resources: tags.page(params[:page]), pager: {
      page: params[:page] || 1,
      per_page: Tag.default_per_page,
      count: tags.count
    }}
  end
end
