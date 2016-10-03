################################################################################
#        Zexonシステム（共通(KT)）
#        [統計情報用]Ruby 統計情報用共通機能
# Program ID :  zktommon.rb
#      Usage :  直接呼出し不可
#
#       改 訂 履 歴
#       年 月 日      区分      所 属/担 当        内 容
#       ------------  -------   -----------------  -------------------
#       2015/08/01    新規      NRI                新規作成
#
#       Copyright (C) 2006 by Nomura Research Institute,Ltd.
#       All right reserved.
#
################################################################################

require 'logger'
require 'yaml'

#
# ログ出力オブジェクト
#
LOG = Logger.new(STDOUT)

#
# ログ出力機能を初期化する
#
# 処理内容：
# 1. 環境変数TOUKEI_DEBUGの値でログレベルを切り替える
# 2. LOGオブジェクトにdebug2機能を追加する。
def init_log_output
  if ENV['TOUKEI_DEBUG'] != nil then
    LOG.level = Logger::DEBUG
  else
    LOG.level = Logger::INFO
  end

  class <<LOG
    def debug3(txt, *data)
      if self.debug? then
        msg = caller.inspect
        msg << " : " << txt
        data.each { |obj|
          msg << "\n          => " << obj.inspect
        }
        LOG.debug(msg)
      end
    end
    def debug2(txt, *data)
      if self.debug? then
        msg = caller[0]
        msg << " : " << txt
        data.each { |obj|
          msg << "\n          => " << obj.inspect
        }
        LOG.debug(msg)
      end
    end
  end
end

init_log_output


#
# モジュール（ファイル）名からクラス名を変換する
# 変換ルール
# 1. モジュール名を"_"で単語に分割する
# 2. 各単語の頭一文字を大文字に変更する
# 3. 単語を繋いで、クラス名になる
#
# 引数
# 1. mod      モジュール名
#
def conv_mod2cls(mod)
  LOG.debug("Call conv_mod2cls(#{mod})")
  rst = ""
  mod.split("_").each do |p|
    rst += p[0, 1].upcase + p[1, p.length - 1];
  end
  LOG.debug("Exit conv_mod2cls => #{rst}")
  return rst
end

#
# プログラムのトレース情報を出力する。
#
# 引数：
# 1. prefix       トレース情報ごとのプレフィックス
#
# 処理概要：
# 1. 現在のスタック情報を取得
# 2. スタック情報から、最後のポジションを取り除く（この関数）
# 3. スタック情報を整形して返す
#
def trace_info(prefix)
  # 1. 現在のスタック情報を取得
  stack_trace = caller
  # 2. スタック情報から、最後のポジションを取り除く（この関数）
  stack_trace.shift

  # 3. スタック情報を整形して返す
  return format_trace(prefix, stack_trace)
end

#
# 例外のトレース情報を取得して返す
#
# 引数：
# 1. e      例外
#
def trace_exception(e)
  rst = e.inspect
  rst << "\n"
  rst << format_trace("EXCEPTION =>", e.backtrace)
  return rst
end

#
# トレース情報をフォーマットする。
#
def format_trace(prefix, stack_trace)
  rst = "\n"

  pf = prefix.clone
  stack_trace.each do |t|
    rst << pf << t << "\n"
    pf << "  "
  end
  return rst
end

#
# 定義情報から指定される処理クラスのインスタンスを作成する
# 引数
# 1. conf      定義情報ハッシュ
#
# 処理
# 1. confからmoduleの文字列を取得する
# 2. create_processorを使って、インスタンスを返す
#
def create_defined_processor(conf)
  LOG.debug("Call create_defined_processor(conf)")
  mod_name = conf.module
  LOG.debug("mod_name => #{mod_name}")
  return create_processor(mod_name)
end

#
# モジュール名を受け、クラスのインスタンスを作成する。
# 引数：
# 1. mod_name          モジュール名
#
# 処理
# 1. conv_mod2clsを使って、モジュール名からクラス名を変換する
# 2. モジュール名の前にzktをつけ、requireでロードする。
# 3. クラスをnewして戻す
#
def create_processor(mod_name)
  LOG.debug("Call create_processor(#{mod_name})")
  cls_name = conv_mod2cls(mod_name)
  LOG.debug("cls_name => #{cls_name}")

  require "zkt#{mod_name}"
  return eval("#{cls_name}.new")
end

