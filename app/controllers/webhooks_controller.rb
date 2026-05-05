class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid Stripe webhook payload: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook signature verification failed: #{e.message}")
      return head :bad_request
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      metadata = session.metadata

      ActiveRecord::Base.transaction do
        property = Property.find(metadata["property_id"])
        checkin_date = Date.parse(metadata["checkin_date"])
        checkout_date = Date.parse(metadata["checkout_date"])

        reservation = Reservation.find_or_create_by!(
          user_id: metadata["user_id"],
          property_id: property.id,
          checkin_date: checkin_date,
          checkout_date: checkout_date
        )

        payment = Payment.find_or_initialize_by(stripe_checkout_session_id: session.id)
        payment.reservation = reservation
        payment.base_fare_cents = metadata["base_fare"].to_i
        payment.base_fare_currency = "USD"
        payment.service_fee_ratio = metadata["service_fee_ratio"].to_d
        payment.total_amount_cents = metadata["total_amount"].to_i
        payment.total_amount_currency = "USD"
        payment.save!
      end
    when "checkout.session.async_payment_succeeded"
      session = event.data.object
      Rails.logger.info("Stripe async payment succeeded for session #{session.id}")

    when "checkout.session.async_payment_failed"
      session = event.data.object
      Rails.logger.warn("Stripe async payment failed for session #{session.id}")

    else
      Rails.logger.info("Unhandled Stripe webhook event type: #{event.type}")
    end

    render json: { message: "success" }
  rescue StandardError => e
    Rails.logger.error("Stripe webhook processing error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    head :internal_server_error
  end
end
