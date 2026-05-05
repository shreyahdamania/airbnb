class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    checkout_params = booking_checkout_params
    @property = Property.find(checkout_params[:property_id])
    checkin_date = Date.parse(checkout_params[:checkin_date].to_s)
    checkout_date = Date.parse(checkout_params[:checkout_date].to_s)
    unless Reservation.available_for_property?(
      property_id: @property.id,
      checkin_date: checkin_date,
      checkout_date: checkout_date
    )
      redirect_to property_path(@property), alert: "Selected dates are unavailable. Please choose new dates."
      return
    end

    nights = (checkout_date - checkin_date).to_i
    service_fee_ratio = 0.18
    base_fare = @property.price_cents * nights
    total_amount = (base_fare + (base_fare * service_fee_ratio)).to_i

    @user = current_user

    # p @property
    # p checkin_date
    # p checkout_date
    # p nights
    # p service_fee_ratio
    # p base_fare
    # p total_amount


    stripe_price = Stripe::Price.create({
      currency: "usd",
      unit_amount: total_amount,
      product_data: {
        name: @property.name
      }
    })

    success_url = url_for(
      controller: "checkouts",
      action: "success",
      only_path: false
    )

    cancel_url = url_for(
      controller: "checkouts",
      action: "cancel",
      only_path: false
    )

    session = Stripe::Checkout::Session.create({
      mode: "payment",
      line_items: [
        {
          price: stripe_price.id,
          quantity: 1
        }
      ],
      success_url: success_url,
      cancel_url: cancel_url,

      metadata: {
        property_id: @property.id,
        user_id: @user.id,
        checkin_date: checkin_date.to_s,
        checkout_date: checkout_date.to_s,
        total_amount: total_amount.to_s,
        base_fare: base_fare.to_s,
        service_fee_ratio: service_fee_ratio.to_s
      }
    })

    redirect_to session.url, allow_other_host: true, status: 303
  rescue ArgumentError
    redirect_to property_path(@property || checkout_params[:property_id]), alert: "Selected dates are invalid. Please choose new dates."
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end

  private

  def booking_checkout_params
    params.require(:checkout).permit(
      :property_id,
      :checkin_date,
      :checkout_date,
      :user_id
    )
  end
end
