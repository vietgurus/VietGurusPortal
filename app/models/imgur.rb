require 'typhoeus'

module Imgur
  class Base
    def self.api_get(url)
      tries ||= 2
      refresh_token if token_expired?
      headers = { "Authorization" => "Bearer #{ENV["IMGUR_TOKEN"]}" }
      response = Typhoeus.get(url, headers: headers)
      raise ImgurError if response.response_code >= 400
      response
    rescue ImgurError
      Rails.logger.error "Error"
      Rails.logger.error response.inspect
      error = response.body["data"]["error"]
      refresh_token && (tries -= 1).zero? ? (raise ImgurError.new(error)) : retry
    end

    def self.api_post(url, params)
      tries ||= 2
      refresh_token if token_expired?
      headers = { "Authorization" => "Bearer #{ENV["IMGUR_TOKEN"]}" }
      response = Typhoeus.post(url, headers: headers, body: params)
      raise ImgurError if response.response_code >= 400
      response
    rescue ImgurError
      Rails.logger.error "Error"
      Rails.logger.error response.inspect
      error = JSON.parse(response.body)["data"]["error"]
      refresh_token && (tries -= 1).zero? ? (raise ImgurError.new(error)) : retry
    end

    def self.api_delete(url)
      tries ||= 2
      refresh_token if token_expired?
      headers = { "Authorization" => "Bearer #{ENV["IMGUR_TOKEN"]}" }
      response = Typhoeus.delete(url, headers: headers)
      raise ImgurError if response.response_code >= 400
      response
    rescue ImgurError
      Rails.logger.error "Error"
      Rails.logger.error response.inspect
      error = response.body["data"]["error"]
      refresh_token && (tries -= 1).zero? ? (raise ImgurError.new(error)) : retry
    end

    def self.refresh_token
      token_from_redis = ENV["IMGUR_TOKEN"]
      if token_from_redis.blank?
        url = "https://api.imgur.com/oauth2/token"
        params = {
            refresh_token: ENV["IMGUR_REFRESH"],
            client_id: ENV["IMGUR_ID"],
            client_secret: ENV["IMGUR_SECRET"],
            grant_type: :refresh_token
        }
        headers = { "Authorization" => "Bearer #{ENV["IMGUR_ID"]}" }
        response = Typhoeus.post(url, headers: headers, body: params)
        body = JSON.parse(response.body)

        ENV["IMGUR_TIMEOUT"] = calculate_timeout(body["expires_in"])
        ENV["IMGUR_TOKEN"] = body["access_token"]
      end

      true
    end

    def self.token_expired?
      (ENV["IMGUR_TIMEOUT"].try(:to_i) || 0) < DateTime.now.to_i
    end

    def self.calculate_timeout(expires_in)
      (DateTime.now.to_i + expires_in).to_s
    end

    def self.parse_id(link)
      File.basename(link, ".*")
    end
  end

  class Album < Base
    def self.all
      url = "https://api.imgur.com/3/account/#{ENV["IMGUR_USERNAME"]}/albums"
      JSON.parse(api_get(url).body)["data"]
    end

    def self.get(imgur_id)
      all.find { |a| a["id"] == imgur_id }
    end

    def self.find(title)
      all.find { |a| a["title"] == title }
    end

    def self.profile
      find("Users") || create(title: "Users")
    end

    def self.create(options = {})
      url = "https://api.imgur.com/3/album"
      params = {
          ids: options[:ids],
          title: options[:title],
          description: options[:description],
          privacy: options[:privacy],
          cover: options[:cover]
      }.compact
      JSON.parse(api_post(url, params).body)["data"]
    end

    def self.add_images(imgur_id, image_ids)
      url = "https://api.imgur.com/3/album/#{imgur_id}/add"
      params = { ids: image_ids }
      JSON.parse(api_post(url, params).body)["data"]
    end

    def self.delete(imgur_id)
      url = "https://api.imgur.com/3/album/#{imgur_id}"
      JSON.parse(api_delete(url).body)
    end
  end

  # Ref https://api.imgur.com/endpoints/image
  class Image < Base
    def self.create(options)
      url = "https://api.imgur.com/3/image"
      params = {
          image: options[:image].try(:tempfile),
          album: options[:album_id],
          type: options[:type] || "file", # "file" || "base64" || "URL"
          title: options[:title],
          description: options[:description]
      }.compact
      JSON.parse(api_post(url, params).body)["data"]
    end

    def self.delete(imgur_id)
      url = "https://api.imgur.com/3/image/#{imgur_id}"
      JSON.parse(api_delete(url).body)
    end
  end

  class ImgurError < StandardError
  end
end