require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'controller_rte/issues_controller'
  require_dependency 'helper_rte/issues_helper'
  require_dependency 'model_rte/issue'
  require_dependency 'redmine_teaching_extension/hooks'
  require_dependency 'redmine_teaching_extension/query'
end

CHECKLISTS_VERSION_NUMBER = '0.0.1'

Redmine::Plugin.register :redmine_teaching_extension do
  name 'Redmine Teaching Extension'
  author 'Mario Merino'
  description 'Trabajo Fin de Grado para extender el sistema de peticiones de Redmine mediante un plugin para su uso en docencia'
  version CHECKLISTS_VERSION_NUMBER
  url 'https://github.com/MarioMerino/RedmineTeachingExtension'
  author_url 'http://example.com/about'
  requires_redmine :version_or_higher => '0.0.1'
  #settings :default => { 'custom_fields' => [] }
end