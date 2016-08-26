require_dependency 'issues_helper'

module IssuesHelper

  # Función helper empleada para mejorar la muestra de valores de los distintos proyectos necesarios:
  def custom_values_by_projects(projects, custom_fields)
    values_by_projects = {}
    projects.each do |project|
      values_by_projects.merge!(project.id => {})
    end
    values = CustomValue.where("customized_type = ? AND customized_id IN (?) AND custom_field_id IN (?)", Project.name.demodulize, projects.map(&:id), custom_fields.map(&:id) )
    values.each do |value|
      values_by_projects[value.customized_id].merge!(value.custom_field_id => value.value)
    end
    values_by_projects
  end

  # Funcion helper empleada para visualizar el listado de subproyectos anidados en un proyecto raiz:
  def render_subproject_nested_lists(projects)
    s = ''
    if projects.any?
      ancestors = []
      original_project = @project
      projects.sort_by(&:lft).reverse_each do |project|
        # set the project environment to please macros.
        @project = project
        if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
          s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
        else
          ancestors.pop
          s << "</li>"
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last))
            ancestors.pop
            s << "</ul></li>\n"
          end
        end
        classes = (ancestors.empty? ? 'root' : 'child')
        if(classes == 'root')
          s << "<li class='root'><div class='root'>"
        else
          s << "<li class='child'><div class='child'>"
        end
        #s << "<li class='#{classes}'><div class='#{classes}'>"
        s << h(block_given? ? yield(project) : project.name)
        s << "</div>\n"
        ancestors << project
      end
      s << ("</li></ul>\n" * ancestors.size)
      @project = original_project
    end
    s.html_safe
  end
end
