# encoding: utf-8

class UserAvatarUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "system/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    # should return path to cache dir
    Rails.root.join 'tmp/uploads'
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    if model.gender == 'female' or model.gender == '女'
      ActionController::Base.helpers.asset_path("images/user_avatars/woman#{model.id % 4 + 1}.png")
    else
      ActionController::Base.helpers.asset_path("images/user_avatars/man#{model.id % 4 + 1}.png")
    end
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fill => [280, 280]
  end

  version :small do
    process :resize_to_fill => [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
