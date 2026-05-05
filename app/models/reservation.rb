class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :property

  has_one :payment

  validates :checkin_date, presence: true
  validates :checkout_date, presence: true
  validate :checkout_after_checkin
  validate :checkin_not_in_past
  validate :no_overlapping_reservation

  scope :upcoming_reservations, -> { where("checkin_date > ?", Date.today).order(:checkin_date) }
  scope :current_reservations, -> { where("checkout_date > ?", Date.today).where("checkin_date < ?", Date.today).order(:checkout_date) }
  scope :overlapping_range, ->(checkin_date, checkout_date) { where("checkin_date < ? AND checkout_date > ?", checkout_date, checkin_date) }

  def self.valid_date_range?(checkin_date, checkout_date)
    return false if checkin_date.blank? || checkout_date.blank?
    return false if checkin_date < Date.tomorrow

    checkout_date > checkin_date
  end

  def self.available_for_property?(property_id:, checkin_date:, checkout_date:, excluding_reservation_id: nil)
    return false unless valid_date_range?(checkin_date, checkout_date)
    return false if property_id.blank?

    conflicts = where(property_id: property_id).overlapping_range(checkin_date, checkout_date)
    conflicts = conflicts.where.not(id: excluding_reservation_id) if excluding_reservation_id.present?
    conflicts.none?
  end

  private

  def checkout_after_checkin
    return if checkin_date.blank? || checkout_date.blank?
    return if checkout_date > checkin_date

    errors.add(:checkout_date, "must be after check-in date")
  end

  def checkin_not_in_past
    return if checkin_date.blank?
    return if checkin_date >= Date.tomorrow

    errors.add(:checkin_date, "must be tomorrow or later")
  end

  def no_overlapping_reservation
    return if Reservation.available_for_property?(
      property_id: property_id,
      checkin_date: checkin_date,
      checkout_date: checkout_date,
      excluding_reservation_id: id
    )

    errors.add(:base, "Selected dates overlap with an existing reservation")
  end
end
