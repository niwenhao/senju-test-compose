################################################################################
#        Zexon�V�X�e���i����(KT)�j
#        [���v���p]Ruby ���v���p���ʋ@�\
# Program ID :  zktommon.rb
#      Usage :  ���ڌďo���s��
#
#       �� �� �� ��
#       �N �� ��      �敪      �� ��/�S ��        �� �e
#       ------------  -------   -----------------  -------------------
#       2015/08/01    �V�K      NRI                �V�K�쐬
#
#       Copyright (C) 2006 by Nomura Research Institute,Ltd.
#       All right reserved.
#
################################################################################

require 'logger'
require 'yaml'

#
# ���O�o�̓I�u�W�F�N�g
#
LOG = Logger.new(STDOUT)

#
# ���O�o�͋@�\������������
#
# �������e�F
# 1. ���ϐ�TOUKEI_DEBUG�̒l�Ń��O���x����؂�ւ���
# 2. LOG�I�u�W�F�N�g��debug2�@�\��ǉ�����B
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
# ���W���[���i�t�@�C���j������N���X����ϊ�����
# �ϊ����[��
# 1. ���W���[������"_"�ŒP��ɕ�������
# 2. �e�P��̓��ꕶ����啶���ɕύX����
# 3. �P����q���ŁA�N���X���ɂȂ�
#
# ����
# 1. mod      ���W���[����
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
# �v���O�����̃g���[�X�����o�͂���B
#
# �����F
# 1. prefix       �g���[�X��񂲂Ƃ̃v���t�B�b�N�X
#
# �����T�v�F
# 1. ���݂̃X�^�b�N�����擾
# 2. �X�^�b�N��񂩂�A�Ō�̃|�W�V��������菜���i���̊֐��j
# 3. �X�^�b�N���𐮌`���ĕԂ�
#
def trace_info(prefix)
  # 1. ���݂̃X�^�b�N�����擾
  stack_trace = caller
  # 2. �X�^�b�N��񂩂�A�Ō�̃|�W�V��������菜���i���̊֐��j
  stack_trace.shift

  # 3. �X�^�b�N���𐮌`���ĕԂ�
  return format_trace(prefix, stack_trace)
end

#
# ��O�̃g���[�X�����擾���ĕԂ�
#
# �����F
# 1. e      ��O
#
def trace_exception(e)
  rst = e.inspect
  rst << "\n"
  rst << format_trace("EXCEPTION =>", e.backtrace)
  return rst
end

#
# �g���[�X�����t�H�[�}�b�g����B
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
# ��`��񂩂�w�肳��鏈���N���X�̃C���X�^���X���쐬����
# ����
# 1. conf      ��`���n�b�V��
#
# ����
# 1. conf����module�̕�������擾����
# 2. create_processor���g���āA�C���X�^���X��Ԃ�
#
def create_defined_processor(conf)
  LOG.debug("Call create_defined_processor(conf)")
  mod_name = conf.module
  LOG.debug("mod_name => #{mod_name}")
  return create_processor(mod_name)
end

#
# ���W���[�������󂯁A�N���X�̃C���X�^���X���쐬����B
# �����F
# 1. mod_name          ���W���[����
#
# ����
# 1. conv_mod2cls���g���āA���W���[��������N���X����ϊ�����
# 2. ���W���[�����̑O��zkt�����Arequire�Ń��[�h����B
# 3. �N���X��new���Ė߂�
#
def create_processor(mod_name)
  LOG.debug("Call create_processor(#{mod_name})")
  cls_name = conv_mod2cls(mod_name)
  LOG.debug("cls_name => #{cls_name}")

  require "zkt#{mod_name}"
  return eval("#{cls_name}.new")
end

