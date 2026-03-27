class Property < ApplicationRecord
  validates :name, presence: :true
  validates :description, presence: :true
  validates :headline, presence: :true
  validates :address_1, presence: :true
  validates :address_2, presence: :true
  validates :city, presence: :true
  validates :state, presence: :true
  validates :country, presence: :true

  monetize :price_cents, allow_nil: true

  has_many_attached :images

  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user

  has_many :reservations, dependent: :destroy
  has_many :reserved_users, through: :reservations, source: :user, dependent: :destroy

  has_rich_text :description

  def recalculate_average_final_rating
    update_column(:average_final_rating, reviews.average(:final_rating))
  end

  def display_average_rating
    average_final_rating&.round(1) || "—"
  end

  def final_rating_distribution
    default_rating_distribution = { 5 => 0, 4 =>0, 3 => 0, 2=> 0, 1=> 0 }
    rating_distribution = reviews.group("ROUND(final_rating)").count.transform_keys(&:to_i)
    default_rating_distribution.merge(rating_distribution)
  end

  def average_cleanliness_rating
    reviews.average(:cleanliness_rating)
  end

  def average_accuracy_rating
    reviews.average(:accuracy_rating)
  end

  def average_checkin_rating
    reviews.average(:checkin_rating)
  end

  def average_communication_rating
    reviews.average(:communication_rating)
  end

  def average_location_rating
    reviews.average(:location_rating)
  end

  def average_value_rating
    reviews.average(:value_rating)
  end

  def available_dates
    current_reservation = reservations.current_reservations.first
    next_reservation = reservations.upcoming_reservations.first

    # if no current and no next
    if current_reservation.nil? && next_reservation.nil?
      Date.tomorrow.strftime("%e %b")..(Date.tomorrow + 30.days).strftime("%e %b")
    # if no current but next
    elsif current_reservation.nil?
      Date.tomorrow.strftime("%e %b")..next_reservation.checkin_date.strftime("%e %b")
    # if current but no next
    elsif next_reservation.nil?
      current_reservation.checkout_date.strftime("%e %b")..(Date.tomorrow + 30.days).strftime("%e %b")
    # if current and next
    else
      current_reservation.checkout_date.strftime("%e %b")..next_reservation.checkin_date.strftime("%e %b")
    end
  end
end
