class AddStripeCheckoutSessionIdToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :stripe_checkout_session_id, :string
    add_index :payments, :stripe_checkout_session_id, unique: true
  end
end
