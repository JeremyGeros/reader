require 'nokogiri'
require 'open-uri'
require 'rss'

class ScanSourceJob < ApplicationJob

  def perform(source)
    Rails.logger.info "ScanSourceJob: Scanning source #{source.id} #{source.url}"

    url = attempt_to_scan_for_rss(source.url)

    if url
      Rails.logger.info "ScanSourceJob: Found RSS feed at #{url}"
      source.update!(url: url)
      scan_rss(source)
    else
      Rails.logger.info "ScanSourceJob: No RSS feed found at #{source.url} scanning using html"
      scan_html(source)
    end
  
  rescue => e
    Rails.logger.info "ScanSourceJob: #{e}"
    raise e if Rails.env.development?
  end

  def attempt_to_scan_for_rss(source_url)
    # Attempt to scan for RSS feed
    html_response = nil


    begin
      html_response = URI.open(source_url)
      if html_response.content_type == "application/rss+xml" || html_response.content_type == "application/atom+xml" || html_response.content_type == "application/xml"
        Rails.logger.info "ScanSourceJob: Found RSS feed at #{source_url}"
        return source_url
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "ScanSourceJob: #{e}"
    end

    # debugger

    Rails.logger.info "ScanSourceJob: Step 1"

    begin
      feed_url = "#{source_url.gsub(/\/$/, '')}/feed"
      feed_response = URI.open(feed_url)
      if feed_response.content_type == "application/rss+xml" || feed_response.content_type == "application/atom+xml" || feed_response.content_type == "application/xml"
        Rails.logger.info "ScanSourceJob: Found RSS feed at #{feed_url}"
        return feed_url
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "ScanSourceJob: #{e}"
    end

    Rails.logger.info "ScanSourceJob: Step 2"

    begin
      rss_url = "#{source_url.gsub(/\/$/, '')}/rss"
      rss_response = URI.open(rss_url)
      if rss_response.content_type == "application/rss+xml" || rss_response.content_type == "application/atom+xml" || rss_response.content_type == "application/xml"
        Rails.logger.info "ScanSourceJob: Found RSS feed at #{rss_url}"
        return rss_url
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "ScanSourceJob: #{e}"
    end

    if html_response.content_type == "text/html"
      Nokogiri::HTML(html_response).css('link[type="application/rss+xml"]').each do |link|
        Rails.logger.info "ScanSourceJob: Found RSS feed at #{link.attributes["href"].value.strip}"
        return link.attributes["href"].value.strip
      end
    end

    nil
  end


  def scan_rss(source)
    URI.open(source.url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        url = item.link.href.strip
        name = CGI::unescape_html(item.title.content.strip)

        Rails.logger.info "ScanSourceJob: Found article #{url} #{name}"
        # Save item.link and name to database if its an article link
        # and the user hasn't already saved it
        unless source.articles.where(url: url).exists?
          article = source.articles.create(
            url: url,
            name: name,
            user: source.user,
            published_at: item.published.content,
          )
          article.raw_html.attach(
            io: URI.open(url),
            filename: "#{article.id}.html"
          )
        end
      end
    end
  end

  def scan_html(source)
    doc = Nokogiri::HTML(URI.open(source.url))

    doc.css('article').each do |link|
      link.css('a').each do |link|
        # Save link.href and link.text to database if its an article link
        # and the user hasn't already saved it
        # Get the links url from nokogiri a element
        url = link.attributes["href"].value.strip
        name = link.text.strip

        Rails.logger.info "ScanSourceJob: Found article #{url} #{name}"

        unless source.articles.where(url: url).exists?
          article = source.articles.create(
            url: url,
            name: name,
            user: source.user
          )
          article.raw_html.attach(
            io: URI.open(url),
            filename: "#{article.id}.html"
          )
        end
      end
    end
  end
end