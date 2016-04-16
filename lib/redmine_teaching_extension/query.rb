require_dependency 'query'

class Query

  alias_method :principal_project_statement, :project_statement

  # Función que devuelve el array de proyectos disponibles para ser seleccionados para su propagación:
  def project_statement

    project_agrupation = principal_project_statement

    if project_agrupation
      "((#{project_agrupation}) OR issues.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
    else
      nil
    end
  end

end