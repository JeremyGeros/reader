class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :reparse]

  def index
    @articles = Article.all
  end

  def new
    @article = Current.user.articles.new
  end

  def create
    @article = Current.user.articles.new(article_params)
    if @article.save
      redirect_to root_url
    else
      render :new
    end
  end

  def reparse
    @article.raw_html.destroy
    @article.read_later_save
    @article.parse!
    redirect_to root_url
  end

  private

  def set_article
    @article = Current.user.articles.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:url, :name)
  end

end