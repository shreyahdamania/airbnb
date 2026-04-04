class CreateAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :amenities do |t|
      t.references :amenity_category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :display_priority, null: false, default: 999
      t.boolean :always_shown_if_absent, null: false, default: false
      t.string :absence_description
      t.boolean :searchable, null: false, default: true

      t.timestamps
    end

    add_index :amenities, :slug, unique: true
    add_index :amenities, :display_priority
    add_index :amenities, :always_shown_if_absent
  end
end
