require 'rubygems'
require 'active_record'
require 'active_support/all'
require 'random_data'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/mobme/enterprise/mobme-enterprise-tv-channel-info.rb"
# load "#{File.expand_path(File.dirname(__FILE__))}/../lib/mobme/enterprise/tv_channel_info/models.rb"
include MobME::Enterprise::TvChannelInfo
Channel.delete_all
Series.delete_all
Category.delete_all
Program.delete_all
#["hbo", "star movies", "cnn", "movies now"].each { |r| p r; Channel.create(:name => r) }
x = 100
x.times do

  channel = Channel.new
  channel.name = Random.alphanumeric
  channel.save
  series = Series.new
  series.name = Random.alphanumeric
  series.imdb_info = "http://www.imdb.com/title/tt0#{ Random.number(100000..999999)}/"
  series.description = Random.paragraphs
  series.rating = Random.number(1..10)
  series.save
  category = Category.new
  category.name = Random.alphanumeric
  category.save
  program = Program.new

  program.name = Random.alphanumeric
  program.category_id = Random.number(1..x)
  program.channel_id = Random.number(1..x)
  program.series_id = Random.number(1..x)
  temp1 = DateTime.parse("#{Random.date} #{(Time.new+rand(9999)).strftime("at %I:%M%p")  }")
  temp2 = DateTime.parse("#{Random.date} #{(Time.new+rand(9999)).strftime("at %I:%M%p")  }")
  program.air_time_start = (temp1>temp2) ? temp2 : temp1
  program.air_time_end = (temp1>temp2) ? temp1 : temp2
  program.run_time =    program.air_time_end.to_time.to_i -  program.air_time_start.to_time.to_i
  program.imdb_info = "http://www.imdb.com/title/tt0#{ Random.number(100000..999999)}/"
  program.description = Random.paragraphs
  program.rating = Random.number(1..10)
  program.save

end