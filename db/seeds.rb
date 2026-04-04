# Seed only PropertyAmenity records for existing properties and amenities.
# Idempotent: reruns update existing rows via upsert.

puts "Seeding property amenities..."

properties = Property.select(:id, :guest_count, :bedroom_count, :bathroom_count).to_a
amenity_ids_by_slug = Amenity.pluck(:slug, :id).to_h

if properties.empty? || amenity_ids_by_slug.empty?
  puts "Skipped: missing properties or amenities."
  return
end

base_probability_by_slug = {
  "wifi" => 0.98,
  "kitchen" => 0.94,
  "washer" => 0.70,
  "dryer" => 0.62,
  "essentials" => 0.96,
  "workspace" => 0.74,
  "ethernet" => 0.14,
  "tv" => 0.90,
  "streaming" => 0.63,
  "books" => 0.42,
  "hangers" => 0.86,
  "iron" => 0.58,
  "hair-dryer" => 0.75,
  "extra-pillows" => 0.78,
  "blackout-blinds" => 0.48,
  "free-parking" => 0.67,
  "paid-parking" => 0.17,
  "ev-charger" => 0.08,
  "lift" => 0.36,
  "gym" => 0.21,
  "smoke-alarm" => 0.97,
  "co-alarm" => 0.72,
  "fire-extinguisher" => 0.64,
  "first-aid-kit" => 0.57,
  "security-cameras" => 0.12,
  "lockbox" => 0.51,
  "bathtub" => 0.43,
  "hot-water" => 0.99,
  "shower-gel" => 0.82,
  "shampoo" => 0.84,
  "conditioner" => 0.72,
  "refrigerator" => 0.97,
  "microwave" => 0.86,
  "cooking-basics" => 0.89,
  "dishes-silverware" => 0.94,
  "dishwasher" => 0.46,
  "oven" => 0.69,
  "stove" => 0.88,
  "coffee-maker" => 0.65,
  "kettle" => 0.61,
  "toaster" => 0.52,
  "air-conditioning" => 0.58,
  "heating" => 0.84,
  "ceiling-fan" => 0.47,
  "fireplace" => 0.22,
  "pool" => 0.16,
  "hot-tub" => 0.09,
  "bbq-grill" => 0.29,
  "outdoor-dining" => 0.33,
  "garden" => 0.41,
  "beach-access" => 0.07,
  "waterfront" => 0.06,
  "mountain-view" => 0.13,
  "near-beach" => 0.19,
  "crib" => 0.17,
  "high-chair" => 0.16,
  "children-books" => 0.24,
  "pets-allowed" => 0.31
}

now = Time.current
rows = []

properties.each do |property|
  size_factor = [
    property.guest_count.to_i / 8.0,
    property.bedroom_count.to_i / 5.0,
    property.bathroom_count.to_i / 4.0
  ].sum / 3.0

  amenity_ids_by_slug.each do |slug, amenity_id|
    base_probability = base_probability_by_slug.fetch(slug, 0.40)

    adjusted_probability =
      case slug
      when "crib", "high-chair", "children-books"
        base_probability + (size_factor * 0.15)
      when "pool", "hot-tub", "gym", "fireplace", "waterfront", "mountain-view", "beach-access"
        base_probability + (size_factor * 0.08)
      when "free-parking", "paid-parking", "ev-charger"
        base_probability + (size_factor * 0.05)
      else
        base_probability
      end

    available = rand < adjusted_probability.clamp(0.02, 0.995)

    details =
      case slug
      when "ev-charger"
        available ? [ "Type 2", "7kW", "11kW" ].sample : nil
      when "security-cameras"
        available ? "Exterior cameras at entrance only" : nil
      when "workspace"
        available && rand < 0.35 ? "Desk + ergonomic chair in quiet room" : nil
      else
        nil
      end

    extra_cost =
      case slug
      when "paid-parking"
        available
      when "crib", "high-chair"
        available && rand < 0.20
      else
        false
      end

    rows << {
      property_id: property.id,
      amenity_id: amenity_id,
      available: available,
      details: details,
      extra_cost: extra_cost,
      created_at: now,
      updated_at: now
    }
  end
