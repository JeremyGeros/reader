module Faviconable
  extend ActiveSupport::Concern

  included do
    has_one_attached :favicon

    def favicon_url=(url)
      return if url.blank?

      io = URI.open(url)
      uri = URI.parse(url)
      filename = File.basename(uri.path)

      favicon.attach(
        io: io,
        filename: filename,
      )
    end
  end
end