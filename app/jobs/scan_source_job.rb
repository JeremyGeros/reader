require 'nokogiri'
require 'open-uri'
require 'rss'

class ScanSourceJob < ApplicationJob

  def perform(source)
    Rails.logger.info "ScanSourceJob: Scanning source #{source.id} #{source.url}"

    url = attempt_to_scan_for_rss(source)

    if url
      Rails.logger.info "ScanSourceJob: Found RSS feed at #{url}"
      source.update!(url: url)
      scan_rss(source)
    else
      Rails.logger.info "ScanSourceJob: No RSS feed found at #{source.url} scanning using html"
      scan_html(source)
    end

    source.update!(last_scanned_at: DateTime.now, scan_progress: :complete)
  
  rescue => e
    Rails.logger.info "ScanSourceJob: #{e}"
    source.update!(scan_progress: :failed)
    raise e if Rails.env.development?
  end

  def attempt_to_scan_for_rss(source)
    # Attempt to scan for RSS feed
    html_response = nil
    source_url = source.url
    found_url = nil

    begin
      html_response = URI.open(source_url)
      if html_response.content_type == "application/rss+xml" || html_response.content_type == "application/atom+xml" || html_response.content_type == "application/xml"
        Rails.logger.info "ScanSourceJob: Found RSS feed at #{source_url}"
        found_url = source_url
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "ScanSourceJob: #{e}"
    end

    parsed_html = nil

    Rails.logger.info "ScanSourceJob: Step 1"

    if found_url.nil? && html_response&.content_type == "text/html"
      parsed_html = Nokogiri::HTML(html_response)
      parsed_html.css('link[type="application/rss+xml"], link[type="application/atom+xml"], link[type="application/xml"]').each do |link|
        Rails.logger.info "ScanSourceJob: Found RSS feed at from html_content #{link.attributes["href"].value.strip}"
        found_url = link.attributes["href"].value.strip
      end
    end

    Rails.logger.info "ScanSourceJob: Step 2"
    if found_url.nil?
      begin
        endings = ["/feed", "/rss", "/feed.atom", "/feed.rss", "/feed.rss/", "/feed.xml"]
        endings.each do |ending|
          next if found_url

          feed_url = "#{source_url.gsub(/\/$/, '')}#{ending}"
          feed_response = URI.open(feed_url)
          if feed_response.content_type == "application/rss+xml" || feed_response.content_type == "application/atom+xml" || feed_response.content_type == "application/xml"
            Rails.logger.info "ScanSourceJob: Found RSS feed at #{feed_url}"
            found_url = feed_url
            break
          end
        end
      rescue OpenURI::HTTPError => e
        Rails.logger.info "ScanSourceJob: #{e}"
      end
    end
  
    parse_name = (parsed_html || Nokogiri::HTML(html_response)).css('title').text
    if (source.name == source.url) && parse_name.present?
      Rails.logger.info "ScanSourceJob: Found name #{parse_name} at #{source_url}"
      source.update!(name: parse_name)
    end

    found_url
  end


  def scan_rss(source)
    article_limit = source.temporary_at.nil? ? 10 : 3

    URI.open(source.url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each_with_index do |item, index|
        break if index >= article_limit

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
    article_limit = source.temporary_at.nil? ? 10 : 3

    doc = Nokogiri::HTML(URI.open(source.url))

    host = URI.parse(source.url).host

    doc.css('article').each do |link|
      link.css('a').each_with_index do |link, index|
        break if index >= article_limit

        # Save link.href and link.text to database if its an article link
        # and the user hasn't already saved it
        # Get the links url from nokogiri a element
        url = link.attributes["href"].value.strip

        # If the url is relative, make it absolute
        url = "https://#{host}#{url}" if url.start_with?("/")


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