class NetReference < ApplicationRecord
  belongs_to :senjuNet
  belongs_to :senjuObject, polymorphic: true
  belongs_to :senjuEnv, optional: true
  has_many :leftLink, class_name: "SenjuSuccession", foreign_key: "right_id", dependent: :destroy
  has_many :rightLink, class_name: "SenjuSuccession", foreign_key: "left_id", dependent: :destroy
  has_many :left, class_name: "NetReference", through: :leftLink
  has_many :right, class_name: "NetReference", through: :rightLink
end
