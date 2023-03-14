class ParseArticleJob < ApplicationJob

  def perform(article)
    # Parse article
    ActiveStorage::Current.host = Rails.application.config.action_controller.default_url_options[:host]

    Rails.logger.info "ApplicationJob: ActiveStorage::Current.host = #{ActiveStorage::Current.host}"
    Rails.logger.info "ParseArticleJob: Parsing article #{article.id} #{article.url} #{article.raw_html.attached?}"

    if is_video?(article.url)
      video_parse(article)
    else
      article_parse(article)
    end

    
  rescue => e
    Rails.logger.info "ParseArticleJob: #{e}"
    article.update!(parse_progress: :failed)
    raise e if Rails.env.development?
  end

  def article_parse(article)
    output = `node lib/article_parse.js #{article.url} #{article.raw_html.url} #{article.id}`

    output = output.strip
    readability = JSON.parse(output)

    article.name = readability["title"].presence&.strip if article.name.blank?

    extracted_text = readability["textContent"]&.strip
    extracted_text&.gsub!(/ {2,}/, " ")

    if !article.source && !article.favicon.attached?
      url = readability["icon"]&.strip || readability["shortcut icon"]&.strip 
      if url
        url = "https://#{URI.parse(article.url).host}#{url}" if url.start_with?("/")
        article.favicon_url = url
      end
    end

    article.update!(
      byline: readability["author"]&.strip || readability["byline"]&.strip,
      excerpt: readability["excerpt"]&.strip || readability["description"]&.strip,
      extracted_content: readability["content"],
      extracted_text: extracted_text,
      ttr: readability["ttr"],
      header_image_url: readability["image"]&.strip,
      parse_progress: :complete,
    )
  end

  def is_video?(url)
    url = URI.parse(url)
    url.host.include?("youtube.com") || url.host.include?("youtu.be") || url.host.include?("vimeo.com")
  end

  def video_parse(article)
    video = VideoInfo.new(article.url)

    article.name = video.title if article.name.blank?
    article.excerpt = video.description if article.excerpt.blank?
    article.header_image_url = video.thumbnail_large unless article.header_image.attached?
    article.extracted_content = video.embed_url
    article.extracted_text = video.description
    article.ttr = video.duration
    article.byline = video.author
    article.favicon_url = video.author_thumbnail unless article.favicon.attached?
    article.kind = :video

    article.update!(
      parse_progress: :complete,
    )
  end
end