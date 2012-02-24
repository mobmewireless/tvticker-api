# Standard

require 'yaml'
require 'json'

# Gems
require 'bundler/setup'
require 'sync_service'
require 'active_record'
require 'active_support/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'open-uri'
require "async_service"
require 'mobme/infrastructure/queue'
require "uuid"

# Local
require_relative 'tv_channel_info/version'
require_relative 'models'
require_relative 'tv_channel_info/service'

MobME::Enterprise::TvChannelInfo::Service.new
