class ExternalArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def read_later
  end


  def read_later_save
    @article = Current.user.articles.new(url: params[:url])
    if @article.save!
      respond_to do |format|
        format.html
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: { success: false } }
      end
    end
  end
end