end

PropertyAmenity.upsert_all(rows, unique_by: :index_property_amenities_on_property_id_and_amenity_id)

puts "Done. #{rows.size} property_amenity rows upserted for #{properties.size} properties."
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# user = User.create!({
#   email: "test@gmail.com",
#   password: "123456"
# })

# 6.times do |i|
#   property = Property.create!({
#     name: Faker::Lorem.unique.sentence(word_count: 3),
#     description: Faker::Lorem.paragraph(sentence_count: 10),
#     headline: Faker::Lorem.unique.sentence(word_count: 6),
#     address_1: Faker::Address.street_address,
#     address_2: Faker::Address.street_name,
#     city: Faker::Address.city,
#     state: Faker::Address.state,
#     country: Faker::Address.country,
#     price: Money.from_amount((50..100).to_a.sample, "USD")
#   })

#   property.images.attach(io: File.open("db/images/property_#{i + 1}.png"), filename: property.name)
#   property.images.attach(io: File.open("db/images/property_#{i + 7}.png"), filename: property.name)

#   ((5..10).to_a.sample).times do
#     Review.create!({
#       content: Faker::Lorem.paragraph(sentence_count: 10),
#       cleanliness_rating: (1..5).to_a.sample,
#       accuracy_rating: (1..5).to_a.sample,
#       checkin_rating: (1..5).to_a.sample,
#       communication_rating: (1..5).to_a.sample,
#       location_rating: (1..5).to_a.sample,
#       value_rating: (1..5).to_a.sample,
#       property: property,
#       user: user
#     })
#   end
# end

# Property.all.each do |property|
#   5.times do |i|
#     property.images.attach(io: File.open("db/images/property_#{i + 13}.png"), filename: property.name)
#   end
# end

# Property.all.each do |property|
#   property.update!({
#     guest_count: (2..5).to_a.sample,
#     bedroom_count: (4..10).to_a.sample,
#     bed_count: (4..20).to_a.sample,
#     bathroom_count: (4..10).to_a.sample
#   })
# end

# property_description = <<-DESCRIPTION
# <div>Explore the nature and art oasis at our unique property. The living room, a cozy masterpiece, and the fully equipped kitchen are ideal for cooking and entertaining. Step outside to our garden patio, unwind, and enjoy morning birdsong. Tastefully decorated bedrooms, a powder room, and utility area complete the experience.<br />Note: The property is surrounded by a residential area. Despite initial surroundings, I am sure that, stepping in will fill your mood with joy and happiness.
# </div>
# <h4 class="font-medium" tabindex="-1">The space</h4>
# <p>Escape to a hidden gem in the heart of nature with our beautiful and artistic property. Our spacious and welcoming home is the perfect retreat for those looking to escape the hustle and bustle of the city and reconnect with nature.<br />As you enter through our beautifully adorned main gate with mandala art, you'll immediately feel a sense of peace and positive energy. The gate is an entryway to an amazing experience that is designed to help you unwind and relax.<br />Our living room is a work of art, with fascinating elements that create a cozy and unforgettable ambiance. The room features artistic designs, which are evident in the use of color, the decorations on the wall, and the unique furniture arrangement. The artistic flair adds a unique touch of elegance to the living room, making it the perfect place to spend time with family and friends. Our fully equipped kitchen is a modern open design with bamboo roofing, perfect for cooking and entertaining guests.<br />Step outside and experience the beauty of our garden patio, complete with a lush green view and the calming sounds of chirping birds in the morning. The patio is an extension of the living room, where you can enjoy your meals and relax in the fresh air. Fire up the barbecue in our cozy gazebo for a fun and relaxing evening with friends and family. The garden patio is the perfect place to unwind, read a book or just take a nap under the shade of a tree.<br />The bedrooms are spacious, comfortable, and tastefully decorated, with plenty of natural light, beautiful art pieces and a calming color scheme. The beds are comfortable, and the linens are soft and luxurious, providing you with the best possible sleeping experience.<br />Even our powder room and utility area have been designed with sustainability in mind. The utility area is a cleverly designed space that is efficient and has all the modern amenities required for your stay.<br />Note: The property is surrounded by a residential area. Despite initial surroundings, I am sure that, stepping in will fill your mood with joy and happiness.</p>
# <h4 class="font-medium" tabindex="-1">Guest Policy</h4>
# <p>Entire Property is yours!! Wish you fun and happy stay!!</p>
# DESCRIPTION

