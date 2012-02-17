module MobME::Enterprise::TvChannelInfo
  class ImageUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    storage :file

    def store_dir
      "uploads/users/#{model.id}/image"
    end

    def extensions_white_list
      %w(jpg jpeg gif png)
    end

    process :resize_to_limit => [720, 720]
    version :icon40 do
      process :resize_to_fill => [40, 40]
    end
    version :icon60 do
      process :resize_to_fill => [60, 60]
    end
    version :profile do
      process :resize_to_limit => [180, 180]
    end
  end

  class Channel < ActiveRecord::Base
    scope :version_greater_than, lambda { |v| select(column_names - ["version_id"]).where("version_id > :version_id", {:version_id =>v}) }
  end

  class Program < ActiveRecord::Base
    scope :version_greater_than, lambda { |v| select(column_names - ["version_id"]).where("version_id > :version_id and air_time_end > :air_time_end", {:version_id =>v,:air_time_end => (Time.now - (60*60))} ) }

    belongs_to :channel
    belongs_to :category
  end

  class Series < ActiveRecord::Base
    scope :version_greater_than, lambda { |v| select(column_names - ["version_id"]).where("version_id > :version_id", {:version_id =>v})}
  end

  class Category < ActiveRecord::Base
    scope :version_greater_than, lambda { |v| select(column_names - ["version_id"]).where("version_id > :version_id", {:version_id =>v}) }
  end

  class Version < ActiveRecord::Base
    after_initialize :init_version

    def init_version
      self.number = "#{Time.now.to_i}#{UUID.generate.gsub("-", "")}"
    end

    scope :version_greater_than, lambda { |v| where("id > :version_id", {:version_id =>v}) }

  end

  class Thumbnail < ActiveRecord::Base
    attr_accessible :image, :remote_image_url, :image_cache, :image_avatar
    mount_uploader :image, ImageUploader
    scope :version_greater_than, lambda { |v| where("version_id > :version_id", {:version_id =>v}) }
  end
end
