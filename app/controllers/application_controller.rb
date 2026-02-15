class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    handle_pending_wishlist(resource)
    stored_location_for(resource) || super
  end

  private

  def handle_pending_wishlist(user)
    property_id = session.delete(:pending_wishlist_property_id)
    return if property_id.blank?

    property = Property.find_by(id: property_id)
    return if property.blank?

    Favorite.find_or_create_by(user: user, property: property)
  end
end
