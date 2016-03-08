require 'redmine'
require 'redmine_teaching_extension/redmine_teaching_extension'

CHECKLISTS_VERSION_NUMBER = '0.0.1'

Redmine::Plugin.register :redmine_teaching_extension do
  name 'Redmine Teaching Extension'
  author 'Mario Merino'
  description 'Trabajo Fin de Grado para extender Redmine mediante un plugin para su uso en docencia'
  version CHECKLISTS_VERSION_NUMBER
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings :default => {
    :save_log => false

  }, :partial => 'settings/propagate_issues/propagate_issues'

end
