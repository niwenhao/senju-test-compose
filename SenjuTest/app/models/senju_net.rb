class SenjuNet < ApplicationRecord
  NAME = 0
  AVA_DATE = 1
  DESC = 3
  TYPE = 4
  REF_NAME = 5
  EXEC_ENV = 9

  TRIGER_START = 14
  TRIGER_COUNT = 32

  PRECEDE_START = 46
  PRECEDE_COUNT = 32

  SENJU_TYPE = "ネット"

  belongs_to :senjuEnv, optional: true
  belongs_to :preExec, polymorphic: true, dependent: :destroy, optional: true
  belongs_to :postExec, polymorphic: true, dependent: :destroy, optional: true
  has_many :netReferences, dependent: :destroy, foreign_key: "senjuNet_id"

  alias :refs :netReferences
end
