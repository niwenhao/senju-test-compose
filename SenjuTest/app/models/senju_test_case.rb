class SenjuTestCase < ApplicationRecord
  belongs_to :preTask, polymorphic: true
  belongs_to :postTask, polymorphic: true
end
