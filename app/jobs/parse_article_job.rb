class ParseArticleJob < ApplicationJob

  def perform(article)
    # Parse article
    ActiveStorage::Current.host = Rails.application.config.action_controller.default_url_options[:host]

    Rails.logger.info "ApplicationJob: ActiveStorage::Current.host = #{ActiveStorage::Current.host}"
    Rails.logger.info "ParseArticleJob: Parsing article #{article.id} #{article.url} #{article.raw_html.attached?}"

    output = `node lib/article_parse.js #{article.url} #{article.raw_html.url}`

    output = output.strip
    readability = JSON.parse(output)

    article.name = readability["title"].presence&.strip if article.name.blank?

    article.update!(
      language: readability["lang"]&.strip,
      byline: readability["byline"]&.strip,
      excerpt: readability["excerpt"]&.strip,
      extracted_content: readability["content"],
      extracted_text: readability["textContent"],
      parse_progress: :complete,
    )
  rescue => e
    Rails.logger.info "ParseArticleJob: #{e}"
    article.update!(parse_progress: :failed)
    raise e if Rails.env.development?
  end
end