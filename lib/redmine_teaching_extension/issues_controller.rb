require_dependency 'issues_controller'

class IssuesController

  before_filter :authorize, :except => [:index, :load_students_selection, :show] #:allow_target_projects] # Autorizar al usuario para realizar todas las acciones, excepto 'index', 'load_students_selection' y 'show'
  before_filter :set_project, :only => [:load_students_selection] # Establecer un proyecto para ser cargado, sólo para la accion 'load_students_selection'
  #append_before_filter :set_members, :only => [:create, :update]

  # Función de carga de usuarios a partir de una issue:
  def load_students_selection
    #@issue = Issue.find(params[:id])
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
    else
      @issue = Issue.new
    end
    @issue.project = @project
  end

  # MODIFICAR PARA PODER CREAR ISSUE DESDE 'PROPAGATE ISSUE TO SUBPROJECTS...'
  def create
    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    if @issue.save
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
          if params[:continue]
            attrs = {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?}
            redirect_to new_project_issue_path(@issue.project, :issue => attrs)
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

  #def allow_target_projects
  #  if User.current.allowed_to?(:add_issues, @projects)
  #    @allowed_projects = Issue.allowed_target_projects
  #    if params[:issue]
  #      @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:issue][:project_id].to_s}
  #      if @target_project
  #        target_projects = [@target_project]
  #      end
  #    end
  #  end
  #  target_projects ||= @projects

  #  @custom_fields = target_projects.map{|p|p.all_issue_custom_fields.visible}.reduce(:&)
  #  @assignables = target_projects.map(&:assignable_users).reduce(:&)
  #  @trackers = target_projects.map(&:trackers).reduce(:&)
  #  @versions = target_projects.map {|p| p.shared_versions.open}.reduce(:&)
  #  @categories = target_projects.map {|p| p.issue_categories}.reduce(:&)

  #  @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)

  #  @issue_params = params[:issue] || {}
  #  @issue_params[:custom_field_values] ||= {}
  #end

  private
    # Se establece el listado de miembros que se va a cargar para aplicarles la propagación de issues:
    def set_members
      #@projects = []
      @subproject_members = []
      #@projects << Project.find(params[:project_id]) if params[:project_id]
      @subprojects << Project.where(:parent_id => project)
      @subprojects.each do |subproject|
        @subproject_members += Principal.member_of(subproject)
      end
      #if params[:issue] && params[:issue][:project_ids]
      #  params[:issue][:project_ids].reject!(&:blank?)
      #  if params[:issue][:project_ids].present?
      #    Project.find(params[:issue][:project_ids]).each do |p|
      #      @projects << p
      #    end
      #  end
      #end
      @users = @subproject_members
      @users << Issue.find(params[:author_id]) if params[:author_id]
      @users << Issue.find(params[:assigned_to_id]) if params[:assigned_to_id]
      @users.uniq.sort
      #@projects.uniq!
      #@issue.projects = @projects
    end

    # Se actualiza el histórico de la issue propagada a los proyectos en cuestión:
    #def update_project_journal
    #  @current_journal = @issue.init_journal(User.current) # Se asocia el histórico actual al usuario actual.
    #  @projects_before_change = @issue.projects # Se declara la situación previa a cualquier actualización del histórico.

      # Se añade en el histórico actual, el registro de la situación actual del mismo (antes de actualizar)
    #  @current_journal.details << JournalDetail.new(:property => 'projects',
    #                                                :old_value => (@projects_before_change - @projects).reject(&:blank?),
    #                                                :value => nil) if (@projects_before_change - @projects).present?

      # Se añade en el histórico actual, el registro actualizado del histórico (una vez realizado los cambios pertinentes)
    #  @current_journal.details << JournalDetail.new(:property => 'projects',
    #                                                :old_value => nil,
    #                                                :value => (@projects - @projects_before_change).reject(&:blank?).join(",")) if (@projects - @projects_before_change).present?
    #end

    # Se establece un proyecto en concreto para ser cargado y propagarle la issue en cuestión:
    def set_project
      project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound # Tratamiento de una excepción: No se encuentra un registro de proyecto en la BD...
      render_404 # ... por tanto, lanzar error 404.
    end

end