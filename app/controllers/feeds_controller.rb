class FeedsController < ApplicationController
  helper Pagy::Frontend
  
  def index
    @pagy, @articles = pagy(@articles.most_recent.common_preloads.ready, items: 10)

    respond_to do |f|
      f.turbo_stream { render 'index' }
      f.html { render 'index' }
    end
  end

  def all
    @articles = Current.user.articles.read_status_new
    @page = 'all'
    index
  end

  def feeds
    @articles = Current.user.articles.read_status_new.where.not(source: nil)
    @page = 'feeds'
    index
  end

  def read_later
    @articles = Current.user.articles.read_status_new.where(source: nil)
    @page = 'read_later'
    index
  end

  def read
    @articles = Current.user.articles.read_status_read
    @page = 'read'
    index
  end

end