class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.date :checkin_date
      t.date :checkout_date

      add_index :reservations, [:user_id, :property_id, :checkin_date, :checkout_date], unique: true, name: "add_index_to_reservations"

      t.timestamps
    end
  end
end
