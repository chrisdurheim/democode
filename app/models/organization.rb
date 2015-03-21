class Organization < ActiveRecord::Base
  has_many :users, inverse_of: :organization
  validates :name, presence: true
end
