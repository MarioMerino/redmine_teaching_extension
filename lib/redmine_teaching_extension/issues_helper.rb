require_dependency 'issues_helper'

module IssuesHelper

  # Función para cargar correctamente una selección múltiple de usuarios, mediante checkbox:
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
                     :class => ("inactive" unless allowed_members.include?(principal)), data: custom_fields_data, :onchange => "select_from_custom_field(event);"} #{h principal.name} </option>)
    end
    s.html_safe
  end

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

  # Función helper empleada para mejorar la muestra de valores de los distintos miembros/usuarios necesarios:
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
end