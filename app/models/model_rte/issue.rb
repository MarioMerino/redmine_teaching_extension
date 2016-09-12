require_dependency 'issue'

class Issue

  has_and_belongs_to_many :projects

  alias_method :issue_visible?, :visible? # alias_method(new_name, old_name) -> self. Makes <i>new_name</i> a new copy of the method <i>old_name</i>.
  alias_method :issue_notified_users, :notified_users

  self.singleton_class.send(:alias_method, :issue_visible_condition, :visible_condition)


  # Comprobar si tanto los usuarios del sistema como el usuario actual, tienen permisos suficientes para ver la Issue
  # del Proyecto en cuestión, y llevar a cabo la propagación de la misma entre alumnos de la asignatura:
  def visible?(usr = nil)
    issue_visible?(usr) || other_project_visible(usr)
  end

  # Devuelve true si el usuario del sistema ó usuario actual tiene permiso para visualizar
  # la Issue de otros Proyectos externos
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
end