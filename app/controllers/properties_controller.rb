class PropertiesController < ApplicationController
    def show
      @property = Property
                    .includes(:reservations, property_amenities: { amenity: :amenity_category })
                    .find(params[:id])
    end
end
