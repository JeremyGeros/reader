class SourcesController < ApplicationController
  before_action :require_user
  before_action :set_source, only: [:show, :edit, :preview, :update, :destroy, :scan]

  def index
    @sources = Current.user.sources.not_preview.order(:name)
  end

  def show
  end

  def new
    @source = Current.user.sources.new
  end

  def create
    @source = Current.user.sources.new(source_params)
    @source.temporary_at = DateTime.now
    
    respond_to do |format|
      if @source.save
        format.html { redirect_to preview_source_path(@source), notice: 'Source was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def preview
  end


  def edit
  end

  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @source.destroy
    respond_to do |format|
      format.html { redirect_to sources_url, notice: 'Source was successfully destroyed.' }
    end
  end

  def scan
    @source.scan!
    if @source.temporary_at?
      redirect_to preview_source_path(@source)
    else
      redirect_to @source
    end
  end

  private

    def set_source
      @source = Current.user.sources.find(params[:id])
    end

    def source_params
      params.require(:source).permit(:name, :url, :scan_interval, :temporary_at)
    end


end