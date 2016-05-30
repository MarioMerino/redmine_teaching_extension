# Plugin's routes routing.html
RedmineApp::Application.routes.draw do
  # Se establece la ruta del link de la ventana de asignación de alumnos a asignatura, correspondiente a un proyecto en cuestión:
  get :plugin_teaching_extension_load_students_selection, to: "issues#load_students_selection"
end