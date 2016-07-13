require_dependency 'issues_controller'

class IssuesController

  menu_item :new_issue, :only => [:new, :create]

  before_filter :authorize, :except => [:index, :load_students_selection, :show] #:allow_target_projects] # Autorizar al usuario para realizar todas las acciones, excepto 'index', 'load_students_selection' y 'show'
  before_filter :set_project, :only => [:load_students_selection] # Establecer un proyecto para ser cargado, sólo para la accion 'load_students_selection'
  #before_filter :build_new_issue_from_params, :only => [:new, :create]
  #before_filter :build_new_issue_subprojects_from_params, :only => [:new, :create]
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

  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
    end
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
          if params[:continue]
            attrs = {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?}
            if @issue.project.parent_id
              # Crear bucle de propagación de la issue creada entre subproyectos ...
              redirect_to new_project_issue_path(@issue.project.parent_id, :issue => attrs)
            else
              #redirect_to new_project_issue_path(@issue.project, :issue => attrs)
              redirect_to project_copy_issue_path(@project, @issue)
              # Crear bucle de propagación de la issue creada entre subproyectos ...
            end
          #elsif params[:propagate]
            # REDIRECCIONAR A copy_from, Y PROPAGACION DE ISSUE REALIZADA A TODOS LOS SUBPROYECTOS DEL PROYECTO ACTUAL...
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

=begin
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      if params[:copy_from]
        begin
          @copy_from = Issue.visible.find(params[:copy_from])
          @copy_attachments = params[:copy_attachments].present? || request.get?
          @copy_subtasks = params[:copy_subtasks].present? || request.get?
          @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
        rescue ActiveRecord::RecordNotFound
          render_404
          return
        end
      end
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end

    @issue.project = @project
    @issue.author ||= User.current
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
    @issue.safe_attributes = params[:issue]

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, @issue.new_record?)
    @available_watchers = @issue.watcher_users
    if @issue.project.users.count <= 20
      @available_watchers = (@available_watchers + @issue.project.users.sort).uniq
    end
  end
=end

=begin
    def build_new_issue_subprojects_from_params
      if params[:id].blank?
        @issue = Issue.new
        if params[:copy_from_subprojects]
          begin
            @copy_from_subprojects = Issue.visible.find(params[:copy_from_subprojects])
            @copy_attachments = params[:copy_attachments].present? || request.get?
            @copy_subtasks = params[:copy_subtasks].present? || request.get?
            @issue.copy_from_subprojects(@copy_from_subprojects, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
          rescue ActiveRecord::RecordNotFound
            render_404
            return
          end
        end
        @issue.project = @project
      else
        @issue = @project.issues.visible.find(params[:id])
      end
      #@issue.project.descendants.each do |subproject|
      @issue.project = @project
      @issue.author ||= User.current
      # Tracker must be set before custom field values
      @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
      if @issue.tracker.nil?
        render_error l(:error_no_tracker_in_project)
        return false
      end
      @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
      @issue.safe_attributes = params[:issue]

      @priorities = IssuePriority.active
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current, @issue.new_record?)
      @available_watchers = @issue.watcher_users
      if @issue.project.users.count <= 20
        @available_watchers = (@available_watchers + @issue.project.users.sort).uniq
      end
      #end
    end
=end

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

      @users = @subproject_members
      @users << Issue.find(params[:author_id]) if params[:author_id]
      @users << Issue.find(params[:assigned_to_id]) if params[:assigned_to_id]
      @users.uniq.sort
      #@projects.uniq!
      #@issue.projects = @projects
    end

    # Se establece un proyecto en concreto para ser cargado y propagarle la issue en cuestión:
    def set_project
      project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound # Tratamiento de una excepción: No se encuentra un registro de proyecto en la BD...
      render_404 # ... por tanto, lanzar error 404.
    end

end