# Property.all.each do |property|
#   property.update!({
#     description: property_description
#   })
# end

# pictures = []
# 10.times do
# pictures << URI.parse(Faker::LoremFlickr.image).open
# end

# 10.times do |i|
#   random_user = User.create!({
#     email: "test#{i+3}@gmail.com",
#     password: "123456",
#     name: Faker::Lorem.unique.sentence(word_count: 3),
#     address_1: Faker::Address.street_address,
#     address_2: Faker::Address.street_name,
#     city: Faker::Address.city,
#     state: Faker::Address.state,
#     country: Faker::Address.country
#   })

#   random_user.picture.attach(io: pictures[i], filename: random_user.name)
# end

# Property.all.each do |property|
#   ((5..10).to_a.sample).times do
#     Review.create!({
#       content: Faker::Lorem.paragraph(sentence_count: 10),
#       cleanliness_rating: (1..5).to_a.sample,
#       accuracy_rating: (1..5).to_a.sample,
#       checkin_rating: (1..5).to_a.sample,
#       communication_rating: (1..5).to_a.sample,
#       location_rating: (1..5).to_a.sample,
#       value_rating: (1..5).to_a.sample,
#       property: property,
#       user: User.all.sample
#     })
#   end
# end

# db/seeds.rb
puts "Seeding amenity categories..."

categories = {
  basics: AmenityCategory.find_or_create_by!(slug: "basics") do |c|
    c.name = "Basics"
    c.display_order = 1
  end,
  bathroom: AmenityCategory.find_or_create_by!(slug: "bathroom") do |c|
    c.name = "Bathroom"
    c.display_order = 2
  end,
  bedroom_laundry: AmenityCategory.find_or_create_by!(slug: "bedroom-laundry") do |c|
    c.name = "Bedroom and laundry"
    c.display_order = 3
  end,
  entertainment: AmenityCategory.find_or_create_by!(slug: "entertainment") do |c|
    c.name = "Entertainment"
    c.display_order = 4
  end,
  family: AmenityCategory.find_or_create_by!(slug: "family") do |c|
    c.name = "Family"
    c.display_order = 5
  end,
  heating_cooling: AmenityCategory.find_or_create_by!(slug: "heating-cooling") do |c|
    c.name = "Heating and cooling"
    c.display_order = 6
  end,
  home_safety: AmenityCategory.find_or_create_by!(slug: "home-safety") do |c|
    c.name = "Home safety"
    c.display_order = 7
  end,
  internet_office: AmenityCategory.find_or_create_by!(slug: "internet-office") do |c|
    c.name = "Internet and office"
    c.display_order = 8
  end,
  kitchen_dining: AmenityCategory.find_or_create_by!(slug: "kitchen-dining") do |c|
    c.name = "Kitchen and dining"
    c.display_order = 9
  end,
  location: AmenityCategory.find_or_create_by!(slug: "location") do |c|
    c.name = "Location features"
    c.display_order = 10
  end,
  outdoor: AmenityCategory.find_or_create_by!(slug: "outdoor") do |c|
    c.name = "Outdoor"
    c.display_order = 11
  end,
  parking: AmenityCategory.find_or_create_by!(slug: "parking-facilities") do |c|
    c.name = "Parking and facilities"
    c.display_order = 12
  end
}

