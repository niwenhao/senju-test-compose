class SenjuSuccession < ApplicationRecord
  belongs_to :left, class_name: NetReference, dependent: :destroy
  belongs_to :right, class_name: NetReference, dependent: :destroy
  belongs_to :task, polymorphic: true, dependent: :destroy, optional: true

  def find_exec_env(config, hctx)
    sctx = config.exec_envs.by_succession[left.senjuNet.name][left.senjuObject.name][right.senjuObject.name]

    if sctx.nil? then
      hctx
    else
      TestContext.new(host: sctx.host, user: sctx.user)
    end
  end
end
