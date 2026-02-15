module Properties
  class FavoritesController < ApplicationController
    before_action :require_login
    before_action :set_property

    def create
      favorite = current_user.favorites.find_or_create_by(property: @property)

      if favorite.persisted?
        render json: { active: true }
      else
        render json: { error: "Could not favorite property" }, status: :unprocessable_entity
      end
    end

    def destroy
      favorite = current_user.favorites.find_by(property: @property)
      favorite&.destroy

      render json: { active: false }
    end

    private

    def set_property
      @property = Property.find_by(id: params[:property_id])
      return head :not_found if @property.blank?
    end

    def require_login
      return if user_signed_in?

      store_location_for(:user, request.referer || root_path)

      if params[:property_id].present?
        session[:pending_wishlist_property_id] = params[:property_id]
      end

      respond_to do |format|
        format.json do
          render json: { redirect_url: new_user_session_path }, status: :unauthorized
        end
        format.html do
          redirect_to new_user_session_path, alert: "You need to sign in to use the wishlist."
        end
      end
      return
    end
  end
end
