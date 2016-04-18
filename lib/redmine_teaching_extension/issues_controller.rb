require_dependency 'issues_controller'

class IssuesController

  before_filter :authorize, :except => [:index, :load_projects_selection, :show] # Autorizar al usuario para realizar todas las acciones, excepto 'index', 'load_students_selection' y 'show'
  before_filter :set_project, :only => [:load_projects_selection] # Establecer un proyecto para ser cargado, sólo para la accion 'load_students_selection'
  append_before_filter :set_projects, :only => [:create, :update]

  # Función de carga de proyectos a partir de una issue:
  def load_projects_selection
    #@issue = Issue.find(params[:id])
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
    else
      @issue = Issue.new
    end
    @issue.project = @project
  end

  private
    # Se establece el listado de proyectos que se va a cargar para aplicarles la propagación de issues:
    def set_projects
      @projects = []
      @projects << Project.find(params[:project_id]) if params[:project_id]
      if params[:issue] && params[:issue][:project_ids]
        Project.find((params[:issue][:project_ids]).reject!(&:blank?)).each do |p|
          @projects << p
        end
      end
      @projects.uniq!
      @issue.projects = @projects
    end

    # Se establece un proyecto en concreto para ser cargado y propagarle la issue en cuestión:
    def set_project
      project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound # Tratamiento de una excepción: No se encuentra un registro de proyecto en la BD...
      render_404 # ... por tanto, lanzar error 404.
    end
end