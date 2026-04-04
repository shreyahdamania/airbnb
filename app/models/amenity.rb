class Amenity < ApplicationRecord
  belongs_to :amenity_category

  has_many :property_amenities, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :display_priority, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(:display_priority) }
  scope :always_shown_if_absent, -> { where(always_shown_if_absent: true) }
end
