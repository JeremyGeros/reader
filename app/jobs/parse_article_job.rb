class ParseArticleJob < ApplicationJob

  def perform(article)
    # Parse article
    ActiveStorage::Current.host = Rails.application.config.action_controller.default_url_options[:host]

    Rails.logger.info "ApplicationJob: ActiveStorage::Current.host = #{ActiveStorage::Current.host}"
    Rails.logger.info "ParseArticleJob: Parsing article #{article.id} #{article.url} #{article.raw_html.attached?}"

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
  rescue => e
    Rails.logger.info "ParseArticleJob: #{e}"
    article.update!(parse_progress: :failed)
    raise e if Rails.env.development?
  end
end