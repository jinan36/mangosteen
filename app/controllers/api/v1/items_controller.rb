class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?

    items = Item.where({user_id: current_user_id})
      .where({created_at: params[:created_after]..params[:created_before]})

    render json: {
      resources: items.page(params[:page]),
      pager: {
        page: params[:page] || 1,
        per_page: Item.default_per_page,
        count: items.count
      }
    }
  end

  def create
    item = Item.new params.permit(:amount, :note, :kind, :happen_at, tags_id: [])
    item.user_id = request.env["current_user_id"]
    if item.save
      render json: {resource: item}, status: :ok
    else
      render json: {errors: item.errors}, status: :unprocessable_entity
    end
  end

  def summary
    hash = {}
    items = Item.where(user_id: request.env["current_user_id"])
      .where(kind: params[:kind])
      .where(happen_at: params[:happened_after]..params[:happened_before])
    items.each do |item|
      key = item.happen_at.in_time_zone("Beijing").strftime("%F")
      hash[key] ||= 0
      hash[key] += item.amount
    end
    groups = hash.map { |key, value| {happen_at: key, amount: value} }
      .sort_by { |a| a[:happen_at] }
    render json: {
      groups: groups,
      total: items.sum(:amount)
    }, status: :ok
  end
end
