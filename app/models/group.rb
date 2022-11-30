class Group < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :kind, presence: true, inclusion: { in: %w[income expense] }
  validates :user_id, presence: true
end
