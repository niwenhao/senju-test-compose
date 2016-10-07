module Senju::CommonLogHelper

  LOG = Logger.new(STDOUT)
  LOG.progname = self.class
  LOG.level = $LOG_LEVEL

  def debug(&block)
    LOG.debug(self.class.name, &block)
  end

  def info(&block)
    #LOG.add(Logger::INFO, self.class.name) { block.call } if LOG.info?
    LOG.info(self.class.name, &block)
  end
end
