require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "获取账目" do
    it "分页未登录" do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }

      get "/api/v1/items"
      expect(response).to have_http_status 401
    end
    it "分页" do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }

      get "/api/v1/items", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "按时间筛选" do
      user = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-02", user_id: user.id
      item2 = Item.create amount: 100, created_at: "2018-01-02", user_id: user.id
      Item.create amount: 100, created_at: "2019-01-01", user_id: user.id

      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "按时间筛选（边界）" do
      user = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user.id
      item2 = Item.create amount: 100, created_at: "2018-01-02", user_id: user.id
      Item.create amount: 100, created_at: "2019-01-01", user_id: user.id

      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-02", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "按时间筛选（只传起始时间）" do
      user = User.create email: "1@qq.com"
      Item.create amount: 100, created_at: "2017-12-31", user_id: user.id
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user.id
      item2 = Item.create amount: 100, created_at: "2019-01-01", user_id: user.id

      get "/api/v1/items?created_after=2018-01-01", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "按时间筛选（只传结束时间）" do
      user = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user.id
      item2 = Item.create amount: 100, created_at: "2019-01-01", user_id: user.id
      Item.create amount: 100, created_at: "2019-01-02", user_id: user.id

      get "/api/v1/items?created_before=2019-01-01", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
  end
  describe "创建账目" do
    it "未登录" do
      post "/api/v1/items", params: {amount: 100}
      expect(response).to have_http_status 401
    end
    it "创建" do
      user = User.create email: "1@qq.com"

      expect {
        post("/api/v1/items", params: {amount: 100, tags_id: [1, 2], happen_at: "2018-01-01T00:00:00+08:00"}, headers: user.generate_auth_header)
      }.to change { Item.count }.by 1
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resource"]["id"]).to be_a Numeric
      expect(json["resource"]["user_id"]).to eq user.id
      expect(json["resource"]["amount"]).to eq 100
      expect(json["resource"]["happen_at"]).to eq "2017-12-31T16:00:00.000Z"
    end
    it "amount、tags_id、happen_at 必填" do
      user = User.create email: "1@qq.com"

      post("/api/v1/items", params: {}, headers: user.generate_auth_header)
      expect(response).to have_http_status 422
      json = JSON.parse(response.body)
      expect(json["errors"]["amount"][0]).to eq "can't be blank"
      expect(json["errors"]["tags_id"][0]).to eq "can't be blank"
      expect(json["errors"]["happen_at"][0]).to eq "can't be blank"
    end
  end
end
