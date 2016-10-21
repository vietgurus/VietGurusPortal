class Image < ActiveRecord::Base
  include FileStore

  enum status: [:temp, :moving, :moved, :generating_thumbs, :ready, :fail]
  after_initialize :init
  after_save :async_process

  validates :path,
            presence: true,
            if: Proc.new { temp_path.blank? }
  validates :temp_path,
            presence: true,
            if: Proc.new { path.blank? }

  def init
    self.status ||= :temp
  end

  def async_process
    if self.temp?
      self.move_file!
    elsif self.moved?
      self.generate_thumbs!
    end
  end

  def move_file!
    self.update!(status: :moving)
    self.path = FileStore.copy_from_temp_path(temp_path, 'image')
    self.temp_path = nil
    self.status = :moved
    self.save!
  rescue
    begin
      self.path = FileStore.copy_from_temp_path(temp_path, 'image')
      self.temp_path = nil
      self.status = :moved
      self.save!
    rescue
      self.update!(status: :fail)
    end
  end

  #TODO REFACTOR: DRY
  def generate_thumbs!
    self.update!(status: :generating_thumbs)
    generate_thumb_scale(thumb_quarter_path, 2)
    generate_thumb(thumb_512x320_path, 512, 320)
    generate_thumb(thumb_128x128_path, 128, 128)
    self.update!(status: :ready)
  rescue
    begin
      generate_thumb_scale(thumb_quarter_path, 2)
      generate_thumb(thumb_512x320_path, 512, 320)
      generate_thumb(thumb_128x128_path, 128, 128)
      self.update!(status: :ready)
    rescue
      self.update!(status: :fail)
    end
  end

  def url
    unless self.path.nil?
      if ENV['AWS_S3_CLOUD_FRONT'].present?
        "https://#{ENV['AWS_S3_CLOUD_FRONT']}/#{self.path}"
      else
        FileStore.bucket.object(self.path).public_url.to_s
      end
    end
  end

  def thumb_quarter_url
    unless self.thumb_quarter_path.nil?
      if ENV['AWS_S3_CLOUD_FRONT'].present?
        "https://#{ENV['AWS_S3_CLOUD_FRONT']}/#{self.thumb_quarter_path}"
      else
        FileStore.bucket.object(self.thumb_quarter_path).public_url.to_s
      end
    end
  end

  def thumb_512x320_url
    unless self.thumb_512x320_path.nil?
      if ENV['AWS_S3_CLOUD_FRONT'].present?
        "https://#{ENV['AWS_S3_CLOUD_FRONT']}/#{self.thumb_512x320_path}"
      else
        FileStore.bucket.object(self.thumb_512x320_path).public_url.to_s
      end
    end
  end

  def thumb_128x128_url
    unless self.thumb_128x128_path.nil?
      if ENV['AWS_S3_CLOUD_FRONT'].present?
        "https://#{ENV['AWS_S3_CLOUD_FRONT']}/#{self.thumb_128x128_path}"
      else
        FileStore.bucket.object(self.thumb_128x128_path).public_url.to_s
      end
    end
  end

  def thumb_quarter_path
    return nil unless self.path.present?
    ext = File.extname(self.path)
    base = File.basename(self.path, ext)
    dir = File.dirname(self.path)
    "#{dir}/#{base}_thumb_quarter#{ext}"
  end

  def thumb_512x320_path
    return nil unless self.path.present?
    ext = File.extname(self.path)
    base = File.basename(self.path, ext)
    dir = File.dirname(self.path)
    "#{dir}/#{base}_thumb_512x320#{ext}"
  end

  def thumb_128x128_path
    return nil unless self.path.present?
    ext = File.extname(self.path)
    base = File.basename(self.path, ext)
    dir = File.dirname(self.path)
    "#{dir}/#{base}_thumb_128x128#{ext}"
  end

  def generate_thumb_scale(path, scale)
    img = MiniMagick::Image.open(self.url)
    width = img[:width] / scale
    height = img[:height] / scale
    img.combine_options do |c|
      c.define "jpeg:size=#{width}x#{height}"
      c.resize "#{width}x#{height}"
    end
    FileStore.bucket.put_object(key: path, body: img.to_blob, acl: 'public-read')
  end

  def generate_thumb(path, width, height)
    img = MiniMagick::Image.open(self.url)
    if (img[:width] * height) < (img[:height] * width)
      remove = ((img[:height] - (img[:width] * height / width)) / 2).round
      img.shave("0x#{remove}")
    else
      remove = ((img[:width] - (img[:height] * width / height)) / 2).round
      img.shave("#{remove}x0")
    end
    img.combine_options do |c|
      c.define "jpeg:size=#{width}x#{height}"
      c.resize "#{width}x#{height}"
    end
    FileStore.bucket.put_object(key: path, body: img.to_blob, acl: 'public-read')
  end
end
