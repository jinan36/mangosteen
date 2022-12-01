class Item < ApplicationRecord
  enum kind: {expenses: 1, income: 2}
  validates :amount, presence: true
  validates :tags_id, presence: true
  validates :happen_at, presence: true

  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tag_ids = Tag.where(user_id: user_id).map(&:id)
    if tags_id & all_tag_ids != tags_id
      errors.add :tags_id, "不属于当前用户"
    end
  end
end
