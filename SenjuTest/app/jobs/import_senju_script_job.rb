class ImportSenjuScriptJob < ApplicationJob
  include OsSupport::Shell

  queue_as :default

  LOG = Logger.new(STDOUT)
  LOG.progname = "ImportSenjuScriptJob"
  LOG.level = $LOG_LEVEL

  WORK_DIR="work/jar"

  def perform(*args)
    @inputJar = args[0]
    LOG.info { "Import jar file => #{@inputJar}" }

    SenjuNet.delete_all()
    SenjuJob.delete_all()
    SenjuTriger.delete_all()
    ShellTask.delete_all()
    SenjuSuccession.delete_all()
    NetReference.delete_all()

    LOG.info { "extrace_jar to #{WORK_DIR}" }
    extrace_jar()

    LOG.info { "稼動環境定義を取り込み" }
    import_env

    LOG.info { "トリガ定義を取り込み" }
    import_triger

    LOG.info { "ジョブ定義を取り込み" }
    import_job

    LOG.info { "ネット定義を取り込み" }
    pre_import_net
    import_net
  end

  def pre_import_net
    last_net_name = ""
    import_object "#{WORK_DIR}/ネット.定義有効日.txt" do |items|
      net_name = items[SenjuNet::NAME]
      if net_name != "" && net_name != last_net_name then
        e = SenjuNet.new(name: net_name)
        raise "Failed to save => #{e.errors.full_messages}"  unless e.save
        last_net_name = net_name
      end
    end
  end

  def import_object(path)
    LOG.info { "ファイル(#{path})を取り込み" }
    File::readable?(path) or raise "Failed to open #{path}"

    first_line = true

    f = File.open(path, "r", external_encoding: Encoding::SJIS)
    f.each_line do |line|
      LOG.debug { "process line =>${line}" }
      if first_line then
        first_line = false
      else
        yield line.split /\t/
      end
    end
  end

  def extrace_jar
    sh_system "rm -rf #{WORK_DIR}/*"
    sh_system "cd #{WORK_DIR} && jar -xf #{File::absolute_path(@inputJar)}" or raise "Failed to extrace #{@inputJar.path}.........."
  end

  def import_env
    import_object "#{WORK_DIR}/動作環境.txt" do |items|
      LOG.debug do
        <<EOS
取り込み稼働環境 =>
    name: #{items[SenjuEnv::NAME]}
    hostName: #{items[SenjuEnv::HOSTNAME]}
    logonUser: #{items[SenjuEnv::LOGONUSER]}
EOS
      end
      e = SenjuEnv.new(name: items[SenjuEnv::NAME],
                       hostName: items[SenjuEnv::HOSTNAME],
                       logonUser: items[SenjuEnv::LOGONUSER])
      raise "Failed to save => #{e.errors.full_messages}" unless e.save
    end
  end


  def import_job
    import_object "#{WORK_DIR}/ジョブ.txt" do |items|
      LOG.debug do
        <<EOS
取り込みジョブ =>
      name: #{items[SenjuJob::NAME]}
      description: #{items[SenjuJob::DESC]}
      command: #{items[SenjuJob::CMD]}
      expected: #{items[SenjuJob::EXPECTED].to_i}
      senju_env: #{items[SenjuJob::EXEC_ENV]}
EOS
      end
      e = SenjuJob.new(name: items[SenjuJob::NAME],
                       description: items[SenjuJob::DESC],
                       command: items[SenjuJob::CMD],
                       expected: items[SenjuJob::EXPECTED].to_i)
      if items[SenjuJob::EXEC_ENV] != "" then
        env = SenjuEnv.find_by(name: items[SenjuJob::EXEC_ENV])
        raise "実行環境(#{items[SenjuJob::EXEC_ENV]})が存在しません" unless env
        e.senjuEnv = env
      end
      raise "Failed to save => #{e.errors.full_messages}" unless e.save
    end
  end

  def import_triger
    import_object "#{WORK_DIR}/トリガ.txt" do |items|
      LOG.debug do
        <<EOS
取り込みトリガ =>
    name: #{items[SenjuTriger::NAME]}
    description: #{items[SenjuTriger::DESC]}
    node: #{items[SenjuTriger::NODE]}
    path: #{items[SenjuTriger::PATH]}
EOS
      end
      e = SenjuTriger.new(name: items[SenjuTriger::NAME],
                          description: items[SenjuTriger::DESC],
                          node: items[SenjuTriger::NODE],
                          path: items[SenjuTriger::PATH])
      raise "Failed to save => #{e.errors.full_messages}" unless e.save()
    end
  end

  def import_net
    # 違う定義有効日が考えられるので、最新のものを保存するバッファを設ける
    #
    # 想定
    #
    # * 同じ名前のネットをまとめてくれる。
    # * 同じ名前のネットの定義有効日は順番で来る
    #
    netBuf = []

    import_object "#{WORK_DIR}/ネット.定義有効日.txt" do |items|
      if items[SenjuNet::NAME] != "" then
        LOG.debug { "ネット定義が着ました。" }
        if netBuf.size > 0 and items[SenjuNet::NAME] != netBuf[0][SenjuNet::NAME] then
          LOG.debug do
            <<EOS
別ネットが着ました。バッファにあるネット定義は最新と考えられ、次はネット定義をDBに保存する。
      ネット名      ：#{netBuf[0][0]}
      定義有効日付  ：#{netBuf[0][1]}
