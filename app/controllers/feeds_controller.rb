class FeedsController < ApplicationController
  
  def all
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready)
    render 'index'
  end

  def feeds
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.where.not(source: nil))
    render 'index'
  end

  def read_later
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready.where(source: nil))
    render 'index'
  end

end