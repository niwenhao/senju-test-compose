module Senju::CommonHelper
  #
  # 定義情報ハッシュのラッパ
  #
  class ConfigContext

    #
    # 変数ハッシュを設定する
    #
    attr_accessor :real_data

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
      @real_data = conf
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

    def to_s
      self.inspect
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

      if @real_data == nil then
        return self
      end

      if name == :[] then
        v = @real_data[args[0]]
      else
        v = @real_data[name.to_s]
      end
      if v.is_a?(Hash) or v.is_a?(Array) then
        r = ConfigContext.new(v)
        return r
      end

      if v == nil then
        return ConfigContext::NIL_CONFIG
      end


      return v
    end

    def nil?
      @real_data == nil
    end

    NIL_CONFIG = ConfigContext.new(nil)
  end
end