EOS
          end
          setupNet(netBuf.shift, netBuf)
        end
        netBuf.clear
      end
      netBuf << items
    end
    
    LOG.debug do
      <<EOS
ファイル最後のネット定義を無条件で取り込み
      ネット名      ：#{netBuf[0][0]}
      定義有効日付  ：#{netBuf[0][1]}
EOS
    end
    setupNet(netBuf.shift, netBuf)
  end

  def setupNet(net, children)
    name = net[SenjuNet::NAME]
    LOG.debug { "親ネット名：#{name}" }
    ent = SenjuNet.find_by(name: name)
    LOG.debug { "ent.description = #{net[SenjuNet::DESC]}" }
    ent.description = net[SenjuNet::DESC]
    LOG.debug { "envname = #{net[SenjuNet::EXEC_ENV]}" }
    envname = net[SenjuNet::EXEC_ENV]
    if envname != "" then
      env = SenjuEnv.find_by(name: envname)
      raise "実行環境(#{envname})が存在しません" unless env
      ent.senjuEnv = env
    end

    #raise "Failed to save => #{ent.errors.full_messages}" unless ent.save()
    
    LOG.debug { "ネットに所属するオブジェクトをとりこみ" }
    children.each do |items|
      appendChild(ent, items)
    end

    #raise "Failed to save => #{ent.errors.full_messages}" unless ent.save()
    
    LOG.debug { "ネットに所属するオブジェクトの先行関係をとりこみ" }
    children.each do |items|
      setupAssociation ent, items
    end

    raise "Failed to save => #{ent.errors.full_messages}" unless ent.save()
  end

  def addAssociation(net, child, pre_type, pre_name)
    pre_children = net.netReferences.select { |r| r.senjuObject.name == pre_name and r.senjuObject.class::SENJU_TYPE == pre_type }
    raise "Failed to find object by (#{pre_name}:#{pre_type})" if pre_children.empty?
    pre_child = pre_children.first
    succession = SenjuSuccession.new left: pre_child, right: child
    pre_child.rightLink << succession
    child.leftLink << succession
    #raise "Failed to save => #{succession.errors.full_messages}" unless succession.save()
  end

  def setupAssociation(net, items)
    child_type = items[SenjuNet::TYPE]
    child_name = items[SenjuNet::REF_NAME]
    child_type = SenjuNet::SENJU_TYPE if child_type == "ノードグループネット"

    LOG.debug { "ネット（#{net.name}）の子オブジェクト(#{child_name}:#{child_type})" }

    children = net.netReferences.select { |r| r.senjuObject.name == child_name and r.senjuObject.class::SENJU_TYPE == child_type }

    raise "Failed to find object by (#{child_name}:#{child_type})" if children.empty?
    child = children.first

    for i in 0 .. SenjuNet::PRECEDE_COUNT - 1
      pre_type = items[SenjuNet::PRECEDE_START + i * 2]
      pre_name = items[SenjuNet::PRECEDE_START + i * 2 + 1]
      if pre_name != "" then
        LOG.debug { "先行設定 #{pre_name}:#{pre_type} => #{child.senjuObject.name}#{child.senjuObject.class::SENJU_TYPE}" }
        addAssociation(net, child, pre_type, pre_name)
      end
    end

    for i in 0 .. SenjuNet::TRIGER_COUNT - 1
      tgr_name = items[SenjuNet::TRIGER_START + i]

      if tgr_name != "" then
        senjuObject = SenjuTriger.find_by name: tgr_name
        raise "Failed to find SenjuTriger by name: #{tgr_name}" unless senjuObject
        ref = NetReference.new(senjuNet: net, senjuObject: senjuObject)
        #raise "Failed to save => #{ref.errors.full_messages}" unless ref.save()

        #net.reload
        net.netReferences << ref

        LOG.debug { "先行設定 #{tgr_name}:トリガ => #{child.senjuObject.name}#{child.senjuObject.class::SENJU_TYPE}" }
        addAssociation(net, child, SenjuTriger::SENJU_TYPE, tgr_name)
      end
    end
    
  end

  def appendChild(net, items)
    child_type = items[SenjuNet::TYPE]
    child_type = SenjuNet::SENJU_TYPE if child_type == "ノードグループネット"
    child_name = items[SenjuNet::REF_NAME]
    child_env = items[SenjuNet::EXEC_ENV]
    child_ent = nil

    LOG.debug do
      <<EOS
ネット（#{net.name}）に子オブジェクトを追加する。
  タイプ    ：#{child_type}
  名称      ：#{child_name}
  稼動環境  ：#{child_env}
EOS
    end

    child_ref = NetReference.new senjuNet: net

    case child_type
    when SenjuNet::SENJU_TYPE then
      child_ref.senjuObject = SenjuNet.find_by name: child_name
    when SenjuJob::SENJU_TYPE then
      child_ref.senjuObject = SenjuJob.find_by name: child_name
      raise "Failed to find job by #{child_name}" unless child_ref.senjuObject
    end

    if child_env != "" then
      child_ref.senjuEnv = SenjuEnv.find_by name: child_env
      raise "Failed to find environment by #{child_env}" unless child_ref.senjuEnv
    end
    #raise "Failed to save => #{child_ref.errors.full_messages}" unless child_ref.save()
    net.netReferences << child_ref
  end

end
