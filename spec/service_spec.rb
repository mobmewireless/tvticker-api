require "rspec"

require_relative 'spec_helper'

require_relative '../lib/mobme/enterprise/mobme-enterprise-tv-channel-info'

module MobME::Enterprise::TvChannelInfo

  describe Service do

    let(:air_time_start) { Time.now.utc }
    let(:air_time_end) { Time.now.utc }
    let(:run_time) { rand(300) }
    let(:imdb_info) { "sdjsafdjklsbjkfb" }
    let(:friends) { double(:id => 123, :name => "friends", :category_id => 1, :series_id => 1, :channel_id => 1, :air_time_start => air_time_start, :air_time_end=>air_time_end, :run_time=>run_time, :imdb_info=>imdb_info) }
    let(:king_of_thrones) { double(:id => 124, :name => "king of thrones", :category_id => 1, :series_id => 2, :channel_id =>1, :air_time_start => air_time_start, :air_time_end=>air_time_end, :run_time=>run_time, :imdb_info=>imdb_info) }
    let(:programs) { [friends, king_of_thrones] }
    let(:air_time) { Time.parse air_time_start.to_s }
    let(:timestamp) { Time.now.to_i }
    let(:hashed_key) { Digest::MD5.hexdigest("#{timestamp}#{"tvticker"}") }
    let(:hashed_key_wrong) { "XXX" }

    before :all do
      air_time_start
    end

    before :each do
      ActiveRecord::Base.stub(:establish_connection)
      Channel.stub(:inspect)
      Program.stub(:inspect)
    end

    it { should respond_to(:channels).with(2).arguments }
    it { should respond_to(:current_version).with(2).arguments }
    it { should respond_to(:programs_for_channel).with(3).argument }
    it { should respond_to(:programs_for_current_frame).with(4).arguments }
    it { should respond_to(:update_to_current_version).with(2).arguments }
    it { should respond_to(:update_to_current_version).with(3).arguments }


    describe "#initialize" do

      let(:database_configuration) { double("Configuration").as_null_object }
      before :each do
        YAML.stub(:load).and_return(database_configuration)
      end
      it "should fetch database configuration from file" do
        expected_file = File.read File.expand_path(File.dirname(__FILE__)).split('/')[0..-2].join('/') + "/lib/mobme/enterprise/tv_channel_info/../../../../config/database.yml"
        YAML.should_receive(:load).with(expected_file) #.once.and_return(database_configuration)
        Service.new
      end

      it "should create a connection to database" do
        YAML.stub(:load).and_return(database_configuration)
        ActiveRecord::Base.should_receive(:establish_connection).with(database_configuration)
        Service.new
      end
    end

    context "when authenticating" do
      it "works correctly for good keys" do
        subject.ping(timestamp, hashed_key).should == "pong"
      end

      it "returns nothing for bad keys" do
        subject.ping(timestamp, hashed_key_wrong).should == ""
      end
    end

    describe "#channels" do
      it "fetches channels from database" do
        Channel.stub(:column_names).and_return([])
        Channel.should_receive(:select).and_return([])
        subject.channels(timestamp, hashed_key)
      end

      it "returns formatted channel information" do
        star_tv_entry = double("ActiveRecord Entry", :id => 1, :name => "star")
        hbo_entry = double("ActiveRecord Entry", :id => 2, :name => "hbo")

        channels = [star_tv_entry, hbo_entry]
        Channel.stub(:column_names).and_return([])
        Channel.stub(:select).and_return(channels)

        subject.channels(timestamp, hashed_key).should == channels
      end
    end
    describe "#categories" do
      it "fetches channels from database" do
        Category.stub(:column_names).and_return([])
        Category.should_receive(:select).and_return([])
        subject.categories(timestamp, hashed_key)
      end

      it "returns formatted channel information" do
        movie = double("ActiveRecord Entry", :id => 1, :name => "movie")
        news = double("ActiveRecord Entry", :id => 2, :name => "news")
        categories = [movie, news]
        Category.stub(:column_names).and_return([])
        Category.stub(:select).and_return(categories)
        subject.categories(timestamp, hashed_key).should == categories
      end
    end

    describe '#programs_for_channel' do

      before :each do
        Time.stub_chain(:now, :utc).and_return(air_time_start)
      end

      it "fetches programs for today for the channel" do
        Program.stub(:column_names).and_return([])
        Program.stub(:select).and_return(programs)
        programs.should_receive(:where).with("channel_id = :channel_id and air_time_start like :air_time_start ", {:channel_id => 1, :air_time_start =>"#{air_time_start.strftime("%Y-%m-%d").to_s}%"}).and_return([])
        subject.programs_for_channel(timestamp, hashed_key, 1)
      end

      it "returns formatted channel information" do
        Program.stub(:column_names).and_return([])
        Program.stub_chain(:select, :where).and_return([])
        subject.programs_for_channel(timestamp, hashed_key, 1).should == []
      end

    end

    describe "#programs_for_current_frame" do
      context "when frame_type is now" do
        it "queries programs table " do
          Program.stub(:column_names).and_return([])
          Program.stub(:select).and_return(programs)
          Program.should_receive(:where).with("air_time_start BETWEEN :air_time_start and :air_time_end", {:air_time_start => air_time-60*60, :air_time_end => air_time+60*60}).and_return(programs)
          programs.stub_chain(:order, :limit, :map).and_return(programs)
          subject.programs_for_current_frame(timestamp, hashed_key, air_time, :now).should == programs
        end
      end

      context "when frame_type is later" do
        it "queries programs table " do
          Program.stub(:column_names).and_return([])
          Program.stub(:select).and_return(programs)
          Program.should_receive(:where).with("air_time_start BETWEEN :air_time_start and :air_time_end", {:air_time_start => air_time+60*60, :air_time_end => air_time+3*60*60}).and_return(programs)
          programs.stub_chain(:order, :limit, :map).and_return(programs)
          subject.programs_for_current_frame(timestamp, hashed_key, air_time, :later).should == programs
        end
      end
      context "when frame_type is full" do
        it "queries programs table " do
          Program.stub(:column_names).and_return([])
          Program.stub(:select).and_return(programs)
          Program.should_receive(:where).with("air_time_start > :air_time_start", {:air_time_start => air_time}).and_return(programs)
          programs.stub_chain(:order, :limit, :map).and_return(programs)
          subject.programs_for_current_frame(timestamp, hashed_key, air_time, :full).should == programs
        end
      end
      context "when frame_type is incorrect" do
        it "fetches list of programs for the frame type" do
          air_time =Time.parse air_time_start.to_s
          expect {
            subject.programs_for_current_frame(timestamp, hashed_key, air_time, :incorrect)
          }.to raise_error(FrameTypeError, "incorrect frame type")
        end
      end

    end

    describe "#current_version" do
      context "when version table is empty" do

        it "returns an empty string" do
          Version.should_receive(:last).and_return([])
          subject.current_version(timestamp, hashed_key).should == ""
        end
      end
      context "when version is available" do
        it "returns the current version" do
          version = double(:id=>5, :number=>"627167327625361")
          Version.should_receive(:last).and_return(version)
          subject.current_version(timestamp, hashed_key).should == version.number
        end
      end

    end

    describe "#update_to_current_version" do


      it "returns formatted channel information" do

        Program.stub(:version_greater_than).and_return(programs)

        star_tv_entry = double("ActiveRecord Entry", :id => 1, :name => "star", :version_id=>1)
        hbo_entry = double("ActiveRecord Entry", :id => 2, :name => "hbo", :version_id=>2)
        channels = [star_tv_entry, hbo_entry]
        Channel.stub(:version_greater_than).and_return(channels)

        categories =[{:id=>1, :name=>"movie", :version_id=>1}, {:id=>2, :name=>"series", :version_id=>2}]
        Category.stub(:version_greater_than).and_return(categories)

        friends = double(:id => 123, :name => "friends", :category_id => 1, :series_id => 1, :channel_id => 1, :air_time_start => air_time_start, :air_time_end=>air_time_end, :run_time=>run_time, :imdb_info=>imdb_info, :version_id=>1)
        king_of_thrones = double(:id => 124, :name => "king of thrones", :category_id => 1, :series_id => 2, :channel_id =>1, :air_time_start => air_time_start, :air_time_end=>air_time_end, :run_time=>run_time, :imdb_info=>imdb_info, :version_id=>2)
        series = [friends, king_of_thrones]
        Series.stub(:version_greater_than).and_return(series)

        versions = [{:id=>2, :number=>"32423423"}, {:id=>3, :name=>"34234234"}]
        Version.stub(:version_greater_than).and_return(versions)
        client_version = "453453453"
        Version.should_receive(:find_by_number).with(client_version).and_return([])

        subject.update_to_current_version(timestamp, hashed_key, client_version).should == {
            :channels=>channels, :categories=>categories, :programs=>programs, :series=>series, :versions=>versions
        }
      end
    end
  end
end