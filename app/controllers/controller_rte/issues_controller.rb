require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_filter :authorize, :except => [:index, :show, :load_students_selection, :destroy] # Autorizar al usuario para realizar todas las acciones, excepto 'index', 'load_students_selection', 'show' y 'destroy'
  before_filter :set_project, :only => [:new, :create, :update_form, :load_students_selection] # Establecer un proyecto para ser cargado

  accept_rss_auth :index, :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  # Función de carga de proyectos a partir de una issue:
  def load_students_selection
    #@issue = Issue.find(params[:id])
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
    else
      @issue = Issue.new
    end
    @issue.project = @project
  end

  def create
    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    if @issue.save
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
          if params[:continue] || params[:continue_issue]
            attrs = {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?}
            if @issue.project.parent_id
              redirect_to new_project_issue_path(@issue.project.parent_id, :issue => attrs)
            elsif @issue.project
              redirect_to new_project_issue_path(@issue.project, :issue => attrs)
              #redirect_to project_copy_issue_path(@project, @issue)
            end
          elsif params[:propagate]
            #redirect_to issue_path(@issue)
            redirect_to project_copy_issue_path(@project, @issue)
          else
            redirect_to issue_path(@issue)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end

  private
  # Se establece un proyecto en concreto para ser cargado y propagarle la issue en cuestión:
  def set_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound # Tratamiento de una excepción: No se encuentra un registro de proyecto en la BD...
    render_404 # ... por tanto, lanzar error 404.
  end

end