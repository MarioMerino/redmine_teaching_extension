module RedmineTeachingExtension
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_layouts_base_content, :partial => "issues/propagate_issues"
    end
  end
end
