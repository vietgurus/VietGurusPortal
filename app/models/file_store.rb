module FileStore
  extend ActiveSupport::Concern

  def self.presigned_path_to_upload(path)
    FileStore.bucket.object(path).presigned_url(:put)
  end

  def self.bucket
    Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET'])
  end

  def self.random_file_path(dir, ext)
    begin
      path = "#{dir}/#{SecureRandom.hex(64)}#{ext}"
    end while FileStore.check_if_exists?(path)
    path
  end

  def self.check_if_exists?(path)
    Aws::S3::Client.new.head_object(bucket: ENV['AWS_S3_BUCKET'], key: path).present?
  rescue
    false
  end

  def self.copy_from_temp_path(from, dirTo)
    obj_from = FileStore.bucket.object(from)
    obj_to = FileStore.bucket.object(FileStore.random_file_path(dirTo, File.extname(from)))
    obj_from.copy_to(obj_to, acl: 'public-read')

    obj_to.key
  end

  def self.delete(path)
    FileStore.bucket.object(path).delete
    return true
  rescue => e
    Rails.logger.error "Failure when delete object from S3. Details: #{e}; #{e.backtrace}"
    return false
  end
end
