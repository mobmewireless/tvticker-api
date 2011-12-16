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
  class Channel < ActiveRecord::Base;
  end
  class Program < ActiveRecord::Base;
  end
  class Series < ActiveRecord::Base;
  end
  class Category < ActiveRecord::Base;
  end
  class Thumbnail < ActiveRecord::Base
    attr_accessible  :image, :remote_image_url, :image_cache, :image_avatar
    mount_uploader :image, ImageUploader
  end
end
