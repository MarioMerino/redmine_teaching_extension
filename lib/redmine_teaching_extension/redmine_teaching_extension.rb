
#Rails.configuration.to_prepare do
#  require 'redmine_teaching_extension/hooks/views_issues_hook'
#end

module RedmineTeachingExtension
  def self.settings()
    Setting[:plugin_redmine_teaching_extension].blank? ? {} : Setting[:plugin_redmine_teaching_extension]
  end
end