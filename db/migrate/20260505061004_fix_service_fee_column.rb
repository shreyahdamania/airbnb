class FixServiceFeeColumn < ActiveRecord::Migration[8.0]
  def change
    remove_column :payments, :servide_fee_cents, :integer
    remove_column :payments, :servide_fee_currency, :string

    add_column :payments, :service_fee_ratio, :decimal, precision: 5, scale: 4, default: 0.0
  end
end
