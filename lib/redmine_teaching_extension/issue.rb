require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

  alias_method :issue_visible?, :visible? # alias_method(new_name, old_name) -> self. Makes <i>new_name</i> a new copy of the method <i>old_name</i>.

  self.singleton_class.send(:alias_method, :issue_visible_condition, :visible_condition)


  # Comprobar si tanto los usuarios del sistema como el usuario actual, tienen permisos suficientes para ver la Issue,
  # y llevar a cabo la propagación de la misma entre alumnos de la asignatura:
  def visible?(usr = nil)
    issue_visible?(usr) || other_project_visible(usr)
  end

  # Devuelve true si el usuario del sistema ó usuario actual tiene permiso para ver la issue
  # (nueva implementación del método 'visible?' existente en models/issue.rb)
  def other_project_visible?(usr = nil)
    other_projects = self.projects - [self.project]
    other_projects_visibility = false

    other_projects.each do |project|
      if other_projects_visibility == false
        other_projects_visibility = (usr || User.current).allowed_to?(:view_issues, project) do |role, user|
          if user.logged?
            case role.issues_visibility
              when 'all'
                true
              when 'default'
                !self.is_private? || (self.author == user || user.is_or_belongs_to?(assigned_to))
              when 'own'
                self.author == user || user.is_or_belongs_to?(assigned_to)
              else
                false
            end
          else
            !self.is_private?
          end
        end
      else
        break
      end
    end
    other_projects_visibility
  end

  # Función que devuelve una consulta SQL usada para encontrar todas las issues visibles por el usuario especificado:
  def self.visible_condition(user, options={})
    statement_by_role = {}
    user.projects_by_role.each do |role, projects|
      if role.allowed_to?(:view_issues) && projects.any?
        statement_by_role[role] = "project_id IN (#{projects.collect(&:id).join(',')})"
      end
    end
    authorized_projects = statement_by_role.values.join(' OR ')

    "(#{issue_visible_condition(user, options)} OR #{Issue.table_name}.id IN (SELECT issue_id FROM issues_projects WHERE (#{authorized_projects}) ))"
  end

end