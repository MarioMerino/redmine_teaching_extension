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

  # Función que devuelve la representación textual de los detalles del journal (histórico de la issue)
=begin
  def show_detail(detail, no_html=false, options={})

    if detail.property == 'projects'
      value = detail.value
      old_value = detail.old_value

      if value.present?
        value = value.split(',')
        list = content_tag("span", h(value.join(', ')), class: "journal_projects_details",
                           data: {detail_id: detail.id}, style: value.size>1 ? "display:none;":"")
        link = link_to l(:label_details).downcase, "#", class: "show_journal_details",
                       data: {detail_id: detail.id} if value.size>1
        linkHide = link_to l(:label_hide_details).downcase, "#", class: "hide_journal_details",
                           data: {detail_id: detail.id} if value.size>1

        details = "(#{link}#{linkHide}#{list})" unless no_html

        "#{value.size} #{value.size>1 ? l(:text_journal_projects_added) : l(:text_journal_project_added)} #{details}".html_safe

      elsif old_value.present?
        old_value = old_value.split(',')
        list = content_tag("del", h(old_value.join(', ')), class: "journal_projects_details",
                           data: {detail_id: detail.id}, style: old_value.size>1 ? "display:none;":"")
        link = link_to l(:label_details).downcase, "#", class: "show_journal_details",
                       data: {detail_id: detail.id} if old_value.size>1
        linkHide = link_to l(:label_hide_details).downcase, "#", class: "hide_journal_details",
                           data: {detail_id: detail.id} if old_value.size>1

        details = "(#{link}#{linkHide}#{list})" unless no_html

        "#{old_value.size} #{old_value.size>1 ? l(:text_journal_projects_deleted) : l(:text_journal_project_deleted)} #{details}".html_safe

      end
    else
      principal_show_detail(detail, no_html, options)
    end
  end
  alias_method :principal_show_detail, :show_detail
=end

=begin
  def principals_options_for_selection(collection, selected=nil)
    s = ''
    groups = ''
    collection.sort.each do |element|
      selected_attribute = ' selected="selected"' if option_value_selected?(element, selected) || element.id.to_s == selected
      (element.is_a?(Group) ? groups : s) << %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>)
    end
    unless groups.empty?
      s << %(<optgroup label="#{h(l(:label_group_plural))}">#{groups}</optgroup>)
    end
    s.html_safe
  end
=end

  # Función para cargar correctamente una selección múltiple de usuarios, mediante checkbox:
=begin
  def principals_check_box_propagation(name, principals, selected=nil)
    s = ''
    if params[:assigned_to_ids]
      assigned_to_id = params[:assigned_to_ids].split(',')
      issue_members = ( assigned_to_id.present? ? Issue.find(assigned_to_id) : [] )
    else
      issue_members = @issue.assignable_users_subprojects
    end
    allowed_members = issue_members

    custom_fields = CustomField.select("id, name")#.where(:type => "ProjectCustomField")
    custom_values = custom_values_by_members(allowed_members, custom_fields)
    options_for_selects = {}
    custom_fields.each do |field|
      options_for_selects.merge!(field.name.parameterize => []) # parameterize -> reemplaza el nombre completo por parámetros separados por guión, para adaptarlo mejor a una URL. (ejemplo: .../mario-merino)
    end

    principals.sort.each do |principal|
      custom_fields_data = {}
      if allowed_members.include?(principal)
        custom_fields.each do |f|
          value = custom_values[principal.id][f.id]
          value = value.join(",") if value.is_a?(Array)
          custom_fields_data.merge!(f.name.parameterize => value)
          value.split(",").each do |val|
            options_for_selects[f.name.parameterize] << val unless options_for_selects[f.name.parameterize].include?(val) || val.blank?
          end if value.present?
        end
      end
      #s << "<option value=#{principal.id}>#{ check_box_tag name, principal.id, false, :id => nil } #{h principal.name}</option>\n"
      selected_attribute = 'selected="selected"' if option_value_selected?(principal, selected) || principal.id.to_s == selected
      s << %(<option value="#{principal.id}"#{selected_attribute}>#{check_box_tag name, principal.id, @issue != nil && allowed_members.include?(principal),
                     :class => ("inactive" unless allowed_members.include?(principal)), data: custom_fields_data} #{h principal.name} </option>) #, :onchange => "select_from_custom_field(event);"
    end
    s.html_safe
  end
=end

  # Función helper empleada para mejorar la muestra de valores de los distintos miembros/usuarios necesarios:
=begin
  def custom_values_by_members(members, custom_fields)
    values_by_members = {}
    members.each do |member|
      values_by_members.merge!(member.id => {})
    end
    values = CustomValue.where("customized_type = ? AND customized_id IN (?) AND custom_field_id IN (?)", Principal.name.demodulize, members.map(&:id), custom_fields.map(&:id) )
    values.each do |value|
      values_by_members[value.customized_id].merge!(value.custom_field_id => value.value)
    end
    values_by_members
  end
=end
