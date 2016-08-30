module RedmineTeachingExtension
  class Hooks < Redmine::Hook::ViewListener
    # Hook empleado para cargar el contenido de la hoja de estilos, necesaria
    # para dotar de estilos a las vistas del sistema:
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("multiusers_issue", :plugin => "redmine_teaching_extension")
    end
  end
end