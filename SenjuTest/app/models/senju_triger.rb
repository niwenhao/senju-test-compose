class SenjuTriger < ApplicationRecord
  include Senju::TestCase::RunnerHelper::ExecEnvDigger

  NAME = 0
  NODE = 2
  PATH = 3
  DESC = 10

  SENJU_TYPE = "トリガ"

  belongs_to :senjuEnv, optional: true
  belongs_to :postExec, polymorphic: true, dependent: :destroy, optional: true
end
