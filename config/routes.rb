# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  get :plugin_teaching_extension_load_users_selection, :to => "issues#load_users_selection"
end