puts "Seeding amenities..."

amenities_data = [
  # --- Basics (shown first in preview) ---
  { slug: "wifi",             name: "Wifi",                    category: :basics,          priority: 10 },
  { slug: "kitchen",          name: "Kitchen",                 category: :basics,          priority: 20 },
  { slug: "washer",           name: "Washer",                  category: :basics,          priority: 30 },
  { slug: "dryer",            name: "Dryer",                   category: :basics,          priority: 40 },
  { slug: "essentials",       name: "Essentials",              category: :basics,          priority: 50,
    always_shown_if_absent: false,
    absence_description: "Essentials such as towels, bed sheets, soap, and toilet paper are not provided." },

  # --- Internet and office ---
  { slug: "workspace",        name: "Dedicated workspace",     category: :internet_office, priority: 60 },
  { slug: "ethernet",         name: "Ethernet connection",     category: :internet_office, priority: 160 },

  # --- Entertainment ---
  { slug: "tv",               name: "TV",                      category: :entertainment,   priority: 70 },
  { slug: "streaming",        name: "Streaming services",      category: :entertainment,   priority: 170 },
  { slug: "books",            name: "Books and reading material", category: :entertainment, priority: 180 },

  # --- Bedroom and laundry ---
  { slug: "hangers",          name: "Hangers",                 category: :bedroom_laundry, priority: 80 },
  { slug: "iron",             name: "Iron",                    category: :bedroom_laundry, priority: 90 },
  { slug: "hair-dryer",       name: "Hair dryer",              category: :bedroom_laundry, priority: 100 },
  { slug: "extra-pillows",    name: "Extra pillows and blankets", category: :bedroom_laundry, priority: 190 },
  { slug: "blackout-blinds",  name: "Room-darkening shades",   category: :bedroom_laundry, priority: 200 },

  # --- Parking and facilities ---
  { slug: "free-parking",     name: "Free parking on premises", category: :parking,        priority: 110 },
  { slug: "paid-parking",     name: "Paid parking on premises", category: :parking,        priority: 210 },
  { slug: "ev-charger",       name: "EV charger",              category: :parking,         priority: 220 },
  { slug: "lift",             name: "Lift",                    category: :parking,         priority: 120 },
  { slug: "gym",              name: "Gym",                     category: :parking,         priority: 230 },

  # --- Home safety (always shown if absent for alarms) ---
  { slug: "smoke-alarm",      name: "Smoke alarm",             category: :home_safety,     priority: 130,
    always_shown_if_absent: true,
    absence_description: "There is no smoke alarm on the property." },
  { slug: "co-alarm",         name: "Carbon monoxide alarm",   category: :home_safety,     priority: 140,
    always_shown_if_absent: true,
    absence_description: "There is no carbon monoxide alarm on the property." },
  { slug: "fire-extinguisher", name: "Fire extinguisher",      category: :home_safety,     priority: 240 },
  { slug: "first-aid-kit",    name: "First aid kit",           category: :home_safety,     priority: 250 },
  { slug: "security-cameras", name: "Security cameras on property", category: :home_safety, priority: 150 },
  { slug: "lockbox",          name: "Lockbox",                 category: :home_safety,     priority: 260 },

  # --- Bathroom ---
  { slug: "bathtub",          name: "Bathtub",                 category: :bathroom,        priority: 270, searchable: true },
  { slug: "hot-water",        name: "Hot water",               category: :bathroom,        priority: 280 },
  { slug: "shower-gel",       name: "Body soap",               category: :bathroom,        priority: 290 },
  { slug: "shampoo",          name: "Shampoo",                 category: :bathroom,        priority: 300 },
  { slug: "conditioner",      name: "Conditioner",             category: :bathroom,        priority: 310 },

  # --- Kitchen and dining ---
  { slug: "refrigerator",     name: "Refrigerator",            category: :kitchen_dining,  priority: 320 },
  { slug: "microwave",        name: "Microwave",               category: :kitchen_dining,  priority: 330 },
  { slug: "cooking-basics",   name: "Cooking basics",          category: :kitchen_dining,  priority: 340 },
  { slug: "dishes-silverware", name: "Dishes and silverware",  category: :kitchen_dining,  priority: 350 },
  { slug: "dishwasher",       name: "Dishwasher",              category: :kitchen_dining,  priority: 360 },
  { slug: "oven",             name: "Oven",                    category: :kitchen_dining,  priority: 370 },
  { slug: "stove",            name: "Stove",                   category: :kitchen_dining,  priority: 380 },
  { slug: "coffee-maker",     name: "Coffee maker",            category: :kitchen_dining,  priority: 390 },
  { slug: "kettle",           name: "Electric kettle",         category: :kitchen_dining,  priority: 400 },
  { slug: "toaster",          name: "Toaster",                 category: :kitchen_dining,  priority: 410 },

  # --- Heating and cooling ---
  { slug: "air-conditioning",  name: "Air conditioning",       category: :heating_cooling,  priority: 420, searchable: true },
  { slug: "heating",           name: "Heating",                category: :heating_cooling,  priority: 430 },
  { slug: "ceiling-fan",       name: "Ceiling fan",            category: :heating_cooling,  priority: 440 },
  { slug: "fireplace",         name: "Indoor fireplace",       category: :heating_cooling,  priority: 450, searchable: true },

  # --- Outdoor ---
  { slug: "pool",              name: "Pool",                   category: :outdoor,          priority: 460, searchable: true },
  { slug: "hot-tub",           name: "Hot tub",                category: :outdoor,          priority: 470, searchable: true },
  { slug: "bbq-grill",         name: "BBQ grill",              category: :outdoor,          priority: 480 },
  { slug: "outdoor-dining",    name: "Outdoor dining area",    category: :outdoor,          priority: 490 },
  { slug: "garden",            name: "Garden or backyard",     category: :outdoor,          priority: 500 },
  { slug: "beach-access",      name: "Beach access",           category: :outdoor,          priority: 510, searchable: true },

  # --- Location features ---
  { slug: "waterfront",        name: "Waterfront",             category: :location,         priority: 520, searchable: true },
  { slug: "mountain-view",     name: "Mountain view",          category: :location,         priority: 530 },
  { slug: "near-beach",        name: "Near beach (within 1km)", category: :location,        priority: 540 },

  # --- Family ---
  { slug: "crib",              name: "Crib",                   category: :family,           priority: 550, searchable: true },
  { slug: "high-chair",        name: "High chair",             category: :family,           priority: 560 },
  { slug: "children-books",    name: "Children's books and toys", category: :family,        priority: 570 },
  { slug: "pets-allowed",      name: "Pets allowed",           category: :family,           priority: 580, searchable: true }
]

