class FeedsController < ApplicationController
  
  def all
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new)
    render 'index'
  end

  def feeds
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new.where.not(source: nil))
    render 'index'
  end

  def read_later
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_new.where(source: nil))
    render 'index'
  end

  def archived
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.read_status_read)
    render 'index'
  end

end