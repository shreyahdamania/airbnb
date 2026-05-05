class Payment < ApplicationRecord
  belongs_to :reservation

  monetize :base_fare_cents, allow_nil: false
  monetize :total_amount_cents, allow_nil: false

  validates :stripe_checkout_session_id, presence: true, uniqueness: true
end
