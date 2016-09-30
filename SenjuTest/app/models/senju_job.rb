class SenjuJob < ApplicationRecord
    NAME = 0
    EXEC_ENV = 1
    EXPECTED = 2
    CMD = 3
    DESC = 4

    SENJU_TYPE = "ジョブ"

    belongs_to :senjuEnv, optional: true
    belongs_to :preExec, polymorphic: true, dependent: :destroy, optional: true
    belongs_to :postExec, polymorphic: true, dependent: :destroy, optional: true
end
