class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :reservation, null: false, foreign_key: true
      t.monetize :base_fare, amount: { null: true, default: nil }, currency: { null: true, default: nil }
      t.monetize :servide_fee, amount: { null: true, default: nil }, currency: { null: true, default: nil }
      t.monetize :total_amount, amount: { null: true, default: nil }, currency: { null: true, default: nil }

      t.timestamps
    end
  end
end
