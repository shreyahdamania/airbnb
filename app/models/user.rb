class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :favorites, dependent: :destroy
  has_many :favorited_properties, through: :favorites, source: :property

  has_many :resrvations, dependent: :destroy
  has_many :reserved_properties, through: :reservations, source: :property, dependent: :destroy

  def favorited_property?(property)
    favorited_properties.exists?(property)
  end
end
