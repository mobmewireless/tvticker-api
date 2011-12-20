# Standard

require 'yaml'
require 'json'

# Gems
require 'bundler/setup'
require 'mobme-infrastructure-rpc'
require 'active_record'
require 'active_support/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'open-uri'
require "mobme/infrastructure/service"
require 'mobme/infrastructure/service/worker'
require 'mobme/infrastructure/queue'
require "uuid"

# Local
require_relative 'tv_channel_info/version'
require_relative 'models'
require_relative 'tv_channel_info/service'



s=MobME::Enterprise::TvChannelInfo::Service.new
#t = MobME::Enterprise::TvChannelInfo::Thumbnail.new

#f = File.open("/home/mobme/work/ruby/tv_channel_info/service/Natalie-Portman-natalie-portman-3947071-1413-1229.jpg")


#t.remote_image_url ="http://images2.fanpop.com/images/photos/3900000/Natalie-Portman-natalie-portman-3947071-1413-1229.jpg"# (f.original_filename.blank?)? nil:f
#t.save
#p t.image.url


