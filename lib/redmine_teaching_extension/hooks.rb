module RedmineTeachingExtension
  class Hooks < Redmine::Hook::ViewListener
    # Hook empleado para cargar el contenido de la hoja de estilos y el script en javascript, necesarios
    # para dotar de funcionalidad al sistema de asignación de issue a proyectos/estudiantes de asignatura:
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("multiusers_issue", :plugin => "redmine_teaching_extension")
    end
  end
end
