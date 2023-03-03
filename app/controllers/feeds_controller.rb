class FeedsController < ApplicationController
  
  def all
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new)
    @page = 'all'
    render 'index'
  end

  def feeds
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new.where.not(source: nil))
    @page = 'feeds'
    render 'index'
  end

  def read_later
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new.where(source: nil))
    @page = 'read_later'
    render 'index'
  end

  def read
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_read)
    @page = 'read'
    render 'index'
  end

end