# Gems
require 'bundler/setup'
require 'active_record'
require 'active_support/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
CarrierWave.configure do |config|
  config.root = File.expand_path(".")
end