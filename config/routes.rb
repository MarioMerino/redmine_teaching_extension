# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  resources :issues do
    member {get :load_students_selection}
  end
end