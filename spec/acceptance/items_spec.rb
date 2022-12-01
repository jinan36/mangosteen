require "rails_helper"
require "rspec_api_documentation/dsl"

resource "账目" do
  authentication :basic, :auth
  let(:current_user) { User.create email: "1@qq.com" }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }

  get "api/v1/items" do
    parameter :page, "页码"
    parameter :created_after, "创建时间起点"
    parameter :created_before, "创建时间终点"
    with_options scope: :resources do
      response_field :id, "ID"
      response_field :amount, "金额（单位：分）"
    end

    let(:created_after) { "2020-10-10" }
    let(:created_before) { "2022-12-11" }

    example "获取账目" do
      tag = Tag.create name: "tag", sign: "x", user_id: current_user.id
      11.times { Item.create amount: 100, tags_id: [tag.id], happen_at: Time.now, created_at: "2021-11-11", user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
      expect(json["resources"][8]["user_id"]).to eq current_user.id
      expect(json["pager"]["count"]).to eq 11
    end
  end

  post "api/v1/items" do
    header "Content-Type", "application/json"
    parameter :amount, "金额（单位：分）", required: true
    parameter :kind, "类型", required: true, enum: ["expenses", "income"]
    parameter :happen_at, "发生时间", required: true
    parameter :tags_id, "标签 id", required: true
    with_options scope: :resource do
      response_field :id, "ID"
      response_field :amount, "金额（单位：分）"
      response_field :kind, "类型"
      response_field :happen_at, "发生时间"
      response_field :tags_id, "标签 id"
    end

    let(:amount) { 9900 }
    let(:kind) { "expenses" }
    let(:happen_at) { "2020-10-30T00:00:00+08:00" }
    let(:tags) { (0..1).map { Tag.create name: "x", sign: "x", user_id: current_user.id } }
    let(:tags_id) { tags.map(&:id) }
    example "创建账目" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["amount"]).to eq amount
    end
  end

  get "api/v1/items/summary" do
    parameter :happened_after, "时间起点", required: true
    parameter :happened_before, "时间终点", required: true
    parameter :kind, "账目类型", enum: ["expenses", "income"], required: true
    parameter :group_by, "分组依据", enum: ["happen_at", "tag_id"], required: true
    response_field :groups, "分组数据"
    response_field :total, "总金额（单位：分）"

    let(:happened_after) { "2018-01-01" }
    let(:happened_before) { "2019-01-01" }
    let(:kind) { "expenses" }
    let(:group_by) { "happen_at" }
    example "统计信息（按 happen_at 分组）" do
      user = current_user
      tag = Tag.create! name: "tag", sign: "x", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-19T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-19T00:00:00+08:00", user_id: user.id

      do_request
      expect(status).to eq 200
    end
  end

  get "api/v1/items/summary" do
    parameter :happened_after, "时间起点", required: true
    parameter :happened_before, "时间终点", required: true
    parameter :kind, "账目类型", enum: ["expenses", "income"], required: true
    parameter :group_by, "分组依据", enum: ["happen_at", "tag_id"], required: true
    response_field :groups, "分组数据"
    response_field :total, "总金额（单位：分）"

    let(:happened_after) { "2018-01-01" }
    let(:happened_before) { "2019-01-01" }
    let(:kind) { "expenses" }
    let(:group_by) { "tag_id" }
    example "统计信息（按 tag_id 分组）" do
      user = current_user
      tag1 = Tag.create! name: "tag1", sign: "x", user_id: user.id
      tag2 = Tag.create! name: "tag2", sign: "x", user_id: user.id
      tag3 = Tag.create! name: "tag3", sign: "x", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag1.id, tag2.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag2.id, tag3.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 300, kind: "expenses", tags_id: [tag3.id, tag1.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id

      do_request
      expect(status).to eq 200
    end
  end
end
