require "rails_helper"
require "rspec_api_documentation/dsl"

resource "账目" do
  get "api/v1/items" do
    authentication :basic, :auth
    parameter :page, "页码"
    parameter :created_after, "创建时间起点"
    parameter :created_before, "创建时间终点"
    with_options scope: :resources do
      response_field :id, "ID"
      response_field :amount, "金额（单位：分）"
    end

    let(:created_after) { "2020-10-10" }
    let(:created_before) { "2022-11-11" }
    let(:current_user) { User.create email: "1@qq.com" }
    let(:auth) { "Bearer #{current_user.generate_jwt}" }
    example "获取账目" do
      user = User.create email: "2@qq.com"
      9.times { Item.create amount: 100, tags_id: [1], happen_at: Time.now, created_at: "2021-11-11", user_id: user.id }

      11.times { Item.create amount: 100, tags_id: [1], happen_at: Time.now, created_at: "2021-11-11", user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
      expect(json["resources"][8]["user_id"]).to eq current_user.id
      expect(json["pager"]["count"]).to eq 11
    end
  end
end
