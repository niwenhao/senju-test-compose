class SenjuSuccession < ApplicationRecord
  belongs_to :left, class_name: NetReference, dependent: :destroy
  belongs_to :right, class_name: NetReference, dependent: :destroy
  belongs_to :task, polymorphic: true, dependent: :destroy, optional: true
end
