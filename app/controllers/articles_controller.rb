class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :reparse]

  def index
    @articles = Current.user.articles.all
  end

  def show
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

  def edit
  end

  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_path(@article) }
        format.json { render json: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article.destroy
    redirect_to root_url
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
    params.require(:article).permit(:url, :name, :read_status, :edited_content)
  end

end