class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: :true
  validates :address_1, presence: :true
  validates :city, presence: :true
  validates :state, presence: :true
  validates :country, presence: :true

  has_one_attached :picture

  has_many :favorites, dependent: :destroy
  has_many :favorited_properties, through: :favorites, source: :property

  has_many :resrvations, dependent: :destroy
  has_many :reserved_properties, through: :reservations, source: :property, dependent: :destroy

  has_many :payments, through: :reservations, dependent: :destroy

  def favorited_property?(property)
    favorited_properties.exists?(property.id)
  end
end
