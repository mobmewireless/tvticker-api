require "rspec"

require_relative 'spec_helper'

require_relative '../lib/mobme-enterprise-tv_channel_info'

module MobME::Enterprise::TvChannelInfo
  describe Service do
    before :each do
      ActiveRecord::Base.stub(:establish_connection)
      Channel.stub(:inspect)
      Program.stub(:inspect)
    end

    it { should respond_to(:channels) }
    it {should respond_to(:programs_for_channel).with(1).argument}

    describe "#initialize" do

      it "should fetch database configuration from file" do
        expected_path =  File.expand_path(File.dirname(__FILE__)).split('/')[0..-2].join('/') + "/lib/mobme/enterprise/tv_channel_info/../../../../database.yml"
        YAML.should_receive(:load).with(expected_path)
        Service.new
      end

      it "should create a connection to database" do
        database_configuration = double("Configuration")
        YAML.stub(:load).and_return(database_configuration)
        ActiveRecord::Base.should_receive(:establish_connection).with(database_configuration)
        Service.new
      end
    end

    describe "#channels" do
      it "fetches channels from database" do
        Channel.should_receive(:all).and_return([])
        subject.channels
      end

      it "returns formatted channel information" do
        star_tv_entry = double("ActiveRecord Entry", :id => 1, :name => "star")
        hbo_entry = double("ActiveRecord Entry", :id => 2, :name => "hbo")

        channels = [star_tv_entry, hbo_entry]
        Channel.stub(:all).and_return(channels)

        subject.channels.should == {1 => "star", 2 => "hbo"}
      end
    end

    describe '#programs_for_channel' do

      let(:air_time) {Time.now.utc}

      before :all do
        air_time
      end

      before :each do
        Time.stub_chain(:now, :utc).and_return(air_time)
      end

      it "fetches programs for today for the channel" do

        Program.should_receive(:where).with("channel_id = :channel_id and air_time like ':air_time%'", {:channel_id => 1, :air_time_start => air_time.strftime("%Y-%m-%d")}).and_return([])
        subject.programs_for_channel(1)
      end

      it "returns formatted channel information" do
        friends = double("", :id => 123, :name => "friends", :category_id => 1, :series_id => 1, :air_time_start => air_time, :channel_id => 1 )
        king_of_thrones = double("", :id => 124, :name => "king of thrones", :category_id => 1, :series_id => 2, :air_time_start => air_time, :channel_id =>1 )
        programs = [friends, king_of_thrones]
        Program.stub(:where).and_return(programs)
        subject.programs_for_channel(1).should == {
          123 => {:name => "friends", :category_id => 1, :series_id => 1, :air_time_start => air_time},
          124 => {:name => "king of thrones", :category_id => 1, :series_id => 2, :air_time_start => air_time}
        }
      end

      context "when date is specified" do
        it "fetches programs for that day for the channel"
      end
    end

  end
end