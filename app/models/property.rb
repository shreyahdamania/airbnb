class Property < ApplicationRecord
  validates :name, presence: :true
  validates :description, presence: :true
  validates :headline, presence: :true
  validates :address_1, presence: :true
  validates :address_2, presence: :true
  validates :city, presence: :true
  validates :state, presence: :true
  validates :country, presence: :true
end
