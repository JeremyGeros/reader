class ImportsController < ApplicationController

  def index    
    @import = Current.user.imports.new
    @previous_imports = Current.user.imports.all.order(created_at: :desc)
  end

  def show
    @import = Current.user.imports.find(params[:id])
  end

  def create
    @import = Current.user.imports.new(import_params)
    @import.save!

    if ImportJob.perform_later(@import)
      redirect_to import_path(@import)
    else
      @previous_imports = Current.user.imports.all.order(created_at: :desc)
      render :index
    end
  end

  def status
    @import = Current.user.imports.find(params[:id])
    render json: { status: @import.status }
  end

  private

  def import_params
    params.require(:import).permit(:file, :import_type)
  end
end