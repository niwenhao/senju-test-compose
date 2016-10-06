module Senju::CommonLogHelper

  LOG = Logger.new(STDOUT)
  LOG.progname = self.class
  LOG.level = $LOG_LEVEL

  def debug(&block)
    LOG.add severity: Logger::DEBUG, progname: self.class.name, block: block if LOG.debug?
  end

  def info(&block)
    LOG.add severity: Logger::INFO, progname: self.class.name, block: block if LOG.info?
  end
end
