require "logger"

module OsSupport
  module Shell
    LOG = Logger.new(STDOUT)
    LOG.level = $LOG_LEVEL
    LOG.progname = "OsSupport::Shell"
    def sh_system(command)
      LOG.info { "Execute command : #{command}" }
      system command
    end
  end
end
      
      

