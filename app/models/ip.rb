class Ip < ApplicationRecord
  belongs_to :user
  validates :ip, uniqueness: {scope: [:ip, :user_id]}
end
