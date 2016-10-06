module Senju::CommonLogHelper

  LOG = Logger.new(STDOUT)
  LOG.progname = self.class
  LOG.level = $LOG_LEVEL

  def debug(&block)
    LOG.add(Logger::DEBUG, self.class.name) { block.call } if LOG.debug?
  end

  def info(&block)
    LOG.add(Logger::INFO, self.class.name) { block.call } if LOG.info?
  end
end
