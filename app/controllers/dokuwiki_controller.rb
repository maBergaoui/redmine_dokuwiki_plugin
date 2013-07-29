class DokuwikiController < ApplicationController
  unloadable
  
  layout 'base'
  
  before_filter :find_project, :authorize, :only => [:show]
  
  def show
    @tab_text = Dokuwiki.get_tab_text(@project)
  end
  
  private
  
  def find_project
  # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
    
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
