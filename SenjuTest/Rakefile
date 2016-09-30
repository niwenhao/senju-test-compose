# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'logger'
require_relative 'config/application'

$LOG_LEVEL = Logger::INFO

Rails.application.load_tasks
namespace :senju do
  desc "senju define script"
  task :importjar => :environment do
    ImportSenjuScriptJob.perform_now ENV["JAR_PATH"]
  end
end
