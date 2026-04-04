class CreatePropertyAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :property_amenities do |t|
      t.references :property, null: false, foreign_key: true
      t.references :amenity, null: false, foreign_key: true
      t.boolean :available, null: false, default: false
      t.string :details
      t.boolean :extra_cost, null: false, default: false

      t.timestamps
    end

    add_index :property_amenities, [ :property_id, :amenity_id ], unique: true
  end
end