#
# ��`���n�b�V���̃��b�p
#
class ConfigContext
  #
  # ���[�h�ς݃t�@�C���ꗗ
  #
  LOADED_CONFIGS = Array.new

  #
  # �ϐ��n�b�V����ݒ肷��
  #
  attr_accessor :vars, :real_data

  #
  #�e�L�X�g����ϐ��𒊏o����p�[�^��
  #
  VARPTN = /@\{\w+\}/

  #
  #�e�L�X�g������ϐ��𒊏o����p�[�^��
  #
  ENVPTN = /\$\{\w+\}/

  #
  #�����N�ł���p�^�[��
  #
  REFPTN = /ref => (.*)$/

  #
  # �����w�肷��p�^�[��
  #
  ARGPTN = /%\{\d+\}/

  #
  #�e�L�X�g���̕ϐ��A���ϐ��̓���ւ���
  #�ϐ�����ւ��F@{�ϐ���}�Œ�`�������̂�l�ɓ���ւ���B�ϐ��̒l�́A������vars(Hash)����擾����B
  #���ϐ�����ւ��F${�ϐ���}�Œ�`�������̂����ϐ��œ���ւ���B
  #
  #�����F
  #   text    :����ւ��Ώۃe�L�X�g
  #   vars    :�ϐ��n�b�V��
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
  # ����������
  #
  # �����F
  # 1. conf       �e�L�X�g�̏ꍇ�AYAML�t�@�C�����w��
  #               ���̑��̏ꍇ�A��`�n�b�V�����w��
  #
  # �������e�F
  #     ��`�����[�h
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
  # Array�����b�v�����ꍇ�A������Ԃ�
  # ���̑��̏ꍇ�Asize���ڂ�Ԃ�
  #
  def size
    if @real_data.is_a?(Array) then
      return @real_data.size
    else
      return self.method_missing(:size)
    end
  end

  #
  # inspect�����b�p����
  #
  def inspect
    return @real_data.inspect
  end

  #
  # Array�܂���Hash��each���\�b�h�����b�v����
  #
  # �����F
  # 1. code       �N���[����
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
  # �Ȃ�ł����b�v����
  #
  # �������e�F
  # 1. ���\�b�h����[]�̏ꍇ�A�n�b�V���E���X�g����
  # 2. ���̑��̏ꍇ�A�n�b�V�����烁�\�b�h�����L�[�Œl���擾����
  # 3. �擾�����l�̓n�b�V���E���X�g�̏ꍇ�A�V�������b�p�𐶐����A�Ԃ�
  # 4. �X�g�����O�̏ꍇ�A�ϐ�����ւ����s��
  # 5. ���ʂ�Ԃ�
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
# �^�C�v�ϊ�
#
class TypeConvertor
  #
  # ���[���� => �ϊ��R�[�hlambda�̃L���b�V��
  #
  PROESS_RULES = Hash.new

  #
  # �ϊ����[��String�̒�`
  #
  # �������e�F
  # �X�g�����O�̏ꍇ�A���̂܂ܕԂ�
  # ���̑��̏ꍇ�Ato_s�ŕԂ�
  #
  PROESS_RULES['String'] = lambda { |v|
    if v.is_a?(String) then
      return v
    else
      return v.to_s
    end
  }

  #
  # �ϊ����[��Integer�̒�`
  #
  # �������e�F
  # Integer�̏ꍇ�A���̂܂ܕԂ�
  # Float�̏ꍇ�Ato_i�ŕԂ�
  # String�̏ꍇ�A���[�̃X�y�[�X���폜���Ă���Ato_i�ŕԂ�
  # ���̑��̏ꍇ�Anil��Ԃ�
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
  # �ϊ����[��Float��`
  #
  # �������e�F
  # Integer�̏ꍇ�Ainduced_from�ŕԂ�
  # String�̏ꍇ�A���[�̃X�y�[�X���폜���Ă���Ato_f�ŕԂ�
  # Float�̏ꍇ�A���̂܂ܕԂ�
  # ���̑��̏ꍇ�Anil��Ԃ�
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
  # �ϊ�����
  #
  # �����F
  # 1. v        �ϊ��l
  # 2. type     �ϊ����[��
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



