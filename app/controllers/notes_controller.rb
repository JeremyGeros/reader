class NotesController < ApplicationController
  before_action :require_user
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def index
    @notes_by_article = Current.user.notes.preload(:article).group_by(&:article)
  end

  def show
  end

  def new
    @note = Current.user.notes.new
  end

  def edit
  end

  def create
    @article = Current.user.articles.find(params[:note][:article_id])
    @note = Current.user.notes.new(note_params.merge(article: @article))

    respond_to do |format|
      if @note.save
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render json: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { render json: @note }
      else
        format.html { render :edit }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
      format.json { render json: @note }
    end
  end

  private

    def set_note
      @note = Current.user.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:text, :highlight_type)
    end


end