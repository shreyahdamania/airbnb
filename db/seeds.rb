# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Property.create!({
  name: "Sample Property 1",
  description: "1 description",
  headline: "1 headline",
  address_1: "1 address_1",
  address_2: "1 address_2",
  city: "Mumbai",
  state: "Maharashtra",
  country: "India"
})

Property.create!({
  name: "Sample Property 2",
  description: "2 description",
  headline: "2 headline",
  address_1: "2 address_1",
  address_2: "2 address_2",
  city: "Jaipur",
  state: "Rajasthan",
  country: "India"
})

Property.create!({
  name: "Sample Property 3",
  description: "3 description",
  headline: "3 headline",
  address_1: "3 address_1",
  address_2: "3 address_2",
  city: "New York",
  state: "New York",
  country: "United States of America"
})