amenities_data.each do |data|
  Amenity.find_or_create_by!(slug: data[:slug]) do |a|
    a.name                   = data[:name]
    a.amenity_category       = categories[data[:category]]
    a.display_priority       = data[:priority]
    a.always_shown_if_absent = data.fetch(:always_shown_if_absent, false)
    a.absence_description    = data[:absence_description]
    a.searchable             = data.fetch(:searchable, true)
  end
end

puts "Done. #{AmenityCategory.count} categories, #{Amenity.count} amenities seeded."

puts "Seeding property amenities..."

properties = Property.select(:id, :guest_count, :bedroom_count, :bathroom_count).to_a
amenity_ids_by_slug = Amenity.pluck(:slug, :id).to_h

if properties.empty? || amenity_ids_by_slug.empty?
  puts "Skipped PropertyAmenity seeding: missing properties or amenities."
else
  # Availability weights tuned for realistic listing distribution.
  base_probability_by_slug = {
    "wifi" => 0.98,
    "kitchen" => 0.94,
    "washer" => 0.70,
    "dryer" => 0.62,
    "essentials" => 0.96,
    "workspace" => 0.74,
    "ethernet" => 0.14,
    "tv" => 0.90,
    "streaming" => 0.63,
    "books" => 0.42,
    "hangers" => 0.86,
    "iron" => 0.58,
    "hair-dryer" => 0.75,
    "extra-pillows" => 0.78,
    "blackout-blinds" => 0.48,
    "free-parking" => 0.67,
    "paid-parking" => 0.17,
    "ev-charger" => 0.08,
    "lift" => 0.36,
    "gym" => 0.21,
    "smoke-alarm" => 0.97,
    "co-alarm" => 0.72,
    "fire-extinguisher" => 0.64,
    "first-aid-kit" => 0.57,
    "security-cameras" => 0.12,
    "lockbox" => 0.51,
    "bathtub" => 0.43,
    "hot-water" => 0.99,
    "shower-gel" => 0.82,
    "shampoo" => 0.84,
    "conditioner" => 0.72,
    "refrigerator" => 0.97,
    "microwave" => 0.86,
    "cooking-basics" => 0.89,
    "dishes-silverware" => 0.94,
    "dishwasher" => 0.46,
    "oven" => 0.69,
    "stove" => 0.88,
    "coffee-maker" => 0.65,
    "kettle" => 0.61,
    "toaster" => 0.52,
    "air-conditioning" => 0.58,
    "heating" => 0.84,
    "ceiling-fan" => 0.47,
    "fireplace" => 0.22,
    "pool" => 0.16,
    "hot-tub" => 0.09,
    "bbq-grill" => 0.29,
    "outdoor-dining" => 0.33,
    "garden" => 0.41,
    "beach-access" => 0.07,
    "waterfront" => 0.06,
    "mountain-view" => 0.13,
    "near-beach" => 0.19,
    "crib" => 0.17,
    "high-chair" => 0.16,
    "children-books" => 0.24,
    "pets-allowed" => 0.31
  }

  now = Time.current
  rows = []

  properties.each do |property|
    size_factor = [
      property.guest_count.to_i / 8.0,
      property.bedroom_count.to_i / 5.0,
      property.bathroom_count.to_i / 4.0
    ].sum / 3.0

    amenity_ids_by_slug.each do |slug, amenity_id|
      base_probability = base_probability_by_slug.fetch(slug, 0.40)

      adjusted_probability =
        case slug
        when "crib", "high-chair", "children-books"
          base_probability + (size_factor * 0.15)
        when "pool", "hot-tub", "gym", "fireplace", "waterfront", "mountain-view", "beach-access"
          base_probability + (size_factor * 0.08)
        when "free-parking", "paid-parking", "ev-charger"
          base_probability + (size_factor * 0.05)
        else
          base_probability
        end

      available = rand < adjusted_probability.clamp(0.02, 0.995)

      details =
        case slug
        when "ev-charger"
          available ? [ "Type 2", "7kW", "11kW" ].sample : nil
        when "security-cameras"
          available ? "Exterior cameras at entrance only" : nil
        when "workspace"
          available && rand < 0.35 ? "Desk + ergonomic chair in quiet room" : nil
        else
          nil
        end

      extra_cost =
        case slug
        when "paid-parking"
          available
        when "crib", "high-chair"
          available && rand < 0.20
        else
          false
        end

      rows << {
        property_id: property.id,
        amenity_id: amenity_id,
        available: available,
        details: details,
        extra_cost: extra_cost,
        created_at: now,
        updated_at: now
      }
    end
  end

  PropertyAmenity.upsert_all(rows, unique_by: :index_property_amenities_on_property_id_and_amenity_id)
  puts "Done. #{rows.size} property_amenity rows upserted for #{properties.size} properties."
end
