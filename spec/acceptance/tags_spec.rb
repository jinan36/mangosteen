require "rails_helper"
require "rspec_api_documentation/dsl"

resource "标签" do
  authentication :basic, :auth
  let(:current_user) { User.create email: "1@qq.com" }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  header "Content-Type", "application/json"

  get "api/v1/tags" do
    parameter :page, "页码"
    with_options scope: :resources do
      response_field :id, "ID"
      response_field :name, "标签名"
      response_field :sign, "emoji 符号"
      response_field :user_id, "用户 ID"
      response_field :deleted_at, "删除时间"
    end

    example "获取标签" do
      user = User.create email: "2@qq.com"
      9.times { |i| Tag.create name: "tag#{i}", sign: "x", user_id: user.id }

      11.times { |i| Tag.create name: "tag#{i}", sign: "x", user_id: current_user.id }

      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
      expect(json["resources"][8]["user_id"]).to eq current_user.id
      expect(json["pager"]["count"]).to eq 11
    end
  end

  post "api/v1/tags" do
    parameter :name, "标签名", required: true
    parameter :sign, "emoji 表情", required: true
    with_options scope: :resource do
      response_field :id, "ID"
      response_field :name, "标签名"
      response_field :sign, "emoji 符号"
      response_field :user_id, "用户 ID"
      response_field :deleted_at, "删除时间"
    end

    let(:name) { "tag" }
    let(:sign) { "x" }
    example "创建标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
    end
  end

  patch "api/v1/tags/:id" do
    let(:tag) { Tag.create name: "tag", sign: "x", user_id: current_user.id }
    let(:id) { tag.id }

    parameter :name, "标签名"
    parameter :sign, "emoji 表情"
    with_options scope: :resource do
      response_field :id, "ID"
      response_field :name, "标签名"
      response_field :sign, "emoji 符号"
      response_field :user_id, "用户 ID"
      response_field :deleted_at, "删除时间"
    end

    let(:name) { "tag_modify" }
    let(:sign) { "y" }
    example "修改标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
    end
  end
end
