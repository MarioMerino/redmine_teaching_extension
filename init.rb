require 'redmine'
require 'redmine_teaching_extension/redmine_teaching_extension'

ActionDispatch::Callbacks.to_prepare do
 require_dependency 'redmine_teaching_extension/issue_patch'
 require_dependency 'redmine_teaching_extension/issues_controller_patch'
 require_dependency 'redmine_teaching_extension/query_patch'
end

CHECKLISTS_VERSION_NUMBER = '0.0.1'

Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

Redmine::Plugin.register :redmine_teaching_extension do
  name 'Redmine Teaching Extension'
  author 'Mario Merino'
  description 'Trabajo Fin de Grado para extender el sistema de peticiones de Redmine mediante un plugin para su uso en docencia'
  version CHECKLISTS_VERSION_NUMBER
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  #requires_redmine_plugin :redmine_base_select2, :version_or_higher => '0.0.1'

  settings :default => { 'custom_fields' => [] }, :partial => 'settings/propagate_issues/propagate_issues'

end
