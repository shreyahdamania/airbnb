class AddReservationIntegrityConstraints < ActiveRecord::Migration[8.0]
  def change
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    change_column_null :reservations, :checkin_date, false
    change_column_null :reservations, :checkout_date, false

    add_check_constraint :reservations,
                         "checkout_date > checkin_date",
                         name: "reservations_checkout_after_checkin"

    add_exclusion_constraint :reservations,
                             "property_id WITH =, daterange(checkin_date, checkout_date, '[)') WITH &&",
                             using: :gist,
                             name: "reservations_no_overlapping_dates_per_property"
  end
end
