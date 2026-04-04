class AmenityCategory < ApplicationRecord
  has_many :amenities, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :ordered, -> { order(:display_order) }
end
