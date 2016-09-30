class SenjuTriger < ApplicationRecord
    NAME = 0
    NODE = 2
    PATH = 3
    DESC = 10

    SENJU_TYPE = "トリガ"

  belongs_to :postExec, polymorphic: true, dependent: :destroy, optional: true
end