#
# 定義情報ハッシュのラッパ
#
class ConfigContext
  #
  # ロード済みファイル一覧
  #
  LOADED_CONFIGS = Array.new

  #
  # 変数ハッシュを設定する
  #
  attr_accessor :vars, :real_data

  #
  #テキストから変数を抽出するパータン
  #
  VARPTN = /@\{\w+\}/

  #
  #テキストから環境変数を抽出するパータン
  #
  ENVPTN = /\$\{\w+\}/

  #
  #リンクであるパターン
  #
  REFPTN = /ref => (.*)$/

  #
  # 引数指定するパターン
  #
  ARGPTN = /%\{\d+\}/

  #
  #テキスト内の変数、環境変数の入れ替える
  #変数入れ替え：@{変数名}で定義したものを値に入れ替える。変数の値は、引数のvars(Hash)から取得する。
  #環境変数入れ替え：${変数名}で定義したものを環境変数で入れ替える。
  #
  #引数：
  #   text    :入れ替え対象テキスト
  #   vars    :変数ハッシュ
  #
  def preprocess_var(text, vars)
    LOG.debug("Call preprocess_var(#{text}, vars)")
    flg = true;
    rst = text;

    if ! rst.is_a?(String) then
      return rst
    end

    while flg
      flg = false
      if (m = VARPTN.match(rst)) != nil then
        t = m.to_s
        t = vars[t[2, t.length - 3]];
        t = "" if t == nil
        rst = m.pre_match + t.to_s + m.post_match
        flg = true
      end
      if (m = ENVPTN.match(rst)) != nil then
        t = m.to_s
        t = ENV[t[2, t.length - 3]];
        t = "" if t == nil
        rst = m.pre_match + t.to_s + m.post_match
        flg = true
      end
      if (m = ARGPTN.match(rst)) != nil then
        t = m.to_s
        t = ARGV[t[2, t.length - 3].to_i - 1];
        t = "" if t == nil
        rst = m.pre_match + t.to_s + m.post_match
        flg = true
      end
    end
    LOG.debug("Exit preprocess_var => #{rst}")
    return rst;
  end

  #
  # 初期化処理
  #
  # 引数：
  # 1. conf       テキストの場合、YAMLファイルを指す
  #               その他の場合、定義ハッシュを指す
  #
  # 処理内容：
  #     定義をロード
  #
  def initialize(conf)
    raise "Faile to init Config with (#{conf.inspect})" unless conf.is_a?(String) or conf.is_a?(Hash) or conf.is_a?(Array)

    if conf.is_a?(String) then
      unless LOADED_CONFIGS.index(conf)
        confdir = File.dirname conf
        inclst = %x(grep '^#include ' #{conf}).split(/\n/).map { |l| l.gsub(/^#include +/, "") }
        @real_data = YAML.load_file(conf)
        LOADED_CONFIGS << conf
        inclst.each do |f|
          (fpath = confdir) << "/" << f.chomp
          if File.readable? fpath
            c = ConfigContext.new(fpath)
            @real_data.merge! c.real_data
          else
            raise "Initialize configure file (#{fpath}) failed!"
          end
        end
      else
        @real_data = Hash.new
      end
    else
      @real_data = conf
    end
    LOG.debug2("@real_data", @real_data)
  end

  #
  # Arrayをラップした場合、長さを返す
  # その他の場合、size項目を返す
  #
  def size
    if @real_data.is_a?(Array) then
      return @real_data.size
    else
      return self.method_missing(:size)
    end
  end

  #
  # inspectをラッパする
  #
  def inspect
    return @real_data.inspect
  end

  #
  # ArrayまたはHashのeachメソッドをラップする
  #
  # 引数：
  # 1. code       クローじゃ
  #
  def each(&code)
    if @real_data.is_a?(Hash) then
      @real_data.each { |k, v|
        code.call(k, self[k])
      }
    end

    if @real_data.is_a?(Array) then
      for i in 0 .. @real_data.size-1
        code.call(self[i])
      end
    end
  end

  #
  # なんでもラップする
  #
  # 処理内容：
  # 1. メソッド名は[]の場合、ハッシュ・リスト扱い
  # 2. その他の場合、ハッシュからメソッド名をキーで値を取得する
  # 3. 取得した値はハッシュ・リストの場合、新しいラッパを生成し、返す
  # 4. ストリングの場合、変数入れ替えを行う
  # 5. 結果を返す
  #
  def method_missing(name, *args)
    if name == :[] then
      v = @real_data[args[0]]
    else
      v = @real_data[name.to_s]
    end
    if v.is_a?(Hash) or v.is_a?(Array) then
      r = ConfigContext.new(v)
      r.vars = @vars
      return r
    end

    if v.is_a?(String) and REFPTN =~ v then
      LOG.info("find reference to #{$1}")
      path = $1
      cfg = $mainconf
      path.split('/').each { |s|
        cfg = cfg[s] if s.length > 0
      }
      return cfg
    end
    if v.is_a?(String) and @vars != nil then
      return preprocess_var(v, @vars)
    end
    return v
  end
end

#
# タイプ変換
#
class TypeConvertor
  #
  # ルール名 => 変換コードlambdaのキャッシュ
  #
  PROESS_RULES = Hash.new

  #
  # 変換ルールStringの定義
  #
  # 処理内容：
  # ストリングの場合、そのまま返す
  # その他の場合、to_sで返す
  #
  PROESS_RULES['String'] = lambda { |v|
    if v.is_a?(String) then
      return v
    else
      return v.to_s
    end
  }

  #
  # 変換ルールIntegerの定義
  #
  # 処理内容：
  # Integerの場合、そのまま返す
  # Floatの場合、to_iで返す
  # Stringの場合、両端のスペースを削除してから、to_iで返す
  # その他の場合、nilを返す
  #
  PROESS_RULES['Integer'] = lambda { |v|
    if v.is_a?(Integer) then
      return v
    end
    if v.is_a?(Float) then
      return v.to_i
    end
    if v.is_a?(String) then
      return v.strip.to_i
    end
    LOG.error("try convert #{v.inspect} to Integer")
    return nil
  }

  #
  # 変換ルールFloat定義
  #
  # 処理内容：
  # Integerの場合、induced_fromで返す
  # Stringの場合、両端のスペースを削除してから、to_fで返す
  # Floatの場合、そのまま返す
  # その他の場合、nilを返す
  #
  PROESS_RULES['Float'] = lambda { |v|
    if v.is_a?(Integer) then
      return Float.induced_from(v)
    end
    if v.is_a?(String) then
      return v.strip.to_f
    end
    if v.is_a?(Float) then
      return v
    end
    LOG.error("try convert #{v.inspect} to Integer")
    return nil
  }

  #
  # 変換する
  #
  # 引数：
  # 1. v        変換値
  # 2. type     変換ルール
  #
  def self.conv(v, type)
    l = PROESS_RULES[type]
    if l == nil then
      LOG.error("type_conv has not rule to convert #{type.inspect} for #{v.inspect}")
      return nil
    end
    return l.call(v)
  end
end


require 'zktcommon_processor'



