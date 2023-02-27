class FeedsController < ApplicationController
  
  def index
    @pagy, @articles = pagy(Current.user.articles.most_recent.ready)
  end

end