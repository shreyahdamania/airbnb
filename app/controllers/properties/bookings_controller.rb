module Properties
  class BookingsController < ApplicationController
    before_action :authenticate_user!

    def new
      @property = Property.find(params[:property_id])
      @checkin_date, @checkout_date = parse_booking_dates

      unless booking_dates_valid_for_property?(@property, @checkin_date, @checkout_date)
        redirect_to property_path(@property), alert: "Selected dates are unavailable. Please choose new dates."
        return
      end

      @total_nights = number_of_nights(@checkin_date, @checkout_date)

      @base_fare = @property.price * @total_nights
      @service_fee = @base_fare * 0.18
      @total_amount = @base_fare + @service_fee
    end

    private

    def parse_booking_dates
      checkin_date = Date.parse(params[:checkin_date].to_s)
      checkout_date = Date.parse(params[:checkout_date].to_s)
      [ checkin_date, checkout_date ]
    rescue ArgumentError, TypeError
      [ nil, nil ]
    end

    def number_of_nights(checkin_date, checkout_date)
      (checkout_date - checkin_date).to_i
    end

    def booking_dates_valid_for_property?(property, checkin_date, checkout_date)
      Reservation.available_for_property?(
        property_id: property.id,
        checkin_date: checkin_date,
        checkout_date: checkout_date
      )
    end
  end
end
