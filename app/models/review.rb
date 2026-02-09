class Review < ApplicationRecord
  belongs_to :user
  belongs_to :property, counter_cache: true

  validates :content, presence: :true
  validates :cleanliness_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :accuracy_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :checkin_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :communication_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :location_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :value_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  before_save :set_final_rating
  after_commit :update_property_average_rating, on: [ :create, :update, :destroy ]

  def set_final_rating
    self.final_rating =
      (cleanliness_rating +
      accuracy_rating +
      checkin_rating +
      communication_rating +
      location_rating +
      value_rating).to_f / 6
  end

  def update_property_average_rating
    property.recalculate_average_final_rating
  end
end
