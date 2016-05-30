require_dependency 'query'
require_dependency 'issue_query'

class Query

  alias_method :principal_project_statement, :project_statement

  # Función que devuelve el array de proyectos/subproyectos cuyos estados son aptos, por lo que pueden seleccionados para su propagación:
  def project_statement

    project_clauses = principal_project_statement
    if self.is_a?(IssueQuery)
      if project_clauses
        "((#{project_clauses}) OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE project_id = #{project.id}))"
      else
        nil
      end
    else
      project_clauses
    end
  end

end

class IssueQuery < Query
  # Función que devuelve las versiones del proyecto en cuestión (se validan aquellas que cumplan las condiciones establecidas -> options[:conditions])
  def versions(options={})
    Version.visible.where(options[:conditions]).all(:include => :project, :conditions => :principal_project_statement)
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message) # Tratamiento de excepción generada cuando la consulta no puede ser ejecutada por la BD
  end
end