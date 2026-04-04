class PropertyAmenity < ApplicationRecord
  belongs_to :property
  belongs_to :amenity

  validates :amenity_id, uniqueness: { scope: :property_id, message: "has already been added to the property" }
  validates :available, inclusion: { in: [ true, false ] }

  delegate :name, to: :amenity, prefix: false, allow_nil: false
  delegate :slug, to: :amenity, prefix: false, allow_nil: false
  delegate :absence_description, to: :amenity, prefix: false, allow_nil: false
  delegate :always_shown_if_absent, to: :amenity, prefix: false, allow_nil: false
  delegate :amenity_category, to: :amenity, prefix: false, allow_nil: false
end
