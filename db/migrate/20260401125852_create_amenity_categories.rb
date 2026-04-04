class CreateAmenityCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :amenity_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :display_order, null: false, default: 0

      t.timestamps
    end

    add_index :amenity_categories, :slug, unique: true
    add_index :amenity_categories, :display_order
  end